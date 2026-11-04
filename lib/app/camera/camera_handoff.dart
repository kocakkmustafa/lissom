import 'dart:async';

/// One camera at a time across Lissom's two camera stacks: the mirror
/// (`camera` package, preview only) and coaching (`motion_camera`, landmarks
/// only). Each screen waits for the previous holder's release before it
/// opens, and records its own release when it closes. A failed release is
/// not hidden: the next opener still waits for it, then may try.
Future<void> _released = Future<void>.value();

/// Completes once every recorded release has finished (or failed).
Future<void> awaitCameraHandoff() =>
    _released.then<void>((_) {}, onError: (Object _, StackTrace _) {});

/// Records [release] as pending; later openers wait for it.
void noteCameraRelease(Future<void> release) {
  final Future<void> before = awaitCameraHandoff();
  _released = Future.wait<void>(<Future<void>>[
    before,
    release.then<void>((_) {}, onError: (Object _, StackTrace _) {}),
  ]).then<void>((_) {});
}
