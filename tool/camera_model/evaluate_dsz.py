"""E15: independent, person-disjoint test of the camera pose rules on DSZ-Yoga.

DSZ-Yoga (Zenodo 10.5281/zenodo.18297451, CC BY 4.0, Damiran / NAIST): 12
people, Sun Salutation B, 3D motion capture skeletons (cm, y up), 2 s clips
at ~8 Hz. Never used before by Lissom. No video: this tests the rule layer
after a synthetic side-view projection, not the camera -> MediaPipe step.

Each pose occurrence (a run of same-label clips in a session) is replayed
through the same time-based logic as the app: 1 s per-feature median window,
pose confirmed when it holds for `setup.stableSeconds`.

Usage: python3 evaluate_dsz.py <dsz-dir> <out.json>
"""
import csv
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np

from features import frame_features
from verifier import CATALOG, in_pose, load_catalog, window_features

# DSZ joint index -> MediaPipe landmark index. Read from the data layout
# (spine 0-11, left arm 12-16, right arm 17-21, left leg 22-26, right leg
# 27-31; +x is the subject's left, +z forward). The head has no face points:
# the head joints stand in for the ears and the nose.
MAP = {
    11: 13, 12: 18,           # shoulders (L, R)
    13: 14, 14: 19,           # elbows
    15: 15, 16: 20,           # wrists
    23: 22, 24: 27,           # hips
    25: 23, 26: 28,           # knees
    27: 24, 28: 29,           # ankles
    29: 24, 30: 29,           # heels := ankles (no heel joint)
    31: 25, 32: 30,           # foot index := toe
    7: 9, 8: 9,               # ears := head
    0: 10,                    # nose := head top-front
}
POSITIVE = {
    'Standing_Mountain': ['mountain'],
    'Chair': ['small-chair-pose'],
    'Standing_Forward_Bend': ['chair-supported-fold', 'shin-supported-fold'],
    'Half_Forward_Bend': ['halfway-lift'],
    'Warrior1_Right': ['warrior-one-short'],
    'Warrior1_Left': ['warrior-one-short'],
}
# Labels left out of a pose's negatives because the side camera cannot tell
# them from that pose's family, or the label does not fix the arm position.
FAMILY = {
    'chair-supported-fold': {'Half_Forward_Bend'},
    'wide-leg-fold': {'Standing_Forward_Bend', 'Half_Forward_Bend'},
    'shallow-fold': {'Half_Forward_Bend'},
    'wall-half-hinge': {'Half_Forward_Bend'},
    'hinge-balance': {'Half_Forward_Bend'},
    'standing-arm-raise': {'Standing_Mountain'},
    'staggered-stance': {'Warrior1_Right', 'Warrior1_Left'},
}
HEIGHT_CM = 200.0      # frame height in cm: a ~170 cm person fills ~0.85
SIZE = (1920, 1080)


def project(motion):
    """(T,32,3) cm -> (T,33,4) MediaPipe-like normalized side view."""
    hip_lr = np.median(motion[:, 22] - motion[:, 27], axis=0)
    lr = np.array([hip_lr[0], 0.0, hip_lr[2]])
    lr /= np.linalg.norm(lr)
    fwd = np.cross(lr, [0.0, 1.0, 0.0])           # horizontal, perpendicular
    toe = np.median(motion[:, [25, 30]] - motion[:, [24, 29]], axis=(0, 1))
    if np.dot(fwd, toe) < 0:
        fwd = -fwd
    aspect = SIZE[0] / SIZE[1]
    T = len(motion)
    out = np.zeros((T, 33, 4))
    centre = np.median(motion[:, 0], axis=0)
    for mp, dsz in MAP.items():
        p = motion[:, dsz] - centre
        u = p @ fwd / HEIGHT_CM                   # iso x (frame heights)
        v = 0.55 - p[:, 1] / HEIGHT_CM            # iso y, pelvis a bit low
        out[:, mp, 0] = (aspect / 2 + u) / aspect
        out[:, mp, 1] = v
        out[:, mp, 2] = (p @ lr) / HEIGHT_CM
        out[:, mp, 3] = 1.0
    return out


