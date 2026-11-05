"""Side-view pose features for the Lissom camera coaching trial.

This file is the reference for `packages/lissom_engine/lib/src/camera/
pose_features.dart`. Both must give the same numbers on the same landmarks
(`test/fixtures/camera/feature_parity.v1.json` checks it). Input: MediaPipe
Pose 33 landmarks, normalized image coordinates (x by width, y by height),
plus visibility. Geometry runs in an aspect-corrected space (x * aspect).
"""
import math

L_SH, R_SH, L_EL, R_EL, L_WR, R_WR = 11, 12, 13, 14, 15, 16
L_HIP, R_HIP, L_KN, R_KN, L_AN, R_AN = 23, 24, 25, 26, 27, 28
L_HEEL, R_HEEL, L_TOE, R_TOE = 29, 30, 31, 32
NOSE, L_EAR, R_EAR = 0, 7, 8

# Landmarks that must be visible for any feature to be computed.
CORE = (L_SH, R_SH, L_HIP, R_HIP)
FEATURES = (
    'trunkLean', 'hip', 'kneeNear', 'kneeMin', 'kneeMax', 'frontKnee', 'rearKnee',
    'liftedKnee', 'standingKnee', 'shoulderFlex', 'elbow', 'headDrop',
    'thighFromVertical', 'ankleLift', 'stanceSplit', 'headBelowHip',
    'shoulderWidthRatio', 'ankleDrop', 'facing',
)


def _pt(lm, i, aspect):
    return (lm[i][0] * aspect, lm[i][1])


def _mid(a, b):
    return ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)


def _angle(a, b, c):
    """Unsigned angle ABC in degrees, 0..180."""
    v1 = (a[0] - b[0], a[1] - b[1])
    v2 = (c[0] - b[0], c[1] - b[1])
    n1 = math.hypot(*v1)
    n2 = math.hypot(*v2)
    if n1 < 1e-9 or n2 < 1e-9:
        return None
    cos = (v1[0] * v2[0] + v1[1] * v2[1]) / (n1 * n2)
    return math.degrees(math.acos(max(-1.0, min(1.0, cos))))


def _between(u, v):
    """Unsigned angle between two vectors in degrees."""
    nu, nv = math.hypot(*u), math.hypot(*v)
    if nu < 1e-9 or nv < 1e-9:
        return None
    cos = (u[0] * v[0] + u[1] * v[1]) / (nu * nv)
    return math.degrees(math.acos(max(-1.0, min(1.0, cos))))


