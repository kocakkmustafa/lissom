# Yoga observation contract v1

The user-approved local pilot binds Hatha 1.0.1 lessons h03 and h07 to
explicit tasks. It adds observation infrastructure while model training,
calibration and qualified physical teaching acceptance remain deferred.
It does not narrow the five-course teaching goal.

`config/yoga/tasks.v1.json` is a hash-pinned structural catalog. Each task
binds the exact course bytes/version, lesson, variant, allowed view, actual
side, required landmark names and phase order. h03 declares entering →
holding → exiting. h07 declares liftingArm → sideReach → centerReturn →
loweringArm. They are separate lesson tasks, not a required continuous series.
Only the visible-standing/front pilot is declared. Side view, seated and
wall-supported variants remain unsupported until separately specified and
calibrated. Support force, breath, pain, pressure, safety, personal suitability
and mastery cannot be inferred. Existing lesson adaptations stay available.

`YogaPhaseProvider` is the boundary for a future calibrated phase decoder.
It receives an aspect-corrected image-space frame and explicit task selection;
it does not reuse ROM battery metrics as yoga labels. The current code
contains no production decoder, thresholds or trained yoga model.
`maxFrameGapUs` is a technical continuity cutoff, not a physical hold target.

`YogaObservationAdapter.production` accepts no provider/fixture injection.
Every declared pilot remains unsupported with reason calibrationRequired;
unknown tasks or variants remain unsupportedTask. There is no raw source
subscription or camera allocation. Existing CameraPoseSource and native
capture ownership are unchanged. A later accepted provider requires a
separate additive production integration; a manifest flag cannot enable it.

`YogaObservationAdapter.replay` accepts only explicitly replay-labelled
providers. Implementations used in this change live only in engine tests.
The adapter sequences their declared evidence; this is not recognition from
synthetic poses. Every result keeps replay provenance. An observed interval
is not a form grade and always has progressEffect=0 / establishesMastery=false.
The adapter has no progress store dependency or write path.

Before accepting evidence, the adapter checks exact task/variant/view/actual
side, required observability, structural frame validity, monotonic timestamps
and phase order. Interrupt synchronously on background, permission/source loss,
account/task/view change or capture retirement. Model/calibration/provider
identity changes invalidate the adapter. Old asynchronous callbacks, overlapping
frames and errors cannot continue an interval. Close invalidates synchronously
and preserves the provider close Future. The caller owns raw camera lifecycle;
this pilot does not create a second capture manager.

The default lesson availability card hash-verifies catalog and course bytes.
It shows calibration required for h03/h07 and unsupported for other lessons;
configuration failure offers retry and keeps the lesson accessible. It neither
starts capture nor modifies self-recorded practice. Preparation remains before
the availability card. TR/EN 320px/200% text is covered by widget checks.

Lissom now consumes published Motion Core PR #9 / immutable main commit
`62c105567a9fdfa9d907a8f8a399494c8ae5b598`: motion_core 0.13.0,
provider contract 1.0.0. App and engine Git declarations/locks share this
exact revision; camera remains 0.2.0. No local override is used.

The catalog constructs the shared typed `MotionProviderManifest` with null
model/calibration/acceptance hashes and calibrationRequired capabilities.
`productionReadiness` checks the exact app-owned task selection before the
shared `MotionProviderRequirement` gate. Both production adapter and lesson
availability use this gate. Production still has no provider injection, model
activation, replay fallback or progress write. The wire getter serializes the
typed declaration for inspection; its fields cannot activate capture.

Focused integration checks cover both task bindings, shared closed readiness,
wire round-trip, replay/ABI refusal and unchanged production/lifecycle behavior.
These are synthetic/host checks, not trained recognition or consumer device
acceptance. Core publication CI is recorded separately from Lissom adoption.

After training: freeze qualified task definitions and validation tolerances,
use the existing first-party rights/split/one-shot holdout tools, bind exact
model/calibration/runtime/acceptance hashes, then verify real-device parity,
permissions/background, sustained capture and expert/learner teaching. No
synthetic result closes those gates. Current-source signed packages, real
account/IAP/restore, privacy and final user release approval remain separate.