def occurrences(dsz):
    rows = list(csv.DictReader(open(dsz / 'raw' / 'global_index_dszyoga.csv')))
    by_session = defaultdict(list)
    for r in rows:
        by_session[r['session_id']].append(r)
    occ = []
    for sid, rs in by_session.items():
        rs.sort(key=lambda r: int(r['clip_id'].rsplit('_', 1)[1]))
        cur = None
        for r in rs:
            if cur and r['label'] == cur['label'] and int(r['clip_id'].rsplit('_', 1)[1]) == cur['last'] + 1:
                cur['clips'].append(r['clip_id'])
                cur['last'] += 1
            else:
                cur = {'session': sid, 'label': r['label'], 'clips': [r['clip_id']],
                       'last': int(r['clip_id'].rsplit('_', 1)[1])}
                occ.append(cur)
    return occ


def sequence(dsz, clip_ids):
    frames = {}
    for cid in clip_ids:
        z = np.load(dsz / 'ext' / 'training_ready_dsz_release' / f'{cid}.npz', allow_pickle=False)
        for t, m in zip(z['timestamps'], z['motion']):
            frames[float(t)] = m
    ts = sorted(frames)
    return np.asarray(ts), np.stack([frames[t] for t in ts]).astype(float)


def confirmed(pose, ts_s, feats, window_s, stable_s):
    since = None
    for i, t in enumerate(ts_s):
        if t - ts_s[0] < window_s:
            continue
        w = window_features([f for tt, f in zip(ts_s, feats) if t - window_s <= tt <= t])
        if in_pose(pose, w):
            since = t if since is None else since
            if t - since >= stable_s:
                return True
        else:
            since = None
    return False


def main(dsz_dir, out_path):
    dsz = Path(dsz_dir)
    cat = load_catalog()
    win, stable = cat['window']['seconds'], cat['setup']['stableSeconds']
    rows = []
    for o in occurrences(dsz):
        ts, motion = sequence(dsz, o['clips'])
        ts_s = (ts - ts[0]) / (1e6 if ts[0] > 1e12 else 1.0)
        lm = project(motion)
        feats = [frame_features(lm[t].tolist(), SIZE[0] / SIZE[1]) for t in range(len(lm))]
        rows.append({'session': o['session'], 'label': o['label'], 'seconds': float(ts_s[-1]),
                     'confirmed': {p['id']: confirmed(p, ts_s, feats, win, stable) for p in cat['poses']}})
    res = {'catalogSha256': hashlib.sha256(CATALOG.read_bytes()).hexdigest(),
           'data': 'DSZ-Yoga, Zenodo 10.5281/zenodo.18297451, CC BY 4.0 (Damiran, NAIST); 12 people; motion only',
           'framing': 'independent person-disjoint test of the rule layer on synthetic side-view projections of 3D mocap; not a camera test',
           'occurrences': len(rows), 'people': len({r['session'] for r in rows}), 'poses': {}}
    for p in cat['poses']:
        pid = p['id']
        pos = [r for r in rows if pid in POSITIVE.get(r['label'], [])]
        neg = [r for r in rows if r['label'] != 'Transition' and pid not in POSITIVE.get(r['label'], [])
               and r['label'] not in FAMILY.get(pid, set())]
        trans = [r for r in rows if r['label'] == 'Transition']
        fa_by = defaultdict(int)
        for r in neg:
            if r['confirmed'][pid]:
                fa_by[r['label']] += 1
        res['poses'][pid] = {
            'positives': len(pos), 'positivePeople': len({r['session'] for r in pos}),
            'trueAccept': float(np.mean([r['confirmed'][pid] for r in pos])) if pos else None,
            'missedBy': sorted({r['session'] for r in pos if not r['confirmed'][pid]}),
            'negatives': len(neg),
            'falseAccept': float(np.mean([r['confirmed'][pid] for r in neg])),
            'falseAcceptBy': dict(fa_by),
            'transitionConfirmRate': float(np.mean([r['confirmed'][pid] for r in trans])) if trans else None,
            'familyExcluded': sorted(FAMILY.get(pid, set())),
        }
    Path(out_path).write_text(json.dumps(res, indent=1))
    for pid, r in res['poses'].items():
        ta = '  -  ' if r['trueAccept'] is None else f"{r['trueAccept']:.3f}"
        print(f"{pid:22s} TA {ta} (n={r['positives']:3d}, people={r['positivePeople']:2d}) FA {r['falseAccept']:.3f} (n={r['negatives']}) {r['falseAcceptBy']}")
    print('occurrences', res['occurrences'], 'people', res['people'])


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
