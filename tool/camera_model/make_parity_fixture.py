"""Writes the Dart/Python feature parity fixture.

Synthetic landmarks only (no dataset frames): random bodies plus random
visibility, so both implementations meet hidden joints, both facings and
degenerate cases. Usage: python3 make_parity_fixture.py <out.json>
"""
import json
import random
import sys

from features import FEATURES, frame_features


def body(rng):
    lm = [[rng.uniform(0.05, 0.95), rng.uniform(0.05, 0.95), rng.uniform(-0.5, 0.5),
           rng.choice([0.05, 0.35, 0.6, 0.9, 0.99])] for _ in range(33)]
    if rng.random() < 0.7:  # make the core visible most of the time
        for i in (11, 12, 23, 24):
            lm[i][3] = 0.95
    return lm


def main(out):
    rng = random.Random(20261105)
    cases = []
    for k in range(60):
        lm = body(rng)
        aspect = rng.choice([9 / 16, 3 / 4, 16 / 9])
        f = frame_features(lm, aspect)
        cases.append({'landmarks': [[round(v, 6) for v in row] for row in lm],
                      'width': 1080 if aspect == 9 / 16 else 1440 if aspect == 3 / 4 else 1920,
                      'height': 1920 if aspect == 9 / 16 else 1920 if aspect == 3 / 4 else 1080,
                      'features': None if f is None else {k2: v for k2, v in f.items() if v is not None}})
    # recompute features from the rounded landmarks so both sides read the same input
    for c in cases:
        f = frame_features(c['landmarks'], c['width'] / c['height'])
        c['features'] = None if f is None else {k2: v for k2, v in f.items() if v is not None}
    json.dump({'schema': 'lissom.camera.feature-parity.v1', 'features': list(FEATURES),
               'note': 'synthetic landmarks; written by tool/camera_model/make_parity_fixture.py',
               'cases': cases}, open(out, 'w'), indent=0)
    print(len(cases), sum(c['features'] is None for c in cases), 'unjudgeable')


if __name__ == '__main__':
    main(sys.argv[1])
