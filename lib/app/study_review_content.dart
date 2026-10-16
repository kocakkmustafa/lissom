// Authored reading/recall activities derived from the source references below.
// These do not promote physical instruction, media rights, scoring or mastery.
final class StudyText {
  const StudyText(this.en, this.tr);
  final String en, tr;
}

final class RecallLesson {
  const RecallLesson({
    required this.id,
    required this.title,
    required this.teaching,
    required this.question,
    required this.answer,
  });
  final String id;
  final StudyText title, teaching, question, answer;
}

final class StudyArea {
  const StudyArea({
    required this.id,
    required this.title,
    required this.boundary,
    required this.sourceRefs,
    required this.lessons,
  });
  final String id;
  final StudyText title, boundary;
  final List<String> sourceRefs;
  final List<RecallLesson> lessons;
}

const List<StudyArea> studyAreas = <StudyArea>[
  StudyArea(
    id: "hatha",
    title: StudyText("Hatha", "Hatha"),
    boundary: StudyText(
      "Reading and written recall only; no movement is needed. Demonstration, personal suitability and physical technique require separate review.",
      "Yalnız okuma ve yazılı hatırlama; hareket gerekmez. Gösterim, kişisel uygunluk ve fiziksel teknik ayrı inceleme gerektirir.",
    ),
    sourceRefs: <String>[
      "config/courses/hatha.v1.json#h02",
      "config/courses/hatha.v1.json#h34",
    ],
    lessons: <RecallLesson>[
      RecallLesson(
        id: "hatha.1",
        title: StudyText(
          "Natural breath is not a target score",
          "Doğal nefes hedef puan değildir",
        ),
        teaching: StudyText(
          "The foundation asks for ordinary breathing rather than forcing a count, hold or ideal depth. A written breath description is not a camera measurement of breath.",
          "Temel, sayıyı, tutmayı veya ideal derinliği zorlamak yerine olağan solunumu ister. Yazılı nefes açıklaması nefesin kamera ölçümü değildir.",
        ),
        question: StudyText(
          "Can a completed reading answer establish that breathing was measured?",
          "Tamamlanmış okuma cevabı nefesin ölçüldüğünü kanıtlar mı?",
        ),
        answer: StudyText(
          "No. Report the written understanding only. Leave breath measurement unavailable.",
          "Hayır. Yalnız yazılı anlamayı bildir. Nefes ölçümünü kullanılamaz bırak.",
        ),
      ),
      RecallLesson(
        id: "hatha.2",
        title: StudyText(
          "A station map is not a full flow",
          "Durak haritası tam akış değildir",
        ),
        teaching: StudyText(
          "h34 arranges previously taught shapes as separate stations. It names mountain, supported fold, tabletop, small cobra and rest; the map is not a required full Surya Namaskara.",
          "h34 önceden öğretilmiş şekilleri ayrı duraklar olarak düzenler. Dağ, destekli katlanma, masa, küçük kobra ve dinlenmeyi adlandırır; harita zorunlu tam Surya Namaskara değildir.",
        ),
        question: StudyText(
          "An unfamiliar floor station appears in an external flow. Can it be silently inserted into this map?",
          "Dış akışta tanıdık olmayan yer durağı var. Bu haritaya sessizce eklenebilir mi?",
        ),
        answer: StudyText(
          "No. Mark it untaught. Explain the selected route and its exits on paper before considering separate teaching.",
          "Hayır. Öğretilmedi işaretle. Ayrı öğretimi düşünmeden seçilen yolu ve çıkışları kâğıtta açıkla.",
        ),
      ),
    ],
  ),
  StudyArea(
    id: "chair",
    title: StudyText("Chair and office", "Sandalye ve ofis"),
    boundary: StudyText(
      "Reading and written recall only; no movement is needed. Demonstration, personal suitability and physical technique require separate review.",
      "Yalnız okuma ve yazılı hatırlama; hareket gerekmez. Gösterim, kişisel uygunluk ve fiziksel teknik ayrı inceleme gerektirir.",
    ),
    sourceRefs: <String>[
      "config/courses/chair-office.v1.json#c01",
      "config/courses/chair-office.v1.json#c09",
    ],
    lessons: <RecallLesson>[
      RecallLesson(
        id: "chair.1",
        title: StudyText("The chair is a prerequisite", "Sandalye ön koşuldur"),
        teaching: StudyText(
          "The pathway requires a suitable stable chair and a fresh setup check. An office label does not make every wheeled, folding or unstable seat suitable.",
          "Yol uygun sabit sandalye ve yeni kurulum kontrolü gerektirir. Ofis etiketi her tekerlekli, katlanır veya dengesiz oturağı uygun yapmaz.",
        ),
        question: StudyText(
          "The chair’s stability is unknown. Does reading the lesson remove that uncertainty?",
          "Sandalyenin sabitliği bilinmiyor. Dersi okumak bu belirsizliği giderir mi?",
        ),
        answer: StudyText(
          "No. Keep the setup unverified and use the written task. Do not approve the chair from a completion tick.",
          "Hayır. Kurulumu doğrulanmadı bırak ve yazılı görevi kullan. Bitirme işaretinden sandalyeyi onaylama.",
        ),
      ),
      RecallLesson(
        id: "chair.2",
        title: StudyText(
          "An interruption resets the setup",
          "Kesinti kurulumu yeniler",
        ),
        teaching: StudyText(
          "After an office interruption the route calls for a fresh setup, rather than automatically continuing an earlier position. Rest and a shorter route remain named choices.",
          "Ofis kesintisinden sonra yol önceki konumdan otomatik devam yerine yeni kurulum ister. Dinlenme ve kısa yol adlandırılmış seçeneklerdir.",
        ),
        question: StudyText(
          "The workspace changed during a call. What should the written plan revisit?",
          "Arama sırasında çalışma alanı değişti. Yazılı plan neye dönmeli?",
        ),
        answer: StudyText(
          "Chair, space and the selected route. The earlier setup record is not evidence that the new setup is unchanged.",
          "Sandalye, alan ve seçilen yol. Önceki kurulum kaydı yeni kurulumun değişmediğine kanıt değildir.",
        ),
      ),
    ],
  ),
  StudyArea(
    id: "vinyasa",
    title: StudyText("Vinyasa", "Vinyasa"),
    boundary: StudyText(
      "Reading and written recall only; no movement is needed. Demonstration, personal suitability and physical technique require separate review.",
      "Yalnız okuma ve yazılı hatırlama; hareket gerekmez. Gösterim, kişisel uygunluk ve fiziksel teknik ayrı inceleme gerektirir.",
    ),
    sourceRefs: <String>[
      "config/courses/vinyasa-standing.v1.json#v01",
      "config/courses/vinyasa-standing.v1.json#v07",
    ],
    lessons: <RecallLesson>[
      RecallLesson(
        id: "vinyasa.1",
        title: StudyText("Choose a taught route", "Öğretilmiş yol seç"),
        teaching: StudyText(
          "The beginner pathway is supported standing Vinyasa. Its route choice does not automatically include an unfamiliar floor branch or every posture from a full-flow video.",
          "Başlangıç yolu destekli ayakta Vinyasa’dır. Yol seçimi tanıdık olmayan yer dalını veya tam akış videosunun her duruşunu otomatik içermez.",
        ),
        question: StudyText(
          "Can recognizing a floor branch be reported as performing it?",
          "Yer dalını tanımak uygulamak diye bildirilebilir mi?",
        ),
        answer: StudyText(
          "No. Keep recognition and physical execution separate. Name the untaught transition as a question.",
          "Hayır. Tanımayla fiziksel uygulamayı ayır. Öğretilmemiş geçişi soru olarak adlandır.",
        ),
      ),
      RecallLesson(
        id: "vinyasa.2",
        title: StudyText("Correction and stopping", "Düzeltme ve durma"),
        teaching: StudyText(
          "The course distinguishes revising an understandable route error from choosing to stop. A stop signal calls for ending the activity, rather than repeating it until it appears successful.",
          "Anlaşılır yol hatasını düzeltmekle durmayı seçmek farklıdır. Durma sinyali, çalışma başarılı görünene kadar tekrarlamak yerine onu bitirmeyi gerektirir.",
        ),
        question: StudyText(
          "The record says stopped because of discomfort. Should the next plan demand another attempt?",
          "Kayıt rahatsızlık nedeniyle durdum diyor. Sonraki plan yeni deneme istemeli mi?",
        ),
        answer: StudyText(
          "No. End the activity and keep the stop visible. A written answer cannot establish personal suitability.",
          "Hayır. Çalışmayı bitir ve durmayı görünür tut. Yazılı cevap kişisel uygunluk kuramaz.",
        ),
      ),
    ],
  ),
  StudyArea(
    id: "yin",
    title: StudyText("Yin", "Yin"),
    boundary: StudyText(
      "Reading and written recall only; no movement is needed. Demonstration, personal suitability and physical technique require separate review.",
      "Yalnız okuma ve yazılı hatırlama; hareket gerekmez. Gösterim, kişisel uygunluk ve fiziksel teknik ayrı inceleme gerektirir.",
    ),
    sourceRefs: <String>[
      "config/courses/yin-supported.v1.json#y01",
      "config/courses/yin-supported.v1.json#y06",
    ],
    lessons: <RecallLesson>[
      RecallLesson(
        id: "yin.1",
        title: StudyText(
          "Adaptation and substitution",
          "Uyarlama ve yerine koyma",
        ),
        teaching: StudyText(
          "This path uses explicitly supported versions of selected Yin floor shapes. Neutral rest and chair observation are alternatives, not evidence of the same Yin movement skill.",
          "Bu yol seçilen Yin yer şekillerinin açık destekli sürümlerini kullanır. Nötr dinlenme ve sandalye gözlemi alternatiflerdir; aynı Yin hareket becerisinin kanıtı değildir.",
        ),
        question: StudyText(
          "If you only observe from a chair, how should the result be labelled?",
          "Yalnız sandalyeden gözlersen sonuç nasıl adlandırılmalı?",
        ),
        answer: StudyText(
          "Chair observation or written understanding. Leave the floor shape physically unattempted.",
          "Sandalye gözlemi veya yazılı anlama. Yer şeklini fiziksel olarak denenmedi bırak.",
        ),
      ),
      RecallLesson(
        id: "yin.2",
        title: StudyText("Time is not acceptance", "Süre kabul değildir"),
        teaching: StudyText(
          "Waiting without force and leaving early are learning choices. Unit minutes organize study; they do not certify a hold dose, tissue change or a health outcome.",
          "Zorlamadan beklemek ve erken çıkmak öğrenme seçenekleridir. Birim dakikaları çalışmayı düzenler; tutuş dozu, doku değişimi veya sağlık sonucunu onaylamaz.",
        ),
        question: StudyText(
          "Can a timer alone establish successful Yin technique?",
          "Zamanlayıcı tek başına başarılı Yin tekniği kurabilir mi?",
        ),
        answer: StudyText(
          "No. Name the chosen variant and the limits of the observation. Elapsed time is not a technique or suitability judgement.",
          "Hayır. Seçilen sürümü ve gözlemin sınırlarını adlandır. Geçen süre teknik veya uygunluk hükmü değildir.",
        ),
      ),
    ],
  ),
  StudyArea(
    id: "ashtanga",
    title: StudyText(
      "Ashtanga: reading preparation",
      "Ashtanga: okuma hazırlığı",
    ),
    boundary: StudyText(
      "This reading bridge complements the separate Ashtanga beginner foundations course. Full traditional-series teaching, demonstrations and individual physical suitability remain separate. No practice of an untaught station follows from this page.",
      "Bu okuma köprüsü ayrı Ashtanga başlangıç temelleri kursunu tamamlar. Tam geleneksel seri öğretimi, gösterimler ve bireysel fiziksel uygunluk ayrıdır. Bu sayfadan öğretilmemiş durakta pratik izni çıkmaz.",
    ),
    sourceRefs: <String>[
      "config/courses/hatha.v1.json#h34",
      "config/courses/hatha.v1.json#h49",
      "config/courses/ashtanga-foundations.v1.json#a01",
      "config/courses/ashtanga-foundations.v1.json#a08",
      "config/ia/library.v1.json",
    ],
    lessons: <RecallLesson>[
      RecallLesson(
        id: "ashtanga.1",
        title: StudyText(
          "Adapted Sun A is not the primary series",
          "Uyarlanmış Güneşe Selam A temel seri değildir",
        ),
        teaching: StudyText(
          "h49 explicitly labels its paused, adapted Sun A as a learning sequence. It excludes jumps and low push-ups. A Hatha map or adapted Sun A cannot be renamed a complete traditional Ashtanga primary series.",
          "h49 duraklı, uyarlanmış Güneşe Selam A’yı açıkça öğrenme dizisi olarak adlandırır. Sıçrama ve alçak şınav içermez. Hatha haritası veya uyarlanmış Güneşe Selam A tam geleneksel Ashtanga temel serisi diye yeniden adlandırılamaz.",
        ),
        question: StudyText(
          "A learner remembers h49. Write exactly what that establishes and what stays open.",
          "Öğrenen h49’u hatırlıyor. Bunun tam neyi kurduğunu ve neyin açık kaldığını yaz.",
        ),
        answer: StudyText(
          "Written recall of the adapted h49 sequence. Traditional sequence completeness, breathing/movement integration, demonstration and physical execution are not established.",
          "Uyarlanmış h49 dizisinin yazılı hatırlaması. Geleneksel dizinin tamlığı, nefes/hareket bütünleşmesi, gösterim ve fiziksel uygulama kurulmaz.",
        ),
      ),
      RecallLesson(
        id: "ashtanga.2",
        title: StudyText(
          "Build a teaching question map",
          "Öğretim soru haritası kur",
        ),
        teaching: StudyText(
          "Divide a route on paper into named stations, entries and exits. Label each as taught, uncertain or untaught. An unfamiliar transition belongs in the question list, not silently in a practice route.",
          "Kâğıtta yolu adlandırılmış durak, giriş ve çıkışlara ayır. Her birini öğretilmiş, belirsiz veya öğretilmemiş işaretle. Tanıdık olmayan geçiş sessizce pratik yoluna değil soru listesine girer.",
        ),
        question: StudyText(
          "You recognize two endpoint shapes but cannot explain the transfer between them. How should the map record the transfer?",
          "İki uç şekli tanıyor ama aralarındaki geçişi açıklayamıyorsun. Harita geçişi nasıl kaydetmeli?",
        ),
        answer: StudyText(
          "Uncertain/untaught transfer. Ask for its instruction, relevant adaptations, demonstration and personal suitability before adding physical practice. Endpoint names alone are insufficient.",
          "Belirsiz/öğretilmemiş geçiş. Fiziksel pratiğe eklemeden öğretimini, ilgili uyarlamaları, gösterimi ve kişisel uygunluğu sor. Uçların adları tek başına yeterli değildir.",
        ),
      ),
    ],
  ),
];
