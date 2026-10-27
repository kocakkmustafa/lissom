import 'package:motion_account/motion_account.dart';

/// Founder decision K-2 (2026-10-27, all five Motion apps): a 13–17 account
/// still waiting for parental consent sees the subscription offers, and the
/// purchase itself is left to the store's family controls (Ask to Buy /
/// Google Play parental approval). Core R4 keeps its own default closed;
/// Lissom opts in here for the account page, the paid-lesson gate and the
/// camera gate. Account features stay closed until consent and under-13
/// accounts cannot buy.
const MotionTeenPurchasePolicy lissomTeenPurchasePolicy =
    MotionTeenPurchasePolicy.storeFamilyControls;
