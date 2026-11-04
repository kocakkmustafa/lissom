"""Rule verifier reference for the camera coaching trial (mirrors the Dart
`CameraPoseVerifier`). A window passes when every `define` check of the pose
holds on the window's per-feature median."""
import json
import math
from pathlib import Path

from features import frame_features

CATALOG = Path(__file__).resolve().parents[2] / 'config' / 'yoga' / 'camera-poses.v1.json'


def load_catalog(path=CATALOG):
    return json.loads(Path(path).read_text())


def median(values):
    v = sorted(values)
    n = len(v)
    if n == 0:
        return None
    return v[n // 2] if n % 2 else (v[n // 2 - 1] + v[n // 2]) / 2


def window_features(frames):
    """frames: list of feature dicts (None = unjudgeable frame)."""
    good = [f for f in frames if f is not None]
    if not good:
        return None
    out = {}
    for k in good[0]:
        vals = [f[k] for f in good if f.get(k) is not None]
        out[k] = median(vals) if vals else None
    return out


def check_ok(check, value):
    if value is None:
        return False
    if 'min' in check and value < check['min']:
        return False
    if 'max' in check and value > check['max']:
        return False
    return True


def in_pose(pose, wf):
    return wf is not None and all(check_ok(c, wf.get(c['feature'])) for c in pose['define'])


def first_correction(pose, wf):
    if wf is None:
        return None
    for c in pose['corrections']:
        v = wf.get(c['feature'])
        if v is not None and not check_ok(c, v):
            return c
    return None
