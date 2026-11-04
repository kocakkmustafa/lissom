import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';

import '../lissom_theme.dart';
import '../locale_text.dart';
import 'camera_catalog_copy.dart';
import 'camera_coach_screen.dart';
import 'coach_speaker.dart';
import 'mirror_camera.dart';
import 'mirror_screen.dart';

/// The camera part of a lesson (trial). Shown only while the camera trial
/// flag is open; otherwise the lesson keeps its existing status card.
class LessonCameraSection extends StatefulWidget {
  const LessonCameraSection({
    required this.courseId,
    required this.lessonId,
    required this.canStart,
    this.catalogLoader,
    this.sourceFactory,
    this.speaker,
    this.mirrorCamera,
    super.key,
  });

  static const Key sectionKey = Key('camera.lesson.section');

  final String courseId;
  final String lessonId;

  /// False until the lesson's physical steps are open (preparation done).
  final bool canStart;
  final Future<CameraPoseCatalog> Function()? catalogLoader;
  final PoseSource Function()? sourceFactory;
  final CoachSpeaker? speaker;
  final MirrorCamera Function()? mirrorCamera;

  @override
  State<LessonCameraSection> createState() => _LessonCameraSectionState();
}

class _LessonCameraSectionState extends State<LessonCameraSection> {
  late final Future<CameraPoseCatalog> _catalog =
      (widget.catalogLoader ?? loadCameraPoseCatalog)();

  @override
  Widget build(BuildContext context) => FutureBuilder<CameraPoseCatalog>(
    future: _catalog,
    builder: (BuildContext context, AsyncSnapshot<CameraPoseCatalog> snap) {
      final ThemeData theme = Theme.of(context);
      final CameraPoseCatalog? cat = snap.data;
      final List<CameraPoseSpec> poses = cat == null
          ? const <CameraPoseSpec>[]
          : cat.posesForLesson(widget.courseId, widget.lessonId);
      final List<Widget> body = <Widget>[
        LissomEyebrow(
          localeText(
            context,
            'Camera coaching · trial',
            'Kamera koçluğu · deneme',
          ),
        ),
        const SizedBox(height: 8),
      ];
      if (snap.connectionState != ConnectionState.done) {
        body.add(Text(localeText(context, 'Loading…', 'Yükleniyor…')));
      } else if (cat == null) {
        body.add(
          Text(
            localeText(
              context,
              'Camera coaching could not load. Your lesson remains available.',
              'Kamera koçluğu yüklenemedi. Dersine devam edebilirsin.',
            ),
            key: const Key('camera.lesson.failed'),
          ),
        );
      } else if (poses.isEmpty) {
        body.add(
          Text(
            localeText(
              context,
              'The camera does not assess this lesson.',
              'Bu dersi kamera değerlendirmiyor.',
            ),
            key: const Key('camera.lesson.notAssessed'),
          ),
        );
      } else {
        body.add(
          Text(
            localeText(
              context,
              'Optional. The camera checks from the side whether you are in the pose, counts the hold and says one correction at a time. It is a trial: it can be wrong, and it gives no score.',
              'İsteğe bağlı. Kamera yandan duruşta olup olmadığını kontrol eder, tutuşu sayar ve bir seferde tek düzeltme söyler. Bu bir denemedir: yanılabilir ve puan vermez.',
            ),
          ),
        );
        body.add(const SizedBox(height: 10));
        if (!widget.canStart) {
          body.add(
            Text(
              localeText(
                context,
                'Opens after you prepare for practice.',
                'Çalışmaya hazırlandıktan sonra açılır.',
              ),
              key: const Key('camera.lesson.locked'),
              style: theme.textTheme.bodySmall,
            ),
          );
        }
        for (final CameraPoseSpec p in poses) {
          body.add(
            OutlinedButton(
              key: Key('camera.lesson.start.${p.id}'),
              onPressed: widget.canStart
                  ? () => unawaited(
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => CameraCoachScreen(
                            catalog: cat,
                            pose: p,
                            sourceFactory: widget.sourceFactory,
                            speaker: widget.speaker,
                          ),
                        ),
                      ),
                    )
                  : null,
              child: Text(
                localeTemplate(
                  context,
                  'Practise with the camera: {pose}',
                  'Kamerayla çalış: {pose}',
                  <String, Object>{
                    'pose': cameraCatalogText(
                      context,
                      p.nameEnglish,
                      p.nameTurkish,
                    ),
                  },
                ),
              ),
            ),
          );
        }
        body.add(
          TextButton(
            key: const Key('camera.lesson.mirror'),
            onPressed: widget.canStart
                ? () => unawaited(
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext c) => MirrorScreen(
                          title: localeText(c, 'Mirror', 'Ayna'),
                          camera: widget.mirrorCamera,
                        ),
                      ),
                    ),
                  )
                : null,
            child: Text(
              localeText(
                context,
                'Open the mirror (front camera)',
                'Aynayı aç (ön kamera)',
              ),
            ),
          ),
        );
      }
      return Semantics(
        container: true,
        child: LissomCard(
          key: LessonCameraSection.sectionKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: body,
          ),
        ),
      );
    },
  );
}
