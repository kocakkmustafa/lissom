import 'dart:async';

import 'package:flutter/material.dart';

import 'hatha_course.dart';
import 'hatha_knowledge_diagrams.dart';
import 'hatha_progress.dart';
import 'hatha_session_preparation.dart';
import 'lesson_media.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';
import 'yoga_observation_status.dart';

String hathaText(BuildContext context, HathaText value) =>
    localeText(context, value.en, value.tr);

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
            previewOnly:
                widget.course.allowsLessonPreview &&
                !lesson.prerequisites.every(_practiced.contains),
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
                    localeTemplate(
                      context,
                      widget.course.recordsParticipation
                          ? '{done} participation records across {total} units; physical skill is not established.'
                          : '{done} of {total} lessons practised',
                      widget.course.recordsParticipation
                          ? '{total} birimde {done} katılım kaydı; fiziksel beceri gösterilmez.'
                          : '{total} dersten {done} tanesi çalışıldı',
                      <String, Object>{
                        'done': localizedInteger(context, practiced.length),
                        'total': localizedInteger(context, lessons.length),
                      },
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
                      localePlural(
                        context,
                        '{count} practice records could not be read.',
                        '{count} çalışma kaydı okunamadı.',
                        _progress.unreadableRecords,
                        englishOne: '{count} practice record could not be read.',
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
                  localeTemplate(
                    context,
                    'Continue: {title}',
                    'Devam et: {title}',
                    <String, Object>{'title': hathaText(context, next.title)},
                  ),
                ),
              )
            else
              Text(
                localeText(
                  context,
                  widget.course.allowsLessonPreview
                      ? 'Your lesson records reach the end. Review the independent route and later recall; records do not establish mastery.'
                      : 'You reached the end. Return to any lesson for another practice.',
                  widget.course.allowsLessonPreview
                      ? 'Ders kayıtların sona ulaştı. Bağımsız yolu ve sonraki hatırlamayı değerlendir; kayıtlar ustalık göstermez.'
                      : 'Kursun sonuna geldin. Tekrar çalışmak için istediğin derse dön.',
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
                allowPreview:
                    widget.course.allowsLessonPreview,
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
    this.allowPreview = false,
  });

  final HathaModule module;
  final Set<String> practiced;
  final void Function(HathaLesson) onOpen;
  final bool allowPreview;

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
                localeTemplate(
                  context,
                  '{done}/{total}',
                  '{done}/{total}',
                  <String, Object>{
                    'done': localizedInteger(context, done),
                    'total': localizedInteger(context, module.lessons.length),
                  },
                ),
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
                      ? localeTemplate(
                          context,
                          '{minutes} min · guided practice',
                          '{minutes} dk · rehberli çalışma',
                          <String, Object>{
                            'minutes': localizedInteger(context, lesson.minutes),
                          },
                        )
                      : localeText(
                          context,
                          allowPreview
                              ? 'Preview only · practise the earlier lesson first'
                              : 'Practice the earlier lesson first',
                          allowPreview
                              ? 'Yalnız inceleme · önce önceki dersi çalış'
                              : 'Önce önceki dersi çalış',
                        ),
                ),
                onTap:
                    allowPreview ||
                        lesson.prerequisites.every(practiced.contains)
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
    this.previewOnly = false,
    super.key,
  });

  static const Key practiceKey = Key('hatha.lesson.practiced');
  static const Key reflectionKey = Key('hatha.lesson.reflection');

  final HathaCourse course;
  final HathaLesson lesson;
  final HathaProgressStore store;
  final bool isRepeat;
  final HathaSessionPreparation? preparation;
  final bool previewOnly;

  @override
  State<HathaLessonScreen> createState() => _HathaLessonScreenState();
}

