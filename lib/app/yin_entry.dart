import 'package:flutter/material.dart';
import 'hatha_course.dart';
import 'hatha_course_screen.dart' show hathaText;
import 'locale_text.dart';
class YinEntry extends StatelessWidget {
  const YinEntry({required this.course, required this.onOpen, this.onOpenFoundations, super.key});
  final HathaCourse course;
  final VoidCallback? onOpen;
  final VoidCallback? onOpenFoundations;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(20), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(hathaText(context, course.title)),
        Text(hathaText(context, course.intro)),
        FilledButton(onPressed: onOpen, child: Text(localeText(context,
          'Open supported Yin', 'Destekli Yin yolunu aç'))),
        TextButton(onPressed: onOpenFoundations, child: Text(localeText(context,
          'Open taught Hatha foundations: h01/h02/h04/h19/h20/h23/h29/h35',
          'Öğretilen Hatha temellerini aç: h01/h02/h04/h19/h20/h23/h29/h35'))),
      ])));
}
