import 'dart:convert';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'hatha_course.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';

const kYogaTasksAsset = 'config/yoga/tasks.v1.json';
const kYogaTasksSha256 =
    '7e3d5623bc55e03abe282b8c5ebcd0a62cb405cba565b95c149a41404571c705';

/// Hash-verified local configuration. No model/provider activation or capture.
Future<YogaTaskCatalog> loadYogaTaskCatalog({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final data = await assets.load(kYogaTasksAsset);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (sha256.convert(bytes).toString() != kYogaTasksSha256) {
    throw const FormatException('Yoga task catalog identity mismatch');
  }
  final catalog = YogaTaskCatalog.parse(utf8.decode(bytes));
  final courseData = await assets.load('config/courses/hatha.v1.json');
  final courseBytes = courseData.buffer.asUint8List(
    courseData.offsetInBytes,
    courseData.lengthInBytes,
  );
  final courseSha = sha256.convert(courseBytes).toString();
  if (catalog.tasks.any((task) => task.courseSha256 != courseSha)) {
    throw const FormatException('Yoga task course identity mismatch');
  }
  return catalog;
}

/// Availability only. There are no camera controls or replay injection here.
class YogaObservationStatusCard extends StatefulWidget {
  const YogaObservationStatusCard({
    required this.course,
    required this.lessonId,
    this.catalogLoader,
    super.key,
  });

  final HathaCourse course;
  final String lessonId;
  final Future<YogaTaskCatalog> Function()? catalogLoader;

  @override
  State<YogaObservationStatusCard> createState() =>
      _YogaObservationStatusCardState();
}

class _YogaObservationStatusCardState extends State<YogaObservationStatusCard> {
  late Future<YogaTaskCatalog> _catalog = _load();
  Future<YogaTaskCatalog> _load() =>
      (widget.catalogLoader ?? loadYogaTaskCatalog)();

  @override
  void didUpdateWidget(covariant YogaObservationStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course != widget.course ||
        oldWidget.lessonId != widget.lessonId ||
        oldWidget.catalogLoader != widget.catalogLoader) {
      _catalog = _load();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<YogaTaskCatalog>(
    future: _catalog,
    builder: (context, snapshot) {
      final loaded = snapshot.connectionState == ConnectionState.done;
      final failed = loaded && (snapshot.hasError || snapshot.data == null);
      final pilot =
          loaded &&
          !failed &&
          snapshot.data!.tasks.any(
            (task) =>
                task.courseId == widget.course.id &&
                task.courseVersion == widget.course.version &&
                task.lessonId == widget.lessonId,
          );
      final text = !loaded
          ? localeText(
              context,
              'Checking camera observation availability…',
              'Kamera gözlemi durumu kontrol ediliyor…',
            )
          : failed
          ? localeText(
              context,
              'Camera observation availability could not be checked. Your lesson remains available.',
              'Kamera gözlemi durumu kontrol edilemedi. Dersine devam edebilirsin.',
            )
          : pilot
          ? localeText(
              context,
              'Calibration required. Camera observation for this lesson is not available yet.',
              'Kalibrasyon gerekli. Bu dersin kamera gözlemi henüz kullanılamıyor.',
            )
          : localeText(
              context,
              'Camera observation is not supported for this lesson.',
              'Bu ders için kamera gözlemi desteklenmiyor.',
            );
      return Semantics(
        container: true,
        liveRegion: true,
        child: LissomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localeText(context, 'Camera observation', 'Kamera gözlemi'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(text, key: const Key('yoga.observation.status')),
              const SizedBox(height: 6),
              Text(
                localeText(
                  context,
                  'Practice remains self-recorded; it is not a posture grade.',
                  'Çalışma kaydı kendi beyanındır; poz değerlendirmesi değildir.',
                ),
              ),
              if (failed)
                TextButton(
                  key: const Key('yoga.observation.retry'),
                  onPressed: () => setState(() {
                    _catalog = _load();
                  }),
                  child: Text(localeText(context, 'Try again', 'Yeniden dene')),
                ),
            ],
          ),
        ),
      );
    },
  );
}