def frame_features(lm, aspect, min_vis=0.5, pair_vis=0.3):
    """lm: 33 rows of (x, y, z, visibility, ...). Returns dict or None.

    None means the frame is not judgeable (core landmarks not visible or the
    torso is too small). Individual features are None when their landmarks
    are not visible.
    """
    vis = [float(row[3]) for row in lm]
    if any(vis[i] < min_vis for i in CORE):
        return None
    P = {i: _pt(lm, i, aspect) for i in range(33)}
    sh = _mid(P[L_SH], P[R_SH])
    hp = _mid(P[L_HIP], P[R_HIP])
    torso = math.hypot(sh[0] - hp[0], sh[1] - hp[1])
    if torso < 0.03:
        return None

    def ok(*idx):
        return all(vis[i] >= min_vis for i in idx)

    def ok_pair(*idx):
        return all(vis[i] >= pair_vis for i in idx)

    # Facing direction from the feet (toe ahead of heel), then the nose.
    fx = 0.0
    n = 0
    for heel, toe in ((L_HEEL, L_TOE), (R_HEEL, R_TOE)):
        if ok(heel, toe):
            fx += P[toe][0] - P[heel][0]
            n += 1
    if n == 0 or abs(fx / n) < 0.02 * torso:
        fx = P[NOSE][0] - sh[0] if ok(NOSE) else 0.0
    facing = 1.0 if fx > 0 else -1.0 if fx < 0 else 0.0

    # Plain left-to-right addition, as in Dart: Python 3.12's sum() uses
    # compensated summation and can break a tie differently.
    left_score = right_score = 0.0
    for i in (L_SH, L_HIP, L_KN, L_AN):
        left_score += vis[i]
    for i in (R_SH, R_HIP, R_KN, R_AN):
        right_score += vis[i]
    near = 'L' if left_score >= right_score else 'R'
    S = {'L': (L_SH, L_EL, L_WR, L_HIP, L_KN, L_AN), 'R': (R_SH, R_EL, R_WR, R_HIP, R_KN, R_AN)}
    sh_i, el_i, wr_i, hip_i, kn_i, an_i = S[near]

    f = {k: None for k in FEATURES}
    f['facing'] = facing
    dx, dy = sh[0] - hp[0], sh[1] - hp[1]
    f['trunkLean'] = math.degrees(math.atan2(facing * dx, -dy)) if facing else None
    if ok(sh_i, hip_i, kn_i):
        f['hip'] = _angle(P[sh_i], P[hip_i], P[kn_i])
        f['thighFromVertical'] = _between((P[kn_i][0] - P[hip_i][0], P[kn_i][1] - P[hip_i][1]), (0.0, 1.0))
    if ok(hip_i, kn_i, an_i):
        f['kneeNear'] = _angle(P[hip_i], P[kn_i], P[an_i])
    knees = {}
    for side, (h, k, a) in {'L': (L_HIP, L_KN, L_AN), 'R': (R_HIP, R_KN, R_AN)}.items():
        if ok_pair(h, k, a):
            knees[side] = _angle(P[h], P[k], P[a])
    if knees:
        f['kneeMin'] = min(knees.values())
        f['kneeMax'] = max(knees.values())
    if ok_pair(L_AN, R_AN):
        f['ankleLift'] = abs(P[L_AN][1] - P[R_AN][1]) / torso
        f['stanceSplit'] = abs(P[L_AN][0] - P[R_AN][0]) / torso
        if len(knees) == 2:
            lifted = 'L' if P[L_AN][1] < P[R_AN][1] else 'R'
            f['liftedKnee'] = knees[lifted]
            f['standingKnee'] = knees['R' if lifted == 'L' else 'L']
            if facing:
                front = 'L' if facing * (P[L_AN][0] - P[R_AN][0]) > 0 else 'R'
                f['frontKnee'] = knees[front]
                f['rearKnee'] = knees['R' if front == 'L' else 'L']
    flex = []
    for s_i, e_i, h_i in ((L_SH, L_EL, L_HIP), (R_SH, R_EL, R_HIP)):
        if ok(s_i, e_i, h_i):
            a = _angle(P[e_i], P[s_i], P[h_i])
            if a is not None:
                flex.append(a)
    if flex:
        f['shoulderFlex'] = max(flex)
    if ok(sh_i, el_i, wr_i):
        f['elbow'] = _angle(P[sh_i], P[el_i], P[wr_i])
    ears = [P[i] for i in (L_EAR, R_EAR) if ok(i)]
    if ears and facing:
        ear = (sum(e[0] for e in ears) / len(ears), sum(e[1] for e in ears) / len(ears))
        trunk = math.atan2(facing * dx, -dy)
        neck = math.atan2(facing * (ear[0] - sh[0]), -(ear[1] - sh[1]))
        d = math.degrees(neck - trunk)
        f['headDrop'] = (d + 180.0) % 360.0 - 180.0
    if ok(NOSE):
        f['headBelowHip'] = (P[NOSE][1] - hp[1]) / torso
    f['shoulderWidthRatio'] = abs(P[L_SH][0] - P[R_SH][0]) / torso
    ankles = [P[i] for i in (L_AN, R_AN) if ok(i)]
    if ankles:
        # Lowest visible ankle below the hips, in torso lengths: standing
        # ~1.6-1.9, sitting on a chair ~0.8-1.1, sitting on the floor ~0.
        f['ankleDrop'] = (max(a[1] for a in ankles) - hp[1]) / torso
    return f
