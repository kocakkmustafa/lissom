# Lissom reviewer notes — local draft, not submitted

Bundle `com.yulalab.lissom`; ASC app ID 6794715023; version 1.0.0 (build 4 in source). Reconciled 2026-10-27 with Motion Core R4 `0d29d1b` and the founder decisions K-2 (13–17 purchases follow store family controls, all five Motion apps) and K-7 (store name "Lissom: Yoga & Mobility", free-lesson counts, Apple standard EULA, all countries). The App Review text to paste is `release-review.json` → `appReview` (EN/TR); this file keeps the longer background. The final signed package must be bound before submission. No credentials belong in this file.

## Content

The Library contains five written catalogues, with interface and lessons in 14 languages: Hatha 60, Ashtanga beginner foundations 19, supported Yin 12, supported Vinyasa 14 (with an optional knees-down floor extension) and chair/office 15 — 120 lessons in total. Ashtanga is not the full Primary Series. Lesson work is self-recorded locally; it does not certify mastery. Demonstration video is absent. Lissom is not a medical device and gives general information only.

Camera evaluation is closed in this release and research models are not activated. The camera code path (MediaPipe/CameraX via `motion_camera`) is compiled into the binary, so the camera usage description and the Android camera permission remain declared; the camera step is gated off (`requireMotionCameraAccess`, Core `motionCameraCoachingAvailable = false`) and the app never requests camera permission. Open-source licences, including the native MediaPipe and CameraX Apache-2.0 notices, are listed under Profile → Open-source licences.

## Subscriptions

Auto-renewable, group "Motion membership":

| Plan | iOS product | Play product / base plan | USD base |
|---|---|---|---|
| Lissom monthly | `com.yulalab.lissom.individual.monthly` | `lissom_individual` / `monthly` | 11.99 |
| Lissom yearly | `com.yulalab.lissom.individual.yearly` | `lissom_individual` / `yearly` | 69.99 |
| Motion+ monthly | `com.yulalab.lissom.motionplus.monthly` | `lissom_motion_plus` / `monthly` | 19.99 |
| Motion+ yearly | `com.yulalab.lissom.motionplus.yearly` | `lissom_motion_plus` / `yearly` | 129.99 |

- Every product starts with a 14-day free trial for new subscribers (Apple introductory offer, Play free-trial phase). The Motion+ trial is granted **once per Motion account** across the five Motion apps (Core R3, founder decision K3): on iOS 16+ the server marks later apps as not eligible; on iOS 15 Apple's per-group eligibility applies; on Play the Motion+ offer is Developer determined with tag `motion-plus-trial`.
- Motion+ also opens the paid parts of Ostinato, Choreia, JabLab and Gravita for the same Motion account.
- The app shows only store-localized prices (`subscriptions-draft.json`).
- Free part of each course (shortest whole-module prefix covering at least a third): Hatha 24/60, chair/office 6/15, Vinyasa 5/14, Yin 5/12, Ashtanga 7/19 — 47/120. These are the current app counts, confirmed by founder decision K-7 (2026-10-27). The remaining lessons need a Lissom or Motion+ subscription; practice records stay readable whatever the subscription state.

**To review a purchase:** Library → supported Vinyasa → lesson 6 (marked "Included with a Lissom or Motion+ subscription") → sign in with the supplied review account → the shared Membership page shows the store-localized offers with trial and renewal terms, **Restore purchases**, **Manage subscription in the store** and Terms/Privacy links. The same page is reachable from Profile → Account → **Membership options**. Purchases are verified server-side (`motion-verify-purchase`) and linked to the Motion account; restore re-verifies; App Store Server Notifications v2 / Play RTDN update renewals, cancellations and refunds on the server (`motion-store-notifications`).

**Cancellation:** in the App Store / Google Play subscription settings (the "Manage subscription in the store" button opens them). Deleting the Motion account does not cancel a store subscription.

## Accounts, age and parental consent

Browse and practice records can be reviewed as a guest after onboarding; the free part of every course needs no account. The optional shared Motion account is under Profile → Account. Sign-in, verification/recovery callbacks and account deletion need the live service and the separately supplied review account. Do not invent a review username/password or create a new account automatically.

Accounts are for ages 13 and over. Under-13 sign-up is blocked and the block persists on the device; the courses stay available as a guest. Users under their country's digital-consent age (country source: store country, otherwise device region) get a restricted account until a parent or guardian approves by email. A restricted account can still see the subscription offers; purchases by users under 18 are subject to the store's family controls (Ask to Buy on the App Store, parental approval on Google Play), and a purchase waiting for that approval is not active. Account features stay limited until consent, and users under 13 cannot purchase (Core R4 `MotionTeenPurchasePolicy.storeFamilyControls`, `lib/app/lissom_release_policy.dart`). On iOS 26+ sign-up may show Apple's Declared Age Range sheet; a shared range can only tighten the flow (under-13 range blocks; a declaration older than the range is refused for correction). When the range is not shared or not available, the declaration flow is unchanged.

The in-app **Delete Motion account** action (Profile → Account) affects the common account across all five Motion apps; it is a destructive acceptance step requiring a dedicated test account and explicit deletion authorization. Local records are scoped to guest/account; deleting one account must not erase guest or another account. The external deletion request page is the shared Motion page https://yulalab.com/en/delete-account/motion (YULALAB YUL-14, 14 languages); it goes live with the next site release, and Play's deletion URL field uses it from then on.

## Screenshots

Suggested scenes: Library showing all five catalogues; one written lesson with support/rest options; a locked lesson and the Membership page; local self-recorded progress; optional account/privacy entry. Capture from the accepted signed package in EN/TR. Keep real email/account/history private. Host renders are drafts, not device proof.

`LISSOM_STORE_DRAFT_DIR=/absolute/local/output flutter test --no-pub tool/render_store_drafts.dart` renders Home, Library, empty Progress and the first written lesson in EN/TR as 1290×2796 PNGs (the store listings themselves are drafted in all 14 languages, K-6) with a visible HOST DRAFT banner (2026-10-18 tool; bundled fonts/icons and real course JSON; isolated empty guest fixture). No screenshot has been uploaded.

## Final prerequisites

Signed current IPA/AAB (LIS-04: hash, identity, version, signature, Declared Age Range profile); merged SDK privacy report; sandbox S1–S18 plus the Core R4 store-family-controls checks S-R4-1…3 and S-R4-5 (`scratch/2026-10-23-lissom-sales/SALES-PLAN.tr.md`); real account tests; live Motion Core functions and parental-consent mail; external deletion link (YUL-14); privacy forms (`privacy-review.json`) and fresh screenshots; console entry of the K-7 store decisions and the 14 K-6 listings; explicit publication decision. No upload or submission is requested or performed by this file.
