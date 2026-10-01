# Hatha course: teaching and model evidence

Date: 2026-09-26 · Scope: Lissom's first guided course, not a clinical yoga program.

## What the first course may claim

The learner can follow a progressive Hatha sequence, practice individual
postures and breathing awareness, record practice, and use self-check prompts.
The app must not call a posture safe, correct, or mastered from a phone image.
The existing assessment battery measures a narrower set of image-plane
quantities; it is not a yoga-form reference set. Its age-band readings cannot
be transferred into yoga-posture grades.

`pose_seen`, `hold_observed`, `form_graded`, and `safe_to_continue` are four
different claims. None of the latter two has production evidence for this
course. Even a future pose-name classifier would not measure breath, pain,
weight distribution, joint load, or contraindications.

## Sources and how they are used

| Source | Evidence used | Limit |
|---|---|---|
| [Yoga Certification Board, Level 1 syllabus](https://yogacertificationboard.nic.in/wp-content/uploads/2019/11/Syllabus-YPI-Version0.2.pdf) | Foundational practice includes preparation, Surya Namaskara, standing, seated, kneeling and lying asanas, simple breathing, rest, and teaching precautions. The movement coverage matrix maps standard choices, supported preparations and knowledge-only routes separately. | Instructor certification is at least 200 hours; the app cannot claim instructor equivalence. A listed posture is not automatically appropriate for every beginner. |
| [Ministry of AYUSH, Common Yoga Protocol](https://www.yogamdniy.nic.in/files/pdf/CYP-2023-English.pdf) | Session structure: preparation, accessible postures, breathing, rest. | Protocol order is a reference, not an individual prescription. |
| [NIH NCCIH yoga safety review](https://www.nccih.nih.gov/health/yoga-effectiveness-and-safety) | Beginner caution, modification and supervision; exclude unsupported headstand/shoulderstand/forceful breathing from required practice. | General safety advice does not diagnose an individual. |
| [ACOG, exercise during pregnancy](https://www.acog.org/womens-health/faqs/exercise-during-pregnancy) | Pregnancy receives general activity options and a clinician prompt, never an automatic suitability decision. | No prenatal treatment pathway or personal contraindication inference. |
| [Yoga With Adriene, Mountain Pose](https://www.youtube.com/watch?v=NYhH8Gr35cI) | Browser viewing at 2:52 and 6:27 plus time-aligned auto-captions: feet begin about hip width, attention moves from foot contact to standing balance and then to head/torso alignment. This supports an early body-awareness lesson and a front/side demonstration brief. | Pedagogic observation only. The video's medical claims are not adopted. No video frames/audio were copied into a dataset or the app. Auto-captions can err. |

## Model/data audit before implementation

| Candidate | Finding | Decision |
|---|---|---|
| Existing Lissom camera model and assessment fixtures | Body landmarks and some image-plane readings exist; no independent yoga-posture labels or multi-person, multi-device yoga holdout was found in this app. | Reuse only the explicitly measured assessment functionality. No yoga-form score. |
| [Yoga-82 official dataset](https://sites.google.com/view/yoga-82/home) | Its publisher permits non-commercial research/education only; images originate with multiple third-party rights holders. Pose labels do not label correct form or safety. | Do not train a commercial app model on it. |
| [3D-Yoga paper](https://openaccess.thecvf.com/content/ACCV2022/papers/Li_3D-Yoga_A_3D_Yoga_Dataset_for_Visual-based_Hierarchical_Sports_Action_ACCV_2022_paper.pdf) | Describes form-quality labels, but the paper alone is not a commercial data grant or an app-camera validation study. | Research lead only; no training input until rights and data access are verified. |
| YouTube instructor videos | Viewing a demonstration helps write original teaching instructions. [YouTube's terms](https://www.youtube.com/t/terms) restrict copying/download and automated use without authorization. | No scraping or model training from ordinary watch pages. |
| AI-generated course demonstrations | Planned instructional media after course scripts/shot lists are complete. | Never use them as independent evidence that the live camera evaluates diverse real people. |

No train/validation/test split, teacher-labeled error taxonomy, person-disjoint
holdout, or real-phone acceptance exists for Hatha. A numerical model accuracy
or form verdict would be invented. The course's initial measurement mode is
`self_report` throughout. To change that mode, create a versioned evidence
receipt with commercial training rights, teacher labels for each target
claim, person-disjoint validation and holdout, negative cases, calibration
rejection, and physical-device replay. Evaluate each posture family separately;
a success on Tadasana cannot automatically unlock Sarvangasana.

## Inclusion boundaries

Pregnancy, injury, and chronic conditions are addressed in general adaptation
notes in the first course. These notes offer support, smaller comfortable
ranges, rest, and questions to discuss with a qualified clinician. They never
prescribe rehabilitation or say an asana is safe for that person. Strong pain,
dizziness, faintness, unusual breathlessness, or new neurological symptoms
stop practice. Optional advanced poses may be explained but do not gate the
beginner-to-intermediate completion path.

## Final local course acceptance

The final content has **60 TR/EN lessons in 10 modules**, with 240 distinct
teaching steps. The [movement coverage matrix](HATHA-COURSE-SCOPE-2026-09-26.md)
records which named forms are standard-choice teaching, preparations or
knowledge-only. It also records source-fetch limitations. There is no claim
that this is the whole yoga tradition, a clinical course or a verified
intermediate qualification. Course SHA-256:
`77c91c0bd89914dc146cb4fe2455f23ca88117f5eea11c8e2963c14739e32f2c`.

- Full Flutter suite: **314 passed / 6 existing skipped**. Analyzer: no issues.
- Course content, real-file progress, all-60 backward prerequisite traversal,
  course/version isolation, broken journal-tail repair, parallel writes,
  deletion races, account switching and Turkish 375 px / 200% text flow pass.
- Wellness lint reads **622 English course fields**, with zero flags; its
  negative tests reject unsafe language in bilingual arrays and zero-scan
  regressions. This is copy checking, not clinical certification.
- Updated local store-copy tests: **10 passed**. Provider drafts were not changed.
- iPhone iOS 27 simulator: native course navigation, first-lesson practice,
  real path-provider file reread, shell recreation, other-owner isolation and
  deletion passed. Four actual Turkish course screenshots were reviewed.
- Android API 37 emulator: the same native flow passed on the final 60-lesson
  content. Flutter SDK image-surface screenshots stalled on two bounded
  attempts; the native flow was rerun without that screenshot tool and passed.
  An ADB screenshot confirms the final Home course card; this is not a
  completed screenshot-set acceptance.
- Native tests use their own temporary local scope, bypass provider auth, and
  remove only that scope in teardown. They do not prove physical-phone camera,
  individual suitability, signed-store packaging or live auth/deletion.

Logs/screenshots: `scratch/2026-09-26-motion-courses/lissom/`. No source video
was downloaded; AI demos, technical media review and physical-device release
acceptance remain open.
