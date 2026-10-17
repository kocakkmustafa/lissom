import 'package:flutter/material.dart';

import 'hatha_course.dart';
import 'hatha_course_screen.dart';
import 'hatha_progress.dart';
import 'locale_text.dart';

/// Shared course entry: read progress before opening, with visible retry.
class CourseOpenButton extends StatefulWidget {
  const CourseOpenButton({
    required this.course,
    required this.storeLoader,
    required this.label,
    super.key,
  });

  final HathaCourse course;
  final Future<HathaProgressStore> Function()? storeLoader;
  final String label;

  @override
  State<CourseOpenButton> createState() => CourseOpenButtonState();
}

class CourseOpenButtonState extends State<CourseOpenButton> {
  bool _opening = false;
  bool _failed = false;

  Future<void> _open() async {
    final loader = widget.storeLoader;
    if (_opening || loader == null) return;
    setState(() {
      _opening = true;
      _failed = false;
    });
    try {
      final store = await loader();
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      final progress = await store.read();
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => HathaCourseScreen(
            course: widget.course,
            initialProgress: progress,
            storeLoader: loader,
          ),
        ),
      );
    } on Object {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FilledButton(
        onPressed: _opening || widget.storeLoader == null ? null : _open,
        child: Text(widget.label),
      ),
      if (_failed) ...[
        const SizedBox(height: 8),
        Text(
          localeText(
            context,
            'Your practice record could not be opened. Tap the course button to try again.',
            'Çalışma kaydın açılamadı. Yeniden denemek için kurs düğmesine dokun.',
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
    ],
  );
}
