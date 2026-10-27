import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_release_policy.dart';
import 'package:motion_account/motion_account.dart';

// K-2 (founder decision 2026-10-27, all five Motion apps) on Core R4: Lissom
// leaves 13–17 purchases to the store's family controls. Core keeps
// parentalConsentRequired as its default, so every Core entry point Lissom
// opens must carry the app's choice; a missing argument silently falls back
// to the Core default.
void main() {
  test('Lissom selects store family controls, not the Core default', () {
    expect(
      lissomTeenPurchasePolicy,
      MotionTeenPurchasePolicy.storeFamilyControls,
    );
    expect(
      const MotionAccountPage(account: _NeverAccount()).teenPurchasePolicy,
      MotionTeenPurchasePolicy.parentalConsentRequired,
      reason: 'Core default unchanged; Lissom must pass its policy',
    );
  });

  // The paid and camera gates open Core's default MotionMembershipPage, which
  // takes the policy from these calls (Core R4 tests that forwarding). Guard
  // the app side: each Core purchase entry point in lib/ passes the policy.
  test('every Core purchase entry point passes the Lissom policy', () {
    final sources = <String, String>{
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File && file.path.endsWith('.dart'))
          // Comment lines may name these calls; only code is checked.
          file.path: file
              .readAsLinesSync()
              .where((line) => !line.trimLeft().startsWith('//'))
              .join('\n'),
    };
    final calls = <String>[];
    sources.forEach((path, source) {
      for (final entry in [
        'MotionAccountPage(',
        'requireMotionPaidAccess(',
        'requireMotionCameraAccess(',
      ]) {
        for (
          var start = source.indexOf(entry);
          start >= 0;
          start = source.indexOf(entry, start + 1)
        ) {
          final call = source.substring(start, _closingParen(source, start));
          calls.add('$path $entry');
          expect(
            call,
            contains('teenPurchasePolicy: lissomTeenPurchasePolicy'),
            reason: '$path $entry',
          );
        }
      }
      expect(source, isNot(contains('MotionMembershipPage(')), reason: path);
    });
    expect(calls, hasLength(3), reason: calls.join(' · '));
  });
}

int _closingParen(String source, int from) {
  var depth = 0;
  for (var i = source.indexOf('(', from); i < source.length; i++) {
    if (source[i] == '(') depth++;
    if (source[i] == ')' && --depth == 0) return i;
  }
  throw StateError('unbalanced call at $from');
}

final class _NeverAccount implements MotionAccountClient {
  const _NeverAccount();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('not used');
}
