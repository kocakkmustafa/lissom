import 'package:flutter/material.dart';

import 'hatha_course.dart';
import 'hatha_course_screen.dart' show hathaText;
import 'lissom_theme.dart';
import 'locale_text.dart';

class AshtangaEntry extends StatelessWidget {
  const AshtangaEntry({
    required this.course,
    required this.participation,
    required this.onOpen,
    super.key,
  });

  final HathaCourse course;
  final int participation;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => LissomCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hathaText(context, course.title),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(hathaText(context, course.intro)),
        const SizedBox(height: 8),
        Text(
          localeText(
            context,
            '$participation/${course.lessons.length} units with self-recorded participation',
            '${course.lessons.length} birimde $participation öz beyanlı katılım kaydı',
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onOpen,
          child: Text(
            localeText(
              context,
              'Open Ashtanga foundations',
              'Ashtanga temellerini aç',
            ),
          ),
        ),
      ],
    ),
  );
}
