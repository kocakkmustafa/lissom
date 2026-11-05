"""E16: UI-PRMD (ODC-PDDL 1.0; Vakanski et al., Univ. of Idaho) — 10 people,
Vicon Plug-in Gait markers (39, mm, z up, 100 Hz), segmented repetitions.
Independent test of the camera pose rules after a synthetic side view.

Positives (first 0.5 s of each repetition, a rest posture):
  standing shoulder movements m07-m10 start   -> mountain
  sit to stand m05 start (seated)              -> seated-upright
Negatives: the window at the middle of every repetition of every movement
(dynamic mid-movement shapes), for all poses except their family below.
Usage: python3 evaluate_uiprmd.py <uiprmd-dir> <catalog.json> <out.json>
"""
import glob
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np

from features import frame_features
from verifier import in_pose, window_features

M = {n: i for i, n in enumerate(
    'LFHD RFHD LBHD RBHD C7 T10 CLAV STRN RBAK LSHO LUPA LELB LFRM LWRA LWRB LFIN '
    'RSHO RUPA RELB RFRM RWRA RWRB RFIN LASI RASI LPSI RPSI LTHI LKNE LTIB LANK LHEE '
    'LTOE RTHI RKNE RTIB RANK RHEE RTOE'.split())}
FPS = 100
WIN = 50                 # 0.5 s (deviation from the app's 1 s: rest phases are short)
SIZE = (1080, 1920)      # portrait, as motion_camera delivers
HEIGHT_MM = 2300.0
POSITIVE = {'m07': 'mountain', 'm08': 'mountain', 'm09': 'mountain', 'm10': 'mountain',
            'm05': 'seated-upright'}
# Mid-movement shapes a side camera cannot tell from these pose families.
FAMILY = {
    'warrior-one-short': {'m03'},      # inline lunge
    'staggered-stance': {'m03', 'm02'},
    'small-chair-pose': {'m01', 'm05'},  # squat / rising from a chair pass through it
    'seated-upright': {'m05'},
    'tree-wall': {'m02', 'm06'},       # hurdle step / straight-leg raise lift a foot
}


def joints(frame):
    g = lambda n: frame[M[n]]
    mid = lambda a, b: (g(a) + g(b)) / 2
    down = np.array([0, 0, -70.0])
    return {
        11: g('LSHO'), 12: g('RSHO'), 13: g('LELB'), 14: g('RELB'),
        15: mid('LWRA', 'LWRB'), 16: mid('RWRA', 'RWRB'),
        23: mid('LASI', 'LPSI') + down, 24: mid('RASI', 'RPSI') + down,
        25: g('LKNE'), 26: g('RKNE'), 27: g('LANK'), 28: g('RANK'),
        29: g('LHEE'), 30: g('RHEE'), 31: g('LTOE'), 32: g('RTOE'),
        7: mid('LFHD', 'LBHD'), 8: mid('RFHD', 'RBHD'), 0: mid('LFHD', 'RFHD'),
    }


def project(P):
    """(T,39,3) mm -> list of 33-landmark frames, side view, portrait."""
    lr = np.median(P[:, M['LASI']] - P[:, M['RASI']], 0)
    lr[2] = 0
    lr /= np.linalg.norm(lr)
    fwd = np.cross([0, 0, 1.0], lr)
    toe = np.median(P[:, [M['LTOE'], M['RTOE']]] - P[:, [M['LHEE'], M['RHEE']]], (0, 1))
    if np.dot(fwd, toe) < 0:
        fwd = -fwd
    centre = np.median((P[:, M['LASI']] + P[:, M['RASI']]) / 2, 0)
    aspect = SIZE[0] / SIZE[1]
    out = []
    for f in P:
        J = joints(f)
        lm = [[0.0, 0.0, 0.0, 0.0] for _ in range(33)]
        for i, p in J.items():
            d = p - centre
            u = float(d @ fwd) / HEIGHT_MM
            v = 0.55 - float(d[2]) / HEIGHT_MM
            lm[i] = [(aspect / 2 + u) / aspect, v, float(d @ lr) / HEIGHT_MM, 1.0]
        out.append(lm)
    return out


def window(lms, start):
    return window_features([frame_features(lm, SIZE[0] / SIZE[1]) for lm in lms[start:start + WIN]])


def main(root, catalog_path, out_path):
    cat = json.loads(Path(catalog_path).read_text())
    files = sorted(glob.glob(str(Path(root) / 'ext/Segmented Movements/Vicon/Positions/*_positions.txt')))
    rows = []
    for f in files:
        name = Path(f).name
        mv, subj = name[:3], name[4:7]
        P = np.loadtxt(f, delimiter=',').reshape(-1, 39, 3)
        lms = project(P)
        first = window(lms, 0)
        mid = window(lms, max(0, len(lms) // 2 - WIN // 2))
        rows.append({'file': name, 'movement': mv, 'subject': subj,
                     'first': {p['id']: in_pose(p, first) for p in cat['poses']},
                     'mid': {p['id']: in_pose(p, mid) for p in cat['poses']}})
    res = {'catalogSha256': hashlib.sha256(Path(catalog_path).read_bytes()).hexdigest(),
           'catalogVersion': cat.get('version'),
           'data': 'UI-PRMD Segmented Movements, Vicon positions (ODC-PDDL 1.0), 10 subjects',
           'repetitions': len(rows), 'poses': {}}
    for p in cat['poses']:
        pid = p['id']
        pos = [r for r in rows if POSITIVE.get(r['movement']) == pid]
        neg = [r for r in rows if r['movement'] not in FAMILY.get(pid, set())]
        by = defaultdict(int)
        for r in neg:
            if r['mid'][pid]:
                by[r['movement']] += 1
        res['poses'][pid] = {
            'positives': len(pos), 'people': len({r['subject'] for r in pos}),
            'trueAccept': float(np.mean([r['first'][pid] for r in pos])) if pos else None,
            'trueAcceptByPerson': {s: float(np.mean([r['first'][pid] for r in pos if r['subject'] == s]))
                                   for s in sorted({r['subject'] for r in pos})} if pos else {},
            'negatives': len(neg),
            'falseAccept': float(np.mean([r['mid'][pid] for r in neg])),
            'falseAcceptBy': dict(by),
            'familyExcluded': sorted(FAMILY.get(pid, set())),
        }
    Path(out_path).write_text(json.dumps(res, indent=1))
    for pid, r in res['poses'].items():
        ta = '  -  ' if r['trueAccept'] is None else f"{r['trueAccept']:.3f}"
        print(f"{pid:22s} TA {ta} (n={r['positives']}, people={r['people']}) FA {r['falseAccept']:.3f} {r['falseAcceptBy']}")


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3])