class _HathaLessonScreenState extends State<HathaLessonScreen>
    with WidgetsBindingObserver {
  bool _saving = false;
  bool _saveFailed = false;
  bool _reflected = false;
  int _answerEpoch = 0;
  late bool _readOnly = widget.previewOnly;

  bool get _chairOffice => widget.course.allowsLessonPreview;
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
        _readOnly = widget.previewOnly;
        _reflected = false;
        _answerEpoch++;
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
            _readOnly = widget.previewOnly;
            _reflected = false;
            _answerEpoch++;
          });
        }
      },
    );
  }

  Future<void> _save() async {
    if (_saving ||
        !_reflected ||
        widget.previewOnly ||
        _readOnly ||
        (_requiresPreparation && !_preparation.acknowledged)) {
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
              localeTemplate(
                context,
                '{minutes} MIN · SELF-RECORDED',
                '{minutes} DK · ÖZ KAYIT',
                <String, Object>{
                  'minutes': localizedInteger(context, lesson.minutes),
                },
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
                chairOnly: widget.course.id == 'lissom.chair-office.beginner',
                vinyasaOnly: widget.course.id == 'lissom.vinyasa.supported-standing.beginner',
                yinOnly: widget.course.id == 'lissom.yin.supported.beginner',
                ashtangaOnly: widget.course.isAshtanga,
                onPrepared: () => setState(() {
                  _preparation.acknowledge();
                  _reflected = false;
                  _answerEpoch++;
                  _scheduleDateBoundary();
                }),
                onReadOnly: () => setState(() => _readOnly = true),
                onStop: () => Navigator.of(context).pop(false),
              ),
            YogaObservationStatusCard(
              key: const Key('yoga.lesson.availability'),
              course: widget.course,
              lessonId: lesson.id,
            ),
            const SizedBox(height: 12),
            if (!needsPreparation) ...<Widget>[
              if (_readOnly)
                LissomCard(
                  child: Text(
                    localeText(
                      context,
                      _chairOffice
                          ? 'Preview: goal, understanding questions and sources. Physical steps and practice recording stay closed; practise prerequisites and prepare before movement.'
                          : lesson.id == 'h59'
                          ? 'Written planning is open. Transition rehearsal stays closed until you prepare; this view cannot record practice.'
                          : 'Goal, knowledge diagrams and sources only. Physical steps stay closed until you prepare; this view cannot record practice.',
                      _chairOffice
                          ? 'İnceleme: hedef, anlama soruları ve kaynaklar. Fiziksel adımlar ve çalışma kaydı kapalıdır; hareketten önce ön dersleri çalış ve hazırlan.'
                          : lesson.id == 'h59'
                          ? 'Yazılı planlama açık. Hazırlanana kadar geçiş provası kapalıdır; bu görünüm çalışma kaydedemez.'
                          : 'Yalnız hedef, bilgi şemaları ve kaynaklar. Hazırlanana kadar fiziksel adımlar kapalıdır; bu görünüm çalışma kaydedemez.',
                    ),
                  ),
                ),
              if (_readOnly && !widget.previewOnly)
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
                    _answerEpoch++;
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
                          localeTemplate(
                            context,
                            '{number}. {text}',
                            '{number}. {text}',
                            <String, Object>{
                              'number': localizedInteger(context, index + 1),
                              'text': hathaText(context, lesson.steps[index]),
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              if (!_readOnly && !_chairOffice)
                LessonMediaSlot.empty(
                  key: const Key('hatha.lesson.media'),
                  course: widget.course,
                  lessonId: lesson.id,
                  locale: Localizations.localeOf(context).languageCode,
                ),
              if (!_readOnly && _chairOffice)
                LissomCard(
                  key: const Key('chairOffice.lesson.mediaGap'),
                  child: Text(
                    localeText(
                      context,
                      'Written guidance only. Instructor demonstration and physical teaching acceptance are still pending.',
                      'Yalnız yazılı rehber. Eğitmen gösterimi ve fiziksel öğretim kabulü bekliyor.',
                    ),
                  ),
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
                          localeTemplate(
                            context,
                            '{number}. {text}',
                            '{number}. {text}',
                            <String, Object>{
                              'number': localizedInteger(context, index + 1),
                              'text': hathaText(context, lesson.steps[index]),
                            },
                          ),
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
              if (!_readOnly || _chairOffice)
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
              if (lesson.answerKey case final HathaText answer)
                KeyedSubtree(
                  key: ValueKey<int>(_answerEpoch),
                  child: ExpansionTile(
                    key: Key('course.answer.${lesson.id}'),
                    initiallyExpanded: false,
                    title: Text(
                      localeText(
                        context,
                        'Reveal after writing your answer',
                        'Yanıtını yazdıktan sonra aç',
                      ),
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(hathaText(context, answer)),
                      ),
                    ],
                  ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      localeText(
                        context,
                        'Sources guide the named teaching detail; they do not validate this whole lesson, personal safety or a camera verdict.',
                        'Kaynaklar belirtilen öğretim ayrıntısını destekler; tüm dersi, kişisel güvenliği veya kamera kararını doğrulamaz.',
                      ),
                    ),
                  ),
                  for (final String sourceId in lesson.sourceIds)
                    ListTile(
                      title: Text(
                        Uri.parse(widget.course.sources[sourceId]!).host,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SelectableText(widget.course.sources[sourceId]!),
                          if (widget.course.sourceScopes[sourceId]
                              case final HathaSourceScope scope) ...<Widget>[
                            Text(
                              '${localeText(context, 'Supports only:', 'Yalnız destekler:')} '
                              '${hathaText(context, scope.supports)}',
                              key: Key('hatha.sourceScope.$sourceId'),
                            ),
                            Text(
                              '${localeText(context, 'Does not establish:', 'Kanıtlamaz:')} '
                              '${hathaText(context, scope.doesNotSupport)}',
                              key: Key('hatha.sourceLimit.$sourceId'),
                            ),
                          ],
                        ],
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
                      widget.course.recordsParticipation ? 'I answered the self-check and want to record participation; this is not observed physical skill.' : 'I answered the self-check and want to record my practice.',
                      widget.course.recordsParticipation ? 'Öz denetimi yanıtladım ve katılımı kaydetmek istiyorum; bu gözlenmiş fiziksel beceri değildir.' : 'Öz denetim sorusunu yanıtladım ve çalışmamı kaydetmek istiyorum.',
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
                            widget.course.recordsParticipation ? 'Record another participation' : 'Record another practice',
                            widget.course.recordsParticipation ? 'Bir katılım daha kaydet' : 'Bir çalışma daha kaydet',
                          )
                        : localeText(
                            context,
                            lesson.id == 'c11' ? 'Record my written planning' : (lesson.id == 'v01' || lesson.id == 'v07' || lesson.id == 'y01' || widget.course.isWrittenStudy(lesson.id))
                                ? 'Record my written study'
                                : widget.course.recordsParticipation ? 'Record my participation' : 'I practised this lesson',
                            lesson.id == 'c11' ? 'Yazılı planlamamı kaydet' : (lesson.id == 'v01' || lesson.id == 'v07' || lesson.id == 'y01' || widget.course.isWrittenStudy(lesson.id))
                                ? 'Yazılı çalışmamı kaydet'
                                : widget.course.recordsParticipation ? 'Katılımımı kaydet' : 'Bu dersi çalıştım',
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
