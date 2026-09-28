import 'dart:async';

import 'package:flutter/material.dart';

import 'hatha_course.dart';
import 'hatha_knowledge_diagrams.dart';
import 'hatha_progress.dart';
import 'hatha_session_preparation.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';

String hathaText(BuildContext context, HathaText value) =>
    Localizations.localeOf(context).languageCode == 'tr' ? value.tr : value.en;

class HathaCourseScreen extends StatefulWidget {
  const HathaCourseScreen({
    required this.course,
    required this.initialProgress,
    required this.storeLoader,
    super.key,
  });

  static const Key progressKey = Key('hatha.progress');
  static const Key continueKey = Key('hatha.continue');

  final HathaCourse course;
  final HathaProgress initialProgress;
  final Future<HathaProgressStore> Function() storeLoader;

  @override
  State<HathaCourseScreen> createState() => _HathaCourseScreenState();
}

class _HathaCourseScreenState extends State<HathaCourseScreen>
    with WidgetsBindingObserver {
  late HathaProgress _progress = widget.initialProgress;
  final HathaSessionPreparation _preparation = HathaSessionPreparation();
  bool _opening = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _preparation.reset();
  }

  Set<String> get _practiced => _progress.practicedIn(widget.course);

  Future<void> _open(HathaLesson lesson) async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _loadFailed = false;
    });
    try {
      final HathaProgressStore store = await widget.storeLoader();
      if (!mounted) return;
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => HathaLessonScreen(
            course: widget.course,
            lesson: lesson,
            store: store,
            isRepeat: _practiced.contains(lesson.id),
            preparation: _preparation,
          ),
        ),
      );
      final HathaProgress updated = await store.read();
      if (mounted) setState(() => _progress = updated);
    } on Object {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Set<String> practiced = _practiced;
    final List<HathaLesson> lessons = widget.course.lessons;
    final HathaLesson? next = lessons.cast<HathaLesson?>().firstWhere(
      (HathaLesson? lesson) => !practiced.contains(lesson!.id),
      orElse: () => null,
    );
    return Scaffold(
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 36),
          children: <Widget>[
            LissomEyebrow(
              localeText(context, 'GUIDED COURSE', 'REHBERLİ KURS'),
            ),
            const SizedBox(height: 8),
            Text(
              hathaText(context, widget.course.title),
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              hathaText(context, widget.course.intro),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            LissomCard(
              key: HathaCourseScreen.progressKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    localeText(context, 'Your practice path', 'Çalışma yolun'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      '${practiced.length} of ${lessons.length} lessons practised',
                      '${lessons.length} dersten ${practiced.length} tanesi çalışıldı',
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  if (_progress.oldVersionCount(widget.course) > 0) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      localeText(
                        context,
                        'Earlier course-version records are kept separately.',
                        'Eski kurs sürümünün kayıtları ayrı saklanır.',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (_progress.unreadableRecords > 0) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      localeText(
                        context,
                        '${_progress.unreadableRecords} practice records could not be read.',
                        '${_progress.unreadableRecords} çalışma kaydı okunamadı.',
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (next != null)
              FilledButton.icon(
                key: HathaCourseScreen.continueKey,
                onPressed: _opening ? null : () => _open(next),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  localeText(
                    context,
                    'Continue: ${hathaText(context, next.title)}',
                    'Devam et: ${hathaText(context, next.title)}',
                  ),
                ),
              )
            else
              Text(
                localeText(
                  context,
                  'You reached the end. Return to any lesson for another practice.',
                  'Kursun sonuna geldin. Tekrar çalışmak için istediğin derse dön.',
                ),
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 24),
            if (_loadFailed)
              Text(
                localeText(
                  context,
                  'Your practice record could not be opened. Try again.',
                  'Çalışma kaydın açılamadı. Yeniden dene.',
                ),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            for (final HathaModule module in widget.course.modules) ...<Widget>[
              _ModuleSection(
                module: module,
                practiced: practiced,
                onOpen: _open,
              ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.module,
    required this.practiced,
    required this.onOpen,
  });

  final HathaModule module;
  final Set<String> practiced;
  final void Function(HathaLesson) onOpen;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int done = module.lessons
        .where((HathaLesson lesson) => practiced.contains(lesson.id))
        .length;
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  hathaText(context, module.title),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                '$done/${module.lessons.length}',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hathaText(context, module.outcome),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          for (final HathaLesson lesson in module.lessons)
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  practiced.contains(lesson.id)
                      ? Icons.check_circle_outline
                      : lesson.prerequisites.every(practiced.contains)
                      ? Icons.radio_button_unchecked
                      : Icons.lock_outline,
                  color: LissomColors.roseDeepHover,
                ),
                title: Text(hathaText(context, lesson.title)),
                subtitle: Text(
                  lesson.prerequisites.every(practiced.contains)
                      ? localeText(
                          context,
                          '${lesson.minutes} min · guided practice',
                          '${lesson.minutes} dk · rehberli çalışma',
                        )
                      : localeText(
                          context,
                          'Practice the earlier lesson first',
                          'Önce önceki dersi çalış',
                        ),
                ),
                onTap: lesson.prerequisites.every(practiced.contains)
                    ? () => onOpen(lesson)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class HathaLessonScreen extends StatefulWidget {
  const HathaLessonScreen({
    required this.course,
    required this.lesson,
    required this.store,
    required this.isRepeat,
    this.preparation,
    super.key,
  });

  static const Key practiceKey = Key('hatha.lesson.practiced');
  static const Key reflectionKey = Key('hatha.lesson.reflection');

  final HathaCourse course;
  final HathaLesson lesson;
  final HathaProgressStore store;
  final bool isRepeat;
  final HathaSessionPreparation? preparation;

  @override
  State<HathaLessonScreen> createState() => _HathaLessonScreenState();
}

class _HathaLessonScreenState extends State<HathaLessonScreen>
    with WidgetsBindingObserver {
  bool _saving = false;
  bool _saveFailed = false;
  bool _reflected = false;
  bool _readOnly = false;
  late final HathaSessionPreparation _preparation;
  Timer? _dateBoundary;

  bool get _requiresPreparation =>
      HathaSessionPreparation.requiredFor(widget.lesson.id);

  @override
  void initState() {
    super.initState();
    _preparation = widget.preparation ?? HathaSessionPreparation();
    WidgetsBinding.instance.addObserver(this);
    _scheduleDateBoundary();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dateBoundary?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _dateBoundary?.cancel();
    _preparation.reset();
    if (mounted) {
      setState(() {
        _readOnly = false;
        _reflected = false;
      });
    }
  }

  void _scheduleDateBoundary() {
    _dateBoundary?.cancel();
    if (!_requiresPreparation || !_preparation.acknowledged) return;
    _dateBoundary = Timer(
      _preparation.untilNextDay() + const Duration(milliseconds: 20),
      () {
        if (!mounted) return;
        if (_preparation.acknowledged) {
          _scheduleDateBoundary();
        } else {
          setState(() {
            _readOnly = false;
            _reflected = false;
          });
        }
      },
    );
  }

  Future<void> _save() async {
    if (_readOnly || (_requiresPreparation && !_preparation.acknowledged)) {
      return;
    }
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await widget.store.markPracticed(widget.course, widget.lesson.id);
      if (mounted) Navigator.of(context).pop(true);
    } on Object {
      if (mounted) setState(() => _saveFailed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final HathaLesson lesson = widget.lesson;
    final bool needsPreparation =
        _requiresPreparation && !_preparation.acknowledged && !_readOnly;
    return Scaffold(
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 36),
          children: <Widget>[
            LissomEyebrow(
              localeText(
                context,
                '${lesson.minutes} MIN · SELF-RECORDED',
                '${lesson.minutes} DK · ÖZ KAYIT',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hathaText(context, lesson.title),
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              hathaText(context, lesson.objective),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            if (needsPreparation)
              HathaSessionPreparationCard(
                onPrepared: () => setState(() {
                  _preparation.acknowledge();
                  _reflected = false;
                  _scheduleDateBoundary();
                }),
                onReadOnly: () => setState(() => _readOnly = true),
                onStop: () => Navigator.of(context).pop(false),
              ),
            if (!needsPreparation) ...<Widget>[
              if (_readOnly)
                LissomCard(
                  child: Text(
                    localeText(
                      context,
                      lesson.id == 'h59'
                          ? 'Written planning is open. Transition rehearsal stays closed until you prepare; this view cannot record practice.'
                          : 'Goal, knowledge diagrams and sources only. Physical steps stay closed until you prepare; this view cannot record practice.',
                      lesson.id == 'h59'
                          ? 'Yazılı planlama açık. Hazırlanana kadar geçiş provası kapalıdır; bu görünüm çalışma kaydedemez.'
                          : 'Yalnız hedef, bilgi şemaları ve kaynaklar. Hazırlanana kadar fiziksel adımlar kapalıdır; bu görünüm çalışma kaydedemez.',
                    ),
                  ),
                ),
              if (_readOnly)
                TextButton(
                  key: const Key('hatha.session.prepareToPractice'),
                  onPressed: () => setState(() => _readOnly = false),
                  child: Text(
                    localeText(
                      context,
                      'Prepare before practising',
                      'Çalışmadan önce hazırlan',
                    ),
                  ),
                ),
              if (_requiresPreparation && !_readOnly)
                TextButton(
                  key: const Key('hatha.session.restart'),
                  onPressed: () => setState(() {
                    _preparation.reset();
                    _reflected = false;
                    _dateBoundary?.cancel();
                  }),
                  child: Text(
                    localeText(
                      context,
                      'After a break · prepare again',
                      'Moladan sonra · yeniden hazırlan',
                    ),
                  ),
                ),
              if (!_readOnly)
                _LessonBlock(
                  title: localeText(context, 'Learn', 'Öğren'),
                  children: <Widget>[
                    for (int index = 0; index < lesson.steps.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${index + 1}. ${hathaText(context, lesson.steps[index])}',
                        ),
                      ),
                  ],
                ),
              if (_readOnly && lesson.id == 'h59')
                _LessonBlock(
                  title: localeText(
                    context,
                    'Written plan only',
                    'Yalnız yazılı plan',
                  ),
                  children: <Widget>[
                    for (int index = 0; index < 3; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '${index + 1}. ${hathaText(context, lesson.steps[index])}',
                        ),
                      ),
                    Text(hathaText(context, lesson.practice)),
                  ],
                ),
              if (HathaKnowledgeDiagrams.supports(lesson.id))
                HathaKnowledgeDiagrams(lessonId: lesson.id),
              if (!_readOnly)
                _LessonBlock(
                  title: localeText(context, 'Practice', 'Çalış'),
                  children: <Widget>[Text(hathaText(context, lesson.practice))],
                ),
              if (!_readOnly)
                _LessonBlock(
                  title: localeText(
                    context,
                    'Check yourself',
                    'Kendini değerlendir',
                  ),
                  children: <Widget>[
                    Text(hathaText(context, lesson.selfCheck)),
                  ],
                ),
              if (!_readOnly)
                _LessonBlock(
                  title: localeText(
                    context,
                    'Choose an easier path',
                    'Daha kolay yolu seç',
                  ),
                  children: <Widget>[
                    Text(hathaText(context, lesson.adaptation)),
                  ],
                ),
              _LessonBlock(
                title: localeText(context, 'When to stop', 'Ne zaman durmalı'),
                children: <Widget>[Text(hathaText(context, lesson.stopSignal))],
              ),
              LissomCard(
                child: Text(
                  localeText(
                    context,
                    'This lesson uses your own practice record. No camera posture or safety grade is made.',
                    'Bu derste kendi çalışma kaydın kullanılır. Kamera duruş veya güvenlik puanı vermez.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  localeText(context, 'Teaching sources', 'Öğretim kaynakları'),
                ),
                children: <Widget>[
                  for (final String sourceId in lesson.sourceIds)
                    ListTile(
                      title: Text(
                        Uri.parse(widget.course.sources[sourceId]!).host,
                      ),
                      subtitle: SelectableText(
                        widget.course.sources[sourceId]!,
                      ),
                    ),
                ],
              ),
              if (_saveFailed)
                Text(
                  localeText(
                    context,
                    'Your practice was not saved. Reopen the course if your account changed, or try again.',
                    'Çalışman kaydedilemedi. Hesabın değiştiyse kursu yeniden aç veya tekrar dene.',
                  ),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              if (!_readOnly)
                CheckboxListTile(
                  key: HathaLessonScreen.reflectionKey,
                  contentPadding: EdgeInsets.zero,
                  value: _reflected,
                  onChanged: _saving
                      ? null
                      : (bool? value) =>
                            setState(() => _reflected = value ?? false),
                  title: Text(
                    localeText(
                      context,
                      'I answered the self-check and want to record my practice.',
                      'Öz denetim sorusunu yanıtladım ve çalışmamı kaydetmek istiyorum.',
                    ),
                  ),
                ),
              if (!_readOnly) const SizedBox(height: 14),
              if (!_readOnly)
                FilledButton(
                  key: HathaLessonScreen.practiceKey,
                  onPressed: _saving || !_reflected ? null : _save,
                  child: Text(
                    widget.isRepeat
                        ? localeText(
                            context,
                            'Record another practice',
                            'Bir çalışma daha kaydet',
                          )
                        : localeText(
                            context,
                            'I practised this lesson',
                            'Bu dersi çalıştım',
                          ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LessonBlock extends StatelessWidget {
  const _LessonBlock({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(title),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}
