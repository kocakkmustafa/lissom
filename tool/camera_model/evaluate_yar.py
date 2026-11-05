"""Evaluates the camera pose catalog on YAR/YogNet side-view clips.

YAR (Mendeley 10.17632/k842kz6v4n.1, CC BY 4.0) is development data here, not
an independent test: the rules were written from the lesson text and then
checked against it. Output: per pose, true accept (proxy class clips) and
false accept (other classes), clip level. A clip counts as accepted when the
app would confirm the pose: the pose holds on consecutive 1 s windows for
`setup.stableSeconds` (the same rule the app uses before the hold timer runs).

Usage: python3 evaluate_yar.py <yar-dir> <out.json>
"""
import hashlib
import json
import sys
from pathlib import Path

import numpy as np

from features import frame_features
from verifier import CATALOG, in_pose, load_catalog, window_features

WIN = 5          # YAR proxies are 5 fps: 5 frames = 1 s, as in the app.
STRIDE = 2       # 0.4 s between windows
SIDE_YAW = 60.0  # same side/front split as E04
# Classes the side camera cannot tell apart from the pose's family; they are
# left out of that pose's negatives and listed in the report.
FAMILY = {
    'wide-leg-fold': {'padahastasana'},
    'chair-supported-fold': {'padahastasana'},
    'shin-supported-fold': {'padahastasana'},
}


def yaw(lm):
    dx = lm[:, 11, 0] - lm[:, 12, 0]
    dz = lm[:, 11, 2] - lm[:, 12, 2]
    return float(np.nanmedian(np.degrees(np.arctan2(np.abs(dz), np.abs(dx)))))


def longest_run(flags):
    best = cur = 0
    for f in flags:
        cur = cur + 1 if f else 0
        best = max(best, cur)
    return best


def clip_windows(lm, aspect):
    feats = []
    for t in range(len(lm)):
        feats.append(None if not np.isfinite(lm[t, 0, 0]) else frame_features(lm[t].tolist(), aspect))
    out = []
    for s in range(0, max(1, len(feats) - WIN + 1), STRIDE):
        w = feats[s:s + WIN]
        if sum(f is not None for f in w) >= 3:
            out.append(window_features(w))
    return out


SPLIT_SEED = 20261105


def person_of(yar):
    """Clip -> person group. E04 asanas: frozen block groups; the other ten:
    the frozen clothing-based nearest assignment (E13 file)."""
    pg = json.loads((yar / 'persons' / 'person-groups.json').read_text())
    oa = json.loads((yar / 'persons' / 'other-asana-assignment.json').read_text())
    out = {}
    clips = json.loads((yar / 'clips.json').read_text())
    for cid, c in clips.items():
        n = int(cid.rsplit('-', 1)[1])
        g = pg['groups'].get(f"{c['label']}/b{(n + 3) // 4:02d}")
        if g is None:
            a = oa['clips'].get(cid)
            # Nearest clothing match without the 0.20 cut: noisier (~20-30%,
            # E13) but it lets the held-out half contain these asanas too.
            if a and a.get('status') == 'ok' and a.get('nearest'):
                g = a['nearest']
        out[cid] = g
    return out


def split_groups(groups):
    """Frozen dev/held-out split of the 17 YAR person groups (seeded)."""
    names = sorted(groups)
    rng = np.random.default_rng(SPLIT_SEED)
    order = [names[i] for i in rng.permutation(len(names))]
    return set(order[:9]), set(order[9:])


def main(yar_dir, out_path, split='all'):
    yar = Path(yar_dir)
    person = person_of(yar)
    dev, held = split_groups({g for g in person.values() if g})
    catalog = load_catalog()
    stable = catalog['setup']['stableSeconds']
    clips = json.loads((yar / 'clips.json').read_text())
    rows = []
    setup_fail = []
    for cid, c in sorted(clips.items()):
        z = np.load(yar / 'landmarks' / f'{cid}.npz')
        lm = z['lm'].astype(float)
        if yaw(lm) < SIDE_YAW:
            continue
        g = person.get(cid)
        if split == 'dev' and g in held:
            continue
        if split == 'held' and g not in held:
            continue
        aspect = float(z['width']) / float(z['height'])
        W = clip_windows(lm, aspect)
        if not W:
            continue
        side_gate = float(np.mean([w['shoulderWidthRatio'] <= catalog['setup']['maxShoulderWidthRatio'] for w in W]))
        if side_gate < 0.5:
            # The app's setup check would ask this person to turn sideways
            # before judging anything; the clip is a setup case, not a
            # verifier decision. Counted and reported, not scored.
            setup_fail.append(cid)
            continue
        share = {p['id']: float(np.mean([in_pose(p, w) for w in W])) for p in catalog['poses']}
        confirmed = {p['id']: longest_run([in_pose(p, w) for w in W]) * STRIDE / 5.0 >= stable for p in catalog['poses']}
        rows.append({'id': cid, 'label': c['label'], 'person': g, 'windows': len(W), 'sideGate': side_gate,
                     'share': share, 'confirmed': confirmed})
    result = {'catalogSha256': hashlib.sha256(CATALOG.read_bytes()).hexdigest(),
              'data': 'YAR/YogNet Mendeley 10.17632/k842kz6v4n.1 (CC BY 4.0), side-view clips (yaw >= 60)',
              'framing': 'development data, rules hand-written from lesson text; not an independent test',
              'split': split, 'splitSeed': SPLIT_SEED, 'heldGroups': sorted(held),
              'clips': len(rows), 'setupFailClips': len(setup_fail),
              'poses': {}}
    for p in catalog['poses']:
        pid, proxy = p['id'], p.get('yarProxy')
        fam = FAMILY.get(pid, set())
        pos = [r for r in rows if proxy and r['label'] == proxy]
        neg = [r for r in rows if r['label'] != proxy and r['label'] not in fam]
        acc = lambda rs: [r['confirmed'][pid] for r in rs]
        fa_by = {}
        for r in neg:
            if r['confirmed'][pid]:
                fa_by[r['label']] = fa_by.get(r['label'], 0) + 1
        result['poses'][pid] = {
            'yarProxy': proxy,
            'positives': len(pos),
            'trueAccept': float(np.mean(acc(pos))) if pos else None,
            'positivePersons': len({r['person'] for r in pos if r['person']}),
            'negatives': len(neg),
            'falseAccept': float(np.mean(acc(neg))),
            'falseAcceptBy': dict(sorted(fa_by.items(), key=lambda kv: -kv[1])),
            'familyExcluded': sorted(fam),
        }
    Path(out_path).write_text(json.dumps(result, indent=1, ensure_ascii=False))
    for pid, r in result['poses'].items():
        ta = '  -  ' if r['trueAccept'] is None else f"{r['trueAccept']:.3f}"
        print(f"{pid:24s} TA {ta} (n={r['positives']:3d}) FA {r['falseAccept']:.3f} (n={r['negatives']}) {r['falseAcceptBy']}")
    print('clips', result['clips'], 'setup-fail (not scored)', len(setup_fail))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else 'all')
