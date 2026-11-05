"""E17: VIDIMU real videos (CC BY 4.0, 54 people) through MediaPipe Pose
Landmarker Full (pinned) -> the app's coaching logic. First real-camera-chain
test. Positives: seated start of A04 (sit to stand) and A05-A09 (seated
tasks, hands on knees) -> seated-upright. Negatives: walking A01-A03 for the
seated poses; seated A05-A09 for the standing poses.
Two readings: (a) the app as built, setup gate included; (b) rules only.
Usage: python3 evaluate_vidimu.py <landmarks-dir> <catalog.json> <out.json>
"""
import glob
import hashlib
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

import numpy as np

from features import frame_features
from verifier import in_pose, setup_issue, window_features

SEATED = {4, 5, 6, 7, 8, 9}
WALK = {1, 2, 3}


def confirmed(pose, frames, fps, window_s, stable_s):
    need_w, need_s = int(window_s * fps), int(stable_s * fps)
    run = 0
    for i in range(need_w - 1, len(frames)):
        w = [f for f in frames[i - need_w + 1:i + 1] if f is not None]
        ok = len(w) >= 3 and in_pose(pose, window_features(w))
        run = run + 1 if ok else 0
        if run > need_s:
            return True
    return False


def main(lm_dir, catalog_path, out_path):
    cat = json.loads(Path(catalog_path).read_text())
    setup = cat['setup']
    win, stable = cat['window']['seconds'], setup['stableSeconds']
    rows, issues = [], Counter()
    for f in sorted(glob.glob(str(Path(lm_dir) / '*.npz'))):
        stem = Path(f).stem
        subj, act = stem.split('_')[0], int(stem.split('_')[1][1:])
        z = np.load(f)
        lm, fps = z['lm'].astype(float), int(z['fps'])
        aspect = float(z['width']) / float(z['height'])
        gated, raw = [], []
        for t in range(len(lm)):
            L = None if not np.isfinite(lm[t, 0, 0]) else lm[t].tolist()
            iss = setup_issue(L, aspect, setup)
            issues[(act in SEATED, iss)] += 1
            ff = None if L is None else frame_features(L, aspect)
            raw.append(ff)
            gated.append(ff if iss is None else None)
        rows.append({'stem': stem, 'subject': subj, 'act': act,
                     'app': {p['id']: confirmed(p, gated, fps, win, stable) for p in cat['poses']},
                     'rules': {p['id']: confirmed(p, raw, fps, win, stable) for p in cat['poses']}})
    res = {'catalogSha256': hashlib.sha256(Path(catalog_path).read_bytes()).hexdigest(),
           'data': 'VIDIMU Zenodo 8210563 (CC BY 4.0), videosoriginal small, 640x480, MediaPipe Pose Landmarker Full v1 (pinned), 10 fps',
           'videos': len(rows), 'people': len({r['subject'] for r in rows}),
           'setupIssues': {f"{'seated' if k[0] else 'other'}:{k[1]}": v for k, v in issues.items()},
           'poses': {}}
    for p in cat['poses']:
        pid = p['id']
        if pid == 'seated-upright':
            pos = [r for r in rows if r['act'] in SEATED]
        else:
            pos = []
        neg = [r for r in rows if (r['act'] in WALK if p['posture'] == 'chair' else r['act'] in SEATED - {4})]
        entry = {'positives': len(pos), 'negatives': len(neg)}
        for mode in ('app', 'rules'):
            entry[mode] = {
                'trueAccept': float(np.mean([r[mode][pid] for r in pos])) if pos else None,
                'trueAcceptPeople': len({r['subject'] for r in pos if r[mode][pid]}),
                'falseAccept': float(np.mean([r[mode][pid] for r in neg])) if neg else None,
            }
        res['poses'][pid] = entry
    Path(out_path).write_text(json.dumps(res, indent=1))
    print('videos', res['videos'], 'people', res['people'])
    print('setup', res['setupIssues'])
    for pid, e in res['poses'].items():
        a, r = e['app'], e['rules']
        f = lambda x: '  -  ' if x is None else f'{x:.3f}'
        print(f"{pid:22s} app TA {f(a['trueAccept'])} FA {f(a['falseAccept'])} | rules TA {f(r['trueAccept'])} FA {f(r['falseAccept'])}")


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3])
