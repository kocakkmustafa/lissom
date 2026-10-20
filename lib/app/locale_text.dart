import 'package:flutter/widgets.dart';

import 'lissom_locales.dart';
import 'lissom_localizations.dart';

export 'lissom_localizations.dart'
    show
        localizedConfigNumber,
        localizedDate,
        localizedDecimal,
        localizedInteger;

/// Inline EN/TR copy remains authoritative outside the reviewed exact-key
/// clarifications below. Other locales use the same immutable source keys.
/// A missing catalog falls back to clarified English for these reviewed keys.
String localeText(BuildContext context, String english, String turkish) {
  final String tag = canonicalLocaleTag(Localizations.localeOf(context));
  final clarified = _reviewedSourceDisplayCopy[english];
  final String safeEnglish = clarified?.english ?? english;
  if (tag == 'tr') return clarified?.turkish ?? turkish;
  if (tag == 'en') return safeEnglish;
  return LissomLocalizations.maybeOf(context)?.lookup(english) ?? safeEnglish;
}

// Reviewed display corrections preserve the pinned course JSON, source keys,
// IDs and progress identity. They clarify teaching/copy meaning; they do not
// establish medical suitability or physical acceptance. The same EN/TR values
// are guarded in locale catalogs and tools/data/localization_semantic_review.v1.json.
const Map<String, ({String english, String turkish})>
_reviewedSourceDisplayCopy = <String, ({String english, String turkish})>{
  "A: No symptoms; a person turns their head to see the timer. B: Tingling begins while waiting. Without the text explain your action and whether a retest occurs in each. Do not open the separate answer key before writing your answer. Seconds held do not determine a correct decision.": (
    english:
        "A: No symptoms; a person turns their head to see the timer. B: Tingling begins while waiting. Without the text explain your action and whether a retest occurs in each. Do not open the separate answer key before writing your answer. Seconds held do not determine a correct decision.",
    turkish:
        "A: Belirti yok; kişi zamanlayıcıya bakmak için başını çeviriyor. B: Kalırken karıncalanma başlıyor. İkisinde de ne yapacağını ve tekrar olup olmayacağını metne bakmadan söyle. Cevabını yazmadan ayrı cevap anahtarını açma. Kaç saniye kaldığın doğru kararı belirlemez.",
  ),
  "Before movement write: upright base → optional small free-arm rise/lower → supported shallow hinge OR familiar wall-dog preparation → upright base → optional short staggered stance/right return → neutral → optional left return → neutral rest. Choose only familiar components, keep required support and never remove it to make the route look continuous.": (
    english:
        "Before movement write: upright base → optional small free-arm rise/lower → supported shallow hinge OR familiar wall-dog preparation → upright base → optional short staggered stance and return of the right foot to neutral → neutral → optional return of the left foot to neutral → neutral rest. Choose only familiar components, keep required support and never remove it to make the route look continuous.",
    turkish:
        "Hareketten önce yaz: dik taban → seçmeli küçük serbest kol kaldır/indir → destekli sığ menteşe VEYA tanıdık duvar köpek hazırlığı → dik taban → seçmeli kısa şaşırtılmış adım/sağ ayağı nötre geri getir → nötr → seçmeli sol ayağı nötre geri getir → nötr dinlenme. Yalnız tanıdık bileşenleri seç; gereken desteği koru, kesintisiz görünmek için kaldırma.",
  ),
  "Bend at the hips to lower the seat slowly; only after sitting down release hands and rest the wrists.": (
    english:
        "Bend at the hips to lower your pelvis slowly; release your hands and rest your wrists only after sitting down.",
    turkish:
        "Kalçadan bükülerek yavaş otur; yalnız oturduktan sonra elleri bırakıp bilekleri dinlendir.",
  ),
  "Choose two standing shapes, two seated/low shapes, one breathing pause and rest.": (
    english:
        "Choose two standing shapes, two seated/low shapes, one pause from movement while continuing ordinary comfortable breathing, and rest.",
    turkish:
        "Ayakta iki duruş, oturarak ya da alçak konumda iki duruş, doğal ve rahat nefesini sürdürerek harekete vereceğin bir mola ve dinlenme seç.",
  ),
  "Did you deepen during the hold or try moving a loaded prop on exit? If symptom-free and you notice a habit of reaching for toes, leave, choose a closer hand location and make one brief rehearsal in a more upright/smaller form. Omit the lesson for symptoms or difficulty controlling the exit. Explain one setup choice and its reason instead of scoring the angle/distance.": (
    english:
        "Did you deepen during the hold or try moving a loaded prop on exit? If symptom-free and you notice a habit of reaching for toes, leave, choose a closer hand location and make one brief rehearsal in a more upright/smaller form. Omit the lesson for symptoms or difficulty controlling the exit. Explain one setup choice and its reason instead of scoring the angle/distance.",
    turkish:
        "Bekleme sırasında derinliği artırdın mı veya çıkışta yük altındaki bir desteği hareket ettirmeyi denedin mi? Belirtisiz olarak parmaklara uzanma alışkanlığını fark ettiysen çık, eller için yakın yer seç ve daha dik/küçük biçimde tek kısa prova yap. Belirti veya çıkışta kontrol güçlüğü varsa dersi bırak. Açıyı/ulaştığın mesafeyi puanlamak yerine bir kurulum seçimini ve nedenini açıkla.",
  ),
  "Did you reset the feet before changing direction and keep breathing at your chosen depth?\n\nOn two separate comfortable practices, can you keep this focus in the chosen variant? Reset the feet before bending the front knee or changing direction.\n\nNext practice, try this without checking the instructions: Reset the feet before bending the front knee or changing direction. Then review what you missed.": (
    english:
        "Did you reset the feet before changing direction and keep breathing naturally at your chosen posture depth?\n\nOn two separate comfortable practices, can you keep this focus in the chosen variant? Reset the feet before bending the front knee or changing direction.\n\nNext practice, try this without checking the instructions: Reset the feet before bending the front knee or changing direction. Then review what you missed.",
    turkish:
        "Yön değiştirmeden ayakları yeniden kurup seçtiğin duruş derinliğinde doğal nefesi sürdürebildin mi?\n\nİki ayrı rahat çalışmada, seçtiğin biçimde şu odağı koruyabildin mi? Ön dizi bükmeden veya yön değiştirmeden ayakları yeniden kur.\n\nSonraki çalışmada yönergeye bakmadan dene: Ön dizi bükmeden veya yön değiştirmeden ayakları yeniden kur. Ardından eksiklerini kontrol et.",
  ),
  "Face the wall upright with palms supported, feet hip-width. Check the space behind without turning while a foot is moving; if the path cannot be checked, omit stepping.": (
    english:
        "Face the wall upright with palms supported, feet hip-width. Before moving a foot, check the space behind you; do not turn while a foot is moving. If the path cannot be checked, omit stepping.",
    turkish:
        "Avuçlar destekli, ayaklar kalça genişliğinde duvara dönük dik dur. Bir ayağını hareket ettirmeden önce arkandaki alanı kontrol et; ayak hareket ederken dönme. Yol kontrol edilemiyorsa adımı atla.",
  ),
  "Keeping both palms in contact and knees soft, move the hips a little back and incline the trunk only a little. Elbows may straighten comfortably, never lock. This limited high wall variation is a preparation related to Downward Dog, not its floor form; no horizontal torso or head-below-hips target.": (
    english:
        "Keeping both palms in contact with the wall and knees soft, move the hips a little back and incline the trunk only a little. Elbows may straighten comfortably, never lock. This limited high wall variation is a preparation related to Downward Dog, not its floor form; no horizontal torso or head-below-hips target.",
    turkish:
        "Her iki avucu duvarda tutup dizleri yumuşak bırakarak kalçayı az geriye, gövdeyi yalnız biraz öne götür. Dirsekler rahatça açılabilir, kilitlenmez. Bu sınırlı yüksek duvar uyarlaması Köpek ile ilişkili hazırlıktır; yer biçimi değildir. Yatay gövde veya başı kalçanın altına indirme hedefi yoktur.",
  ),
  "Lissom is a general wellness app and is not a medical device, so it does not screen, diagnose or predict injury risk. Those claims require clinical validation we have not done and are not seeking. A movement reading, however carefully taken, is not evidence about your health.": (
    english:
        "Lissom is a general wellness app and is not a medical device, so it does not screen, diagnose or predict injury risk. Those claims require clinical validation we have not done and are not seeking. A movement reading, however carefully taken, is not evidence about your health.",
    turkish:
        "Lissom genel iyi yaşam uygulamasıdır; tıbbi cihaz değildir. Tarama, tanı veya sakatlanma riski tahmini yapmaz. Bu iddialar, yapmadığımız ve hedeflemediğimiz klinik doğrulama gerektirir. Hareket ölçümü tek başına sağlık durumuna ilişkin kanıt değildir.",
  ),
  "Lissom offers written yoga courses with practice tasks, adaptations and self-checks. Practice records stay on this device and reflect your own reports. Live camera measurements and subscription sales are closed in this release.": (
    english:
        "Lissom offers written yoga courses with practice tasks, adaptations and self-checks. Practice records stay on this device and reflect your own reports. Live camera measurements and subscription sales are closed in this release.",
    turkish:
        "Lissom, çalışma görevleri, uyarlamalar ve öz denetimler içeren yazılı yoga kursları sunar. Çalışma kayıtları bu cihazda kalır ve kendi beyanlarını yansıtır. Bu sürümde canlı kamera ölçümleri ve abonelik satışı kapalıdır.",
  ),
  "Lower the seat before lifting either hand, then rest wrists without rolling onto them.": (
    english:
        "Lower your pelvis back to sitting before lifting either hand, then rest your wrists without rolling onto them.",
    turkish:
        "Ellerinden herhangi birini kaldırmadan önce kalçanı indirip otur; ardından bileklerinin üzerine yuvarlanmadan bileklerini dinlendir.",
  ),
  "Lower to a padded kneeling seat using a stable support; place the hands before shifting weight forward.": (
    english:
        "Lower to a padded kneeling seat using a stable support; place the hands before shifting weight forward.",
    turkish:
        "Sabit destekle minderli diz üstü oturuşa alçal; ağırlığı öne vermeden elleri koy.",
  ),
  "Must feet move toward the wall or both hands release before the torso returns?": (
    english:
        "Must feet move toward the wall or both hands release before the torso returns upright?",
    turkish:
        "Gövde yeniden dik konuma dönmeden ayaklar duvara yaklaşmalı veya iki el bırakılmalı mı?",
  ),
  "Neither is required: feet remain fixed, palm contact stays while hips/trunk return, hands may slide upward; release one then the other only at a stable upright base when support is unnecessary. This is not floor-form evidence.": (
    english:
        "Neither is required: feet remain fixed, palm contact stays while hips/trunk return, hands may slide upward; release one then the other only at a stable upright base when support is unnecessary. This is not floor-form evidence.",
    turkish:
        "İkisi de gerekmez: ayaklar sabit, kalça yerine gelirken ve gövde doğrulurken avuç teması korunur; eller yukarı kayabilir. Destek gerekmeyen sağlam dik tabanda önce biri sonra diğeri bırakılır. Yer biçimi kanıtı değildir.",
  ),
  "Notice breathing without controlling or holding it.": (
    english: "Notice breathing without controlling or holding it.",
    turkish: "Nefesi kontrol etmeye çalışmadan veya tutmadan fark et.",
  ),
  "Once the familiar upright base and comfortable wall contact are restored, pause, then lower one hand to the thigh, followed by the other only if support is no longer needed. No foot approach occurs within this variation. If you cannot maintain comfortable contact/return at this distance, choose a shallower range or omit; do not improvise a backward/forward walking transition.": (
    english:
        "Once the familiar upright base and comfortable wall contact are restored, pause, then lower one hand to the thigh, followed by the other only if support is no longer needed. No foot approach occurs within this variation. If you cannot maintain comfortable contact/return at this distance, choose a shallower range or omit; do not improvise a backward/forward walking transition.",
    turkish:
        "Tanıdık dik taban ve rahat duvar teması geri geldiğinde bekle; önce bir eli uyluk yanına indir; ardından yalnız destek artık gerekmiyorsa diğer eli indir. Bu uyarlamada duvara yaklaşma adımı yoktur. Bu mesafede rahat temas/dönüş korunamıyorsa daha sığ aralık seç veya atla; doğaçlama ileri/geri yürüyüş ekleme.",
  ),
  "Place a folded blanket beneath shins or between heels and seat; enter slowly with a wall nearby.": (
    english:
        "Place a folded blanket beneath shins or between heels and buttocks; enter slowly with a wall nearby.",
    turkish:
        "Kaval kemiklerinin altına veya topuklarınla kalçanın arasına katlı battaniye koy; duvar yakındayken yavaş gir.",
  ),
  "Put both hands on the thighs and return to unobserved natural breathing if attention becomes tiring.": (
    english:
        "Put both hands on your thighs. If focusing on breathing becomes tiring, stop watching it and let breathing continue naturally.",
    turkish:
        "İki elini de uyluklarına koy; nefese dikkat etmek yorucu gelirse onu izlemeyi bırak ve solunumun doğal ritminde sürmesine izin ver.",
  ),
  "Repeat three alternating turns without swinging the arms for momentum.\n\nCommon mistake: Arm swing supplies momentum for the turn. Correction: Turn gently from a stable base; let the feet reset when needed.\n\nCompare a smaller and familiar standing turn with the same comfortable foot placement.": (
    english:
        "Repeat three alternating turns without swinging the arms for momentum.\n\nCommon mistake: Arm swing supplies momentum for the turn. Correction: Turn gently from a stable base; let the feet reset when needed.\n\nCompare a smaller and familiar standing turn with the same comfortable foot placement.",
    turkish:
        "Kolları savurmadan dönüşümlü üç dönüş yap.\n\nSık hata: Kol savurma dönüşe momentum sağlar. Düzeltme: Sabit tabandan yumuşak dön; gerekirse ayakları yeniden kur.\n\nAynı rahat ayak yerinde küçük ve tanıdık ayakta dönüşü karşılaştır.",
  ),
  "Select one taught shape already chosen comfortably. Describe support and exit; first rehearse a brief entry/exit.": (
    english:
        "Select one taught shape already chosen comfortably. Describe support and exit; first rehearse a brief entry/exit.",
    turkish:
        "Daha önce öğretilmiş ve rahat seçtiğin tek biçimi seç. Destek ve çıkışı anlat; önce kısa giriş/çıkış provası yap.",
  ),
  "Side entry and full lowering, wrist placement close-up and small-height comparison; show no head drop or unsupported straight-leg progression.": (
    english:
        "Side entry and full lowering, wrist placement close-up and small-height comparison; show no head drop or unsupported straight-leg progression.",
    turkish:
        "Yandan giriş ve tam iniş, bilek yerleşimi yakın planı ve küçük yükseklik karşılaştırması; başı düşürme veya desteksiz düz bacak ilerlemesi yok.",
  ),
  "Side-lying or seated rest as the same posture, a universal duration, pregnancy clearance, personal suitability or camera assessment.": (
    english:
        "Side-lying or seated rest as the same posture, a universal duration, pregnancy clearance, personal suitability or camera assessment.",
    turkish:
        "Yan yatış veya oturma dinlenmesini aynı poz saymayı, evrensel süreyi, gebelikte bu hareketi yapmaya uygunluk onayını, kişisel uygunluğu veya kamera değerlendirmesini.",
  ),
  "Someone says, “I must never move in Yin.” Explain the right to leave in your own words. For symptom-free distraction return to ordinary breathing; if you deliberately slowed it, end observation, return to ordinary breathing and check a brief observation again. Remove “more sensation = better” from your progress criteria.": (
    english:
        "Someone says, “I must never move in Yin.” Explain the right to leave in your own words. For symptom-free distraction return to ordinary breathing; if you deliberately slowed it, end observation, return to ordinary breathing and check a brief observation again. Remove “more sensation = better” from your progress criteria.",
    turkish:
        "Bir kişi “Yin'de hiç hareket etmemeliyim” diyor. Kendi sözlerinle çıkma hakkını açıkla. Belirtisiz dikkat dağılmasında yalnız normal nefese dön; bilerek yavaşlatmışsan gözlemi kesip sıradan nefese dön ve kısa gözlemde yeniden kontrol et. “Daha çok his = daha iyi” yorumunu ilerleme ölçütünden çıkar.",
  ),
  "The lesson's full setup or duration, pregnancy clearance, personal suitability or camera assessment.": (
    english:
        "The lesson's full setup or duration, pregnancy clearance, personal suitability or camera assessment.",
    turkish:
        "Dersin bütün kurulumunu veya süresini, gebelikte bu hareketi yapmaya uygunluk onayını, kişisel uygunluğu ya da kamera değerlendirmesini.",
  ),
  "The reading itself will not — see above for why.": (
    english:
        "The measurement value itself will not appear in this list — see above for why.",
    turkish: "Sayısal değer testin kendi sayfasında gösterilir.",
  ),
  "This lesson's exact chair placement, stance length, two-breath hold, foot reset, safe depth or personal balance judgment.": (
    english:
        "This lesson's exact chair placement, stance length, a posture held for two natural breaths, foot reset, safe depth or personal balance judgment.",
    turkish:
        "Dersin tam sandalye yerini, duruş uzunluğunu, iki doğal nefes boyunca duruşta kalmayı, ayak sıfırlamasını, güvenli derinliği veya kişisel denge kararını.",
  ),
  "This list is shared with the other apps built on the same measurement core, and that shared record still has no place for the number itself — it can only tell you that a test was measured, not what it came to.": (
    english:
        "This list uses the same measurement-record format as the other apps built on the same core. That format records that a test was measured, but does not include the numeric measurement value.",
    turkish:
        "Bu liste, aynı ölçüm altyapısını kullanan diğer uygulamalarla ortak kayıt biçimini kullanır. Bu biçim testin yapıldığını kaydeder; sayısal ölçüm değerini içermez.",
  ),
  "Write distinct branches for “prop slips” and “symptoms occur.” If a symptom-free written plan omitted neutral, add it before movement and verbally recheck the two entry/exit orders; repeating the whole practice is unnecessary. For an ordinary error during physical practice use the shared single smaller-rehearsal rule. No record replaces physical observation.": (
    english:
        "Write distinct branches for “prop slips” and “symptoms occur.” If a symptom-free written plan omitted neutral, add it before movement and verbally recheck the two entry/exit orders; repeating the whole practice is unnecessary. For an ordinary error during physical practice use the shared single smaller-rehearsal rule. No record replaces physical observation.",
    turkish:
        "Planın “destek kayarsa” ve “belirti olursa” dallarını ayrı yaz. Belirtisiz planda nötr arayı unuttuysan hareketten önce arayı ekle ve iki giriş/çıkış sırasını sözlü tekrar kontrol et; bütün çalışmayı tekrar etmek gerekmez. Fiziksel denemede yalnız belirtisiz bir kurulum/dikkat hatasında ortak tek küçük yeniden prova kuralını uygula. Hiçbir kayıt fiziksel gözlem yerine geçmez.",
  ),
  "A trained teacher remains necessary for individual physical instruction. Recording these lessons is self-reported participation, not observed Ashtanga skill.": (
    english:
        "These instructions teach the small written route, not personal physical eligibility. If setup, an action or a personal limit is uncertain, choose written study and name what needs clarification. A lesson record is self-reported participation, not observed Ashtanga skill.",
    turkish:
        "Bu yönergeler küçük yazılı yolu öğretir; kişisel fiziksel uygunluğu belirlemez. Kurulum, eylem veya kişisel sınır belirsizse yazılı incelemeyi seç, neyin açıklığa kavuşması gerektiğini adlandır. Ders kaydı öz beyanlı katılımdır; gözlenmiş Ashtanga becerisi değildir.",
  ),
  "Name the actions that are already familiar and suitable for you. Unknown setup or personal suitability belongs in a teacher question, not a completion tick.": (
    english:
        "For the optional standing route, identify the already taught h01/h02 boundaries and ordinary breathing, h03 supported standing and h05 small joint preparation, or those same familiar components you already know. This planning card is not the preparation itself. If any entry or return is new or unclear today, study it first and keep this route written; a completion mark is not permission.",
    turkish:
        "Seçmeli ayakta yol için önceden öğretilen h01/h02 sınır ve doğal nefes, h03 destekli duruş, h05 küçük eklem hazırlığını veya zaten bildiğin aynı tanıdık bileşenleri belirle. Bu plan kartı hazırlığın kendisi değildir. Giriş veya dönüş bugün yeni ya da belirsizse önce öğretimini incele, bu yolu yazılı tut; tamamlama işareti izin değildir.",
  ),
  "After suitable familiar preparation, stand with a comfortable space between the feet, knees unlocked and arms down. Use your planned wall support if needed.": (
    english:
        "Use the current a03 setup and the familiar small preparation identified there before optional movement. Then start as taught: feet comfortably apart, knees unlocked and arms down; keep the planned wall support if needed. If reaching this starting base is unfamiliar, remain with written study rather than trying a new transfer.",
    turkish:
        "Seçmeli hareketten önce güncel a03 kurulumunu ve orada belirlenen tanıdık küçük hazırlığı kullan. Sonra öğretildiği gibi ayaklar rahat aralıklı, dizler kilitsiz ve kollar aşağıda başla; gerekliyse planlı duvar desteğini koru. Bu başlangıç tabanına erişim tanıdık değilse yeni transfer denemek yerine yazılı incelemede kal.",
  ),
  "Keep one precise question for a trained teacher and decide whether to repeat a taught unit. Completion means participation records reached the end, not certified performance.": (
    english:
        "Keep one specific unresolved teaching question and return to its named lesson before deciding on another taught unit. Compare the written explanation first. Completion means participation records reached the end; it is not an observed assessment of practice.",
    turkish:
        "Tek somut çözülmemiş öğretim sorusu sakla; başka öğretilmiş birimi seçmeden adı verilen dersine dön. Önce yazılı açıklamayı karşılaştır. Tamamlama, katılım kayıtlarının sona ulaşmasıdır; uygulamanın gözlenmiş değerlendirmesi değildir.",
  ),
  "Pause at your own comfortable depth, then press through the feet to stand.": (
    english:
        "Pause at your own comfortable depth with both hands supported and breathe normally. Begin the return only in the next step; do not stand first and then try to approach the chair.",
    turkish:
        "İki el destekliyken kendi rahat derinliğinde bekle ve doğal nefes al. Dönüşe yalnız sonraki adımda başla; önce doğrulup sonra sandalyeye yaklaşmaya çalışma.",
  ),
  "Rehearse only the unfamiliar transitions once, then revise the written plan before h60; seek instruction for unresolved problems.": (
    english:
        "Rehearse once only a transition taught in an earlier lesson whose entry, support and exit you know and have used comfortably. Do not physically test a first-time or unresolved transition: keep it on paper, replace it with a familiar taught route or observation, then revise the plan before h60.",
    turkish:
        "Yalnız önceki bir derste öğretilmiş, girişini, desteğini ve çıkışını bildiğin ve rahat uyguladığın bir geçişi bir kez prova et. İlk kez karşılaşılan veya çözülmemiş bir geçişi fiziksel olarak sınama: kâğıtta tut, tanıdık öğretilmiş bir yol veya gözlemle değiştir; h60 öncesi planı düzelt.",
  ),
  "To return, keep feet fixed and bring hips forward over the feet as the trunk rises. Keep palms at their original height if comfortable; if needed, slide palms a little upward on the wall while returning, one short adjustment at a time without releasing both contacts. Stop at the highest comfortable supported trunk position; do not reach for an inaccessible upright position.": (
    english:
        "To return, keep feet fixed and bring hips forward over the feet as the trunk rises. Keep both palms continuously against the wall. Leave them at their original height if comfortable; if needed, make small upward slides without taking either palm off the wall. Stop at the highest comfortable supported trunk position; do not reach for an inaccessible upright position.",
    turkish:
        "Dönüşte ayaklar sabitken kalçayı ayakların üzerine öne getir ve gövdeyi yükselt. Her iki avucun duvarla teması dönüş boyunca kesilmesin. Rahatsa avuçlar başlangıç yüksekliğinde kalsın; gerekiyorsa avuçlardan hiçbirini duvardan kaldırmadan küçük yukarı kaydırmalar yap. En yüksek rahat destekli gövde konumunda dur; erişilemeyen dikliğe uzanma.",
  ),
  "From mountain, place one hand at the hip and raise the other arm only as far as comfortable.": (
    english:
        "Keep any needed lower-hand support on the wall. Start the free hand at the hip and raise only that arm as far as comfortable. If no hand is free without losing needed support, omit the arm lift or choose the seated option.",
    turkish:
        "Gereken alt el desteğini duvarda koru. Serbest eli kalçaya getirip yalnız o kolu rahat aralıkta kaldır. Gereken desteği kaybetmeden serbest el kalmıyorsa kol kaldırmayı atla veya oturarak seçeneği kullan.",
  ),
  "Finish upright, hands low, then use the familiar rest chair if chosen. End the route whenever attention, contact or breathing becomes uncertain; no timer or compulsory second round.": (
    english:
        "Finish at the familiar supported upright base. Let only free arms rest low and keep any hand support you still need. Then use the familiar rest chair if chosen. End the route whenever attention, contact or breathing becomes uncertain; no timer or compulsory second round.",
    turkish:
        "Tanıdık destekli dik tabanda bitir. Yalnız serbest kolları aşağıda dinlendir; hâlâ gereken el desteğini koru. Seçtiysen ardından tanıdık dinlenme sandalyesini kullan. Dikkat, temas veya nefes belirsizleşirse rotayı bitir; süre hedefi veya zorunlu ikinci tur yok.",
  ),
  "Walk closer to the chair before standing and raise the torso gradually. If light-headed, stop rising and use the stable support.": (
    english:
        "Before starting, choose the taught seated alternative if the chair setup or return is uncertain. To leave this familiar chair-supported fold, keep both palms supported, take small comfortable steps closer to the chair, then raise the torso gradually. Keep any hand support you still need. If light-headed, stop rising and keep stable support; do not repeat the attempt.",
    turkish:
        "Başlamadan önce sandalye kurulumu veya dönüş belirsizse öğretilen oturarak seçeneği seç. Bu tanıdık sandalye destekli katlanmadan çıkarken iki avucu destekli tut, sandalyeye doğru küçük rahat adımlar at, sonra gövdeyi yavaşça yükselt. Hâlâ gereken el desteğini koru. Sersemlik veya baş dönmesi hissedersen yükselmeyi durdur ve sağlam desteği koru; denemeyi yineleme.",
  ),
  "Bring the raised arm down after returning upright; pause before lifting the other arm.": (
    english:
        "After returning upright, lower the raised free arm and pause. Keep any needed hand support. Do not lift the supporting hand to change sides; omit the other side or choose an already familiar seated option if the next reach would remove needed support.",
    turkish:
        "Dik konuma döndükten sonra kaldırdığın serbest kolu indir ve bekle. Gereken el desteğini koru. Taraf değiştirmek için destek elini kaldırma; sonraki uzanma gereken desteği bırakmayı gerektiriyorsa o tarafı atla veya zaten tanıdık oturarak seçeneği seç.",
  ),
  "Do three slow reaches each way with a normal breath.\n\nCommon mistake: The side reach compresses one point instead of spreading the movement. Correction: Reach upward first, then lean a little without jamming one side.\n\nCompare the standing reach with a supported seated reach.": (
    english:
        "Choose only a reach with a free arm while needed hand support remains in place. One slow comfortable reach and return is optional; neither three repetitions nor both sides are required. Keep breathing naturally. Do not lift a supporting hand or add a new support transfer to complete the other side.\n\nCommon mistake: The side reach compresses one point instead of spreading the movement. Correction: Keep needed support, reach upward first with the free arm, then lean only a little without jamming one side; return upright before lowering that arm.\n\nAn already taught, familiar supported seated reach may be chosen instead. Compare your chosen smaller version in words; a second physical version is not required.",
    turkish:
        "Yalnız gereken el desteği yerinde kalırken serbest kolla yapılabilen uzanmayı seç. Tek yavaş, rahat uzanma ve dönüş seçmelidir; üç tekrar veya iki taraf zorunlu değildir. Doğal nefesi sürdür. Öteki tarafı tamamlamak için destek elini kaldırma veya yeni bir destek geçişi ekleme.\n\nSık hata: Yana uzanma hareketi yaymak yerine tek noktayı sıkıştırır. Düzeltme: Gereken desteği koru; serbest kolla önce yukarı uzan, sonra tek tarafı sıkıştırmadan yalnız az yana eğil; kolu indirmeden dik konuma dön.\n\nYerine önceden öğretilmiş, tanıdık ve destekli oturarak uzanmayı seçebilirsin. Seçtiğin küçük biçimi sözle karşılaştır; ikinci fiziksel biçim zorunlu değildir.",
  ),
};

/// Translate a stable template before substituting arguments. Callers never
/// translate a rendered English sentence or match user text with a regex.
String localeTemplate(
  BuildContext context,
  String english,
  String turkish,
  Map<String, Object> arguments,
) => _renderTemplate(localeText(context, english, turkish), arguments);

String _renderTemplate(String template, Map<String, Object> arguments) {
  final Set<String> expected = LissomLocalizations.argumentsOf(template);
  if (expected.length != arguments.length ||
      !expected.every(arguments.containsKey)) {
    throw ArgumentError('Localization template arguments differ');
  }
  return template.replaceAllMapped(
    RegExp(r'\{([A-Za-z][A-Za-z0-9_]*)\}'),
    (Match match) => arguments[match.group(1)]!.toString(),
  );
}

/// Catalogs may supply zero/one/two/few/many/other maps under the English
/// plural template. A plain translated string supports count-neutral copy.
String localePlural(
  BuildContext context,
  String englishOther,
  String turkish,
  int count, {
  required String englishOne,
  Map<String, Object> arguments = const <String, Object>{},
}) {
  final String tag = canonicalLocaleTag(Localizations.localeOf(context));
  final String fallback = tag == 'tr'
      ? turkish
      : (count.abs() == 1 ? englishOne : englishOther);
  final String template = tag == 'tr' || tag == 'en'
      ? fallback
      : LissomLocalizations.maybeOf(context)?.lookup(
              englishOther,
              pluralCategory: lissomPluralCategory(tag, count),
            ) ??
            fallback;
  return _renderTemplate(template, <String, Object>{
    ...arguments,
    'count': localizedInteger(context, count),
  });
}

/// The named gap already says what failed. OS exception text can include
/// paths or identifiers, so this detail gives a fixed translated next step.
String? localizedHistoryFailureDetail(BuildContext context, String? failure) {
  if (failure == null) return null;
  return localeText(
    context,
    'Reopen Lissom and check your records again.',
    'Uygulamayı yeniden açıp kayıtlarını tekrar kontrol et.',
  );
}

/// Translate display copy loaded from versioned IA and assessment JSON.
/// Unknown values remain visible in their source language rather than vanishing.
String configText(BuildContext context, String source) {
  final String tag = canonicalLocaleTag(Localizations.localeOf(context));
  final clarified = _reviewedSourceDisplayCopy[source];
  if (tag == 'tr') {
    if (clarified != null) return clarified.turkish;
    final String? direct = _turkishConfigCopy[source];
    if (direct != null) return direct;
  }
  final String honestSource =
      clarified?.english ??
      (source == _assessmentIntro ? _assessmentIntroHonest : source);
  final String? translated = LissomLocalizations.maybeOf(
    context,
  )?.lookup(source);
  if (tag != 'en' && translated != null) return translated;

  // These bounded formats come from the app's typed config/engine readers.
  // They are not a general translator for rendered English or user input.
  final RegExpMatch? sidedTest = RegExp(
    r'^(.+) · (right|left)$',
  ).firstMatch(source);
  if (sidedTest != null && _turkishConfigCopy.containsKey(sidedTest.group(1))) {
    return localeTemplate(
      context,
      '{name} · {side}',
      '{name} · {side}',
      <String, Object>{
        'name': configText(context, sidedTest.group(1)!),
        'side': sidedTest.group(2) == 'right'
            ? localeText(context, 'right', 'sağ')
            : localeText(context, 'left', 'sol'),
      },
    );
  }
  final RegExpMatch? mixedVerdict = RegExp(
    r'^Of the (\d+) tests behind this line, (\d+) is compared against a reference range and (\d+) are reported without one — the second kind carries no verdict\.$',
  ).firstMatch(source);
  if (mixedVerdict != null) {
    return localeTemplate(
      context,
      'Of the {total} tests behind this line, {compared} is compared against a reference range and {uncompared} are reported without one — the second kind carries no verdict.',
      'Bu satırın dayandığı {total} testin {compared} tanesi referans aralığıyla karşılaştırılır; {uncompared} tanesi karşılaştırılmadan bildirilir. İkinci gruba ilişkin bir hüküm verilmez.',
      <String, Object>{
        'total': localizedInteger(context, int.parse(mixedVerdict.group(1)!)),
        'compared': localizedInteger(
          context,
          int.parse(mixedVerdict.group(2)!),
        ),
        'uncompared': localizedInteger(
          context,
          int.parse(mixedVerdict.group(3)!),
        ),
      },
    );
  }
  final RegExpMatch? namedCount = RegExp(
    r'^(\d+) named · none in this build\.$',
  ).firstMatch(source);
  if (namedCount != null) {
    return localeTemplate(
      context,
      '{count} named · none in this build.',
      '{count} başlık var · bu sürümde içerik yok.',
      <String, Object>{
        'count': localizedInteger(context, int.parse(namedCount.group(1)!)),
      },
    );
  }
  final RegExpMatch? cameraDistance = RegExp(
    r'^Stand about (\d+)–(\d+) cm from the camera\.$',
  ).firstMatch(source);
  if (cameraDistance != null) {
    return localeTemplate(
      context,
      'Stand about {min}–{max} cm from the camera.',
      'Kameradan yaklaşık {min}–{max} cm uzakta dur.',
      <String, Object>{
        'min': localizedInteger(context, int.parse(cameraDistance.group(1)!)),
        'max': localizedInteger(context, int.parse(cameraDistance.group(2)!)),
      },
    );
  }
  final RegExpMatch? cameraHeight = RegExp(
    r'^Put the phone (\d+)–(\d+) cm off the floor\.$',
  ).firstMatch(source);
  if (cameraHeight != null) {
    return localeTemplate(
      context,
      'Put the phone {min}–{max} cm off the floor.',
      'Telefonu yerden {min}–{max} cm yüksekliğe koy.',
      <String, Object>{
        'min': localizedInteger(context, int.parse(cameraHeight.group(1)!)),
        'max': localizedInteger(context, int.parse(cameraHeight.group(2)!)),
      },
    );
  }
  final RegExpMatch? yaw = RegExp(
    r'^Face the camera square-on — more than (\d+)° of turn and the reading is not used\.$',
  ).firstMatch(source);
  if (yaw != null) {
    return localeTemplate(
      context,
      'Face the camera square-on — more than {degrees}° of turn and the reading is not used.',
      'Kameraya düz dön; {degrees}° üzerindeki dönüşlerde ölçüm kullanılmaz.',
      <String, Object>{
        'degrees': localizedInteger(context, int.parse(yaw.group(1)!)),
      },
    );
  }
  return _knownBlockerText(context, source) ?? honestSource;
}

// Metric subjects are named by the engine's finite bridge vocabulary. Do not
// partially rewrite an unrecognised ID, user string or unknown blocker reason.
const Set<String> _knownBlockerSubjects = <String>{
  'Forward trunk lean',
  'Sideways trunk tilt',
  'Shin angle',
  'Heel lift',
  'Knee height',
  'Reach depth',
  'Shoulder-line width',
  'Hip line in the plank',
  'Hold time',
};

String? _knownBlockerText(BuildContext context, String source) {
  final String? direct = _turkishBlockerParts[source];
  if (direct != null) return localeText(context, source, direct);
  final List<String> groups = source.split(' · ');
  if (groups.length > 1) {
    final List<String> translated = <String>[];
    for (final String group in groups) {
      final String? value = _knownBlockerText(context, group);
      if (value == null) return null;
      translated.add(value);
    }
    return translated.join(' · ');
  }
  final int divider = source.indexOf(' — ');
  if (divider == -1) return null;
  final String subject = source.substring(0, divider);
  final String reason = source.substring(divider + 3);
  final String? translatedReason = _knownBlockerText(context, reason);
  if (translatedReason == null) return null;
  String translatedSubject;
  if (_turkishConfigCopy.containsKey(subject)) {
    translatedSubject = configText(context, subject);
  } else {
    final List<String> subjects = subject.replaceAll(' and ', ', ').split(', ');
    if (subjects.isEmpty || !subjects.every(_knownBlockerSubjects.contains)) {
      return null;
    }
    final List<String> names = subjects
        .map(
          (String name) =>
              localeText(context, name, _turkishBlockerParts[name]!),
        )
        .toList();
    translatedSubject = names.length == 1
        ? names.single
        : localeTemplate(
            context,
            '{first} and {last}',
            '{first} ve {last}',
            <String, Object>{
              'first': names.sublist(0, names.length - 1).join(', '),
              'last': names.last,
            },
          );
  }
  return localeTemplate(
    context,
    '{subject} — {reason}',
    '{subject} — {reason}',
    <String, Object>{'subject': translatedSubject, 'reason': translatedReason},
  );
}

const String _assessmentIntro =
    'Twelve camera-based movement tests. Each one measures a specific area and tells you what it could and could not see.';
const String _assessmentIntroHonest =
    'Twelve movement assessments are listed; three have a camera measurement path in this build. Each test shows its current limits.';

const Map<String, String> _turkishConfigCopy = <String, String>{
  'Something unexpected happened while starting the camera. Try again.':
      'Kamera başlatılırken beklenmeyen bir hata oluştu. Yeniden dene.',
  'The camera could not start. Try again.':
      'Kamera başlatılamadı. Yeniden dene.',
  'Camera access is off for Lissom.': 'Lissom için kamera erişimi kapalı.',
  'Lissom needs camera access to measure.':
      'Lissom ölçüm yapmak için kamera erişimine ihtiyaç duyar.',
  'MEASUREMENTS, NOT MARKS': 'BUNLAR ÖLÇÜM, NOT DEĞİL',
  'Measured and compared': 'Ölçüldü ve karşılaştırıldı',
  'Measured — your starting point': 'Ölçüldü; başlangıç noktan',
  'Below the lowest range we compare against. That is a starting point, not a failure — and the number is yours.':
      'Karşılaştırdığımız en düşük aralığın altında. Bu bir başlangıç noktasıdır, başarısızlık değildir; sayı sana aittir.',
  'Your number, placed against the range we compare with.':
      'Değerin, karşılaştırmada kullandığımız aralığa göre gösterilir.',
  'Measured — read qualitatively': 'Ölçüldü; nitel olarak okunur',
  'These tests have no numeric range to compare against, by design.':
      'Bu testlerin tasarım gereği karşılaştırılacak sayısal aralığı yoktur.',
  'Measured — not compared': 'Ölçüldü; karşılaştırılmadı',
  'The number is real. Why we cannot compare it is on each row.':
      'Sayı gerçek bir ölçümdür. Neden karşılaştıramadığımız her satırda açıklanır.',
  'Named, with the reason. We would rather tell you than leave a blank.':
      'Nedeniyle birlikte adlandırıldı. Boş bırakmak yerine açıklıyoruz.',
  'Ashtanga beginner foundations': 'Ashtanga başlangıç temelleri',
  'Written Hatha, chair/office, supported standing Vinyasa, adapted supported Yin and Ashtanga beginner foundations are included. Ashtanga uses standing adaptations and sequence reading, not the full Primary Series. Demonstration and physical acceptance remain separate. Yoga postures are not camera-scored.':
      'Yazılı Hatha, sandalye/ofis, destekli ayakta Vinyasa, uyarlanmış destekli Yin ve Ashtanga başlangıç temelleri içerilir. Ashtanga ayakta uyarlamalar ve sıra okumayı kullanır; tam temel seri değildir. Gösterim ve fiziksel kabul ayrıdır. Yoga duruşları kamerayla puanlanmaz.',
  'Written Hatha, chair/office, supported standing Vinyasa and adapted supported Yin beginner paths are included. Demonstration and physical acceptance remain separate; the beginner Ashtanga course remains pending. Yoga postures are not camera-scored.':
      'Yazılı Hatha, sandalye/ofis, destekli ayakta Vinyasa ve uyarlanmış destekli Yin başlangıç yolları içerilir. Gösterim ve fiziksel kabul ayrı; başlangıç Ashtanga kursu bekliyor. Yoga duruşları kamerayla puanlanmaz.',
  "Today's plan": 'Bugünün planı',
  'Measuring again': 'Yeniden ölçüm',
  'Continue': 'Devam et',
  'Quick start': 'Hızlı başlangıç',
  'Assessment Battery': 'Hareket değerlendirmeleri',
  'Runs in this build.': 'Bu sürümde çalışır.',
  'Named, not in this build — no sessions are bundled with the app.':
      'Bu bölümde başlıklar var; bu sürümde oturum içeriği yok.',
  'Head and feet must stay in frame through the full range of motion.':
      'Hareket boyunca başın ve ayakların kadrajda kalsın.',
  'measured and compared with a reference range':
      'ölçüldü ve referans aralığıyla değerlendirildi',
  'measured, below the lowest reference line':
      'ölçüldü; en düşük referans çizgisinin altında',
  'measured, this test has no numeric range by design':
      'ölçüldü; bu testin sayısal aralığı yok',
  'measured, not compared with any reference':
      'ölçüldü; referansla karşılaştırılmadı',
  'attempted, no reading could be taken': 'denendi; ölçüm alınamadı',
  'recorded': 'kaydedildi',
  'Compared against an age-banded reference range.':
      'Yaş grubuna göre belirlenmiş referans aralığıyla karşılaştırılır.',
  'Reported without any reference range — the number is a reading, not a verdict.':
      'Referans aralığı olmadan bildirilir; sayı bir okumadır, hüküm değildir.',
  'Programmes for children': 'Çocuklara yönelik programlar',
  'Breath or meditation measurement': 'Nefes veya meditasyon ölçümü',
  'Clinical screens and risk scores': 'Klinik tarama ve risk puanları',
  'Hot yoga (Bikram)': 'Sıcak yoga (Bikram)',
  'Hip internal / external rotation measurement':
      'Kalça iç / dış rotasyon ölçümü',
  'Cervical rotation': 'Boyun rotasyonu',
  "Lissom has no validated camera assessment for children. The youngest reference band is a single under-40 group, not a child-specific reference. This release does not provide programmes for children.":
      "Çocuklar için doğrulanmış Lissom kamera değerlendirmesi yoktur. En genç referans grubu 40 yaş altıdır; çocuklara özgü referans değildir. Bu sürümde çocuklara yönelik program bulunmaz.",
  'Lissom does not measure breathing or meditation with the camera. The Hatha course includes natural-breath practice without a breathing score; guided meditation sessions are not included.':
      'Lissom nefesi veya meditasyonu kamerayla ölçmez. Hatha kursunda nefes puanı vermeyen doğal nefes çalışması vardır; rehberli meditasyon oturumu bulunmaz.',
  'Lissom is a general wellness app and is not a medical device, so it does not screen, diagnose or predict injury risk. Those claims require clinical validation we have not done and are not seeking. A movement reading, however carefully taken, is not evidence about your health.':
      'Lissom genel iyi yaşam uygulamasıdır; tıbbi cihaz değildir. Tarama, tanı veya sakatlanma riski tahmini yapmaz. Bu iddialar klinik doğrulama gerektirir. Hareket ölçümü tek başına sağlık durumuna ilişkin kanıt değildir.',
  'Heat lends you range while you are in it, and we cannot tell borrowed range from your own — a reading taken in a hot room would quietly overstate you. Room temperature is also something an app can neither provide nor verify.':
      'Isı, hareket açıklığını geçici olarak artırabilir. Sıcak odadaki ölçümün doğal açıklığından ne kadar farklı olduğunu ayıramayız. Uygulama oda sıcaklığını da sağlayamaz veya doğrulayamaz.',
  'Rotation happens in the plane the camera is looking down, so a single lens cannot recover it. We would rather leave the test out of the battery than print a number we cannot stand behind.':
      'Bu dönüş kameranın bakış yönündeki düzlemde gerçekleşir; tek kamerayla güvenilir biçimde ölçülemez. Savunamayacağımız bir sayı göstermek yerine testi değerlendirmeden çıkarıyoruz.',
  'A single 2D camera cannot recover transverse-plane rotation reliably. Measuring it anyway would mean showing a number we cannot stand behind.':
      'Tek bir iki boyutlu kamera yatay düzlemdeki dönüşü güvenilir biçimde çıkaramaz. Bu yüzden sayı göstermiyoruz.',
  'Pose model facial/neck landmarks are too coarse for the precision neck rotation needs. Excluded rather than shown with a wide meaningless band.':
      'Poz modelinin yüz ve boyun noktaları, boyun dönüşü için gereken hassasiyeti sağlamaz. Anlamsız geniş bir aralık göstermek yerine test çıkarıldı.',
  'Standing, seated and kneeling poses':
      'Ayakta, oturarak ve diz çökerek yapılan duruşlar',
  'Floor and supine poses': 'Yerde ve sırtüstü duruşlar',
  'Inversions': 'Ters duruşlar',
  'Pose-by-pose coaching and reference scoring are not available.':
      'Duruş bazında koçluk ve referans puanlaması sunulmaz.',
  'Guided camera coaching and scoring are not available.':
      'Kamerayla rehberlik ve puanlama sunulmaz.',
  'Avatar demonstrations and scoring are not available.':
      'Avatar gösterimi ve puanlama sunulmaz.',
  'Pose coaching is not available for this category.':
      'Bu kategori için poz koçluğu sunulmaz.',
  'Self-occlusion: lying on the floor hides most landmarks from a side camera':
      'Yerde uzanırken vücut, yan kameradan birçok eklem noktasını örter.',
  'Pose models silently swap limb labels on inverted bodies with high confidence (family finding M-019)':
      'Poz modelleri ters duruşlarda uzuv adlarını yüksek güvenle yanlış eşleyebilir (aile bulgusu M-019).',
  'A limit of what a phone camera can do. Better hardware could change this.':
      'Telefon kamerasının yetenek sınırı. Farklı donanım bunu değiştirebilir.',
  'A limit of what we can measure apart from everything else.':
      'Ölçümü diğer etkenlerden ayırabilme sınırı.',
  'A choice. We would keep it even with perfect measurement.':
      'Ürün kararı. Ölçüm kusursuz olsa da bu sınır kalır.',
  'Shoulder, hip and knee angles, in the plane the camera faces':
      'Kameranın gördüğü düzlemde omuz, kalça ve diz açıları',
  'Left and right measured separately on those joints — never averaged into one figure, because a stiff left shoulder and a mobile right one are not one number':
      'Sağ ve sol ayrı ölçülür; iki farklı hareket açıklığı tek sayıda birleştirilmez.',
  'Trunk lean and shin angle measured against vertical':
      'Gövde eğimi ve kaval kemiği açısı dikey çizgiye göre',
  'Hold duration and gross balance': 'Duruş süresi ve genel denge',
  'Rotation of the hip or shoulder (a single camera cannot recover transverse-plane twist)':
      'Kalça veya omuz dönüşü (tek kamera yatay düzlemdeki dönüşü güvenilir ölçemez)',
  'Forward lean and sideways lean as two separate figures — the measurement engine keeps a single tilt, so the frontal plane is not read apart from the sagittal one':
      'Öne ve yana eğimi ayrı sayılar olarak vermez; ölçüm motoru yalnız tek eğim değeri tutar.',
  'How far your shin leans from upright — the measurement engine reads a limb against the line of your torso, not against upright, so a shin angle measured this way would change when you lean':
      'Kaval kemiğinin dikeyden ne kadar saptığını vermez; motor açıyı gövdeye göre okur ve gövde eğilince sayı değişir.',
  'Distances and heights — how far your fingertips reach, how high a heel or knee lifts, how far the hips drop in a plank. The measurement engine reads angles between body points and does not read distances at all.':
      'Uzaklık ve yükseklikleri ölçmez: uzanma mesafesi, topuk veya diz yüksekliği ve plankta kalçanın düşüşü. Motor vücut noktaları arasındaki açıları okur.',
  'Anything clinical: this is not a screen, a diagnosis, or an injury-risk prediction':
      'Klinik değerlendirme yoktur: tarama, tanı veya sakatlanma riski tahmini yapılmaz.',
  'An exact, validated degree — we show you the number we measured, but our own validation study has not been run, so it is a reading and not a verdict':
      'Doğrulanmış kesin derece iddiası yoktur. Gösterilen sayı bir okumadır; kendi doğrulama çalışmamız yapılmadığı için hüküm değildir.',
  'Standing, seated and kneeling poses — joint angles and hold time':
      'Ayakta, oturarak ve diz çökerek yapılan duruşlarda eklem açıları ve duruş süresi',
  'Floor and prone poses are guided but not scored: lying on the floor is where a single camera is weakest':
      'Yerde ve yüzüstü duruşlarda yönlendirme yapılabilir; tek kamera burada zayıf kaldığı için puanlama yapılmaz.',
  'Inversions are demonstrated by the avatar only':
      'Ters duruşlar yalnız avatar tarafından gösterilir.',
  'Breath is never measured by the camera': 'Nefes kamera ile ölçülmez.',
  "No goal measurements or scheduled re-tests are available in this build.":
      "Bu sürümde hedef ölçümleri veya zamanlanmış yeniden testler bulunmaz.",
  "No estimate of weeks or months to a goal is available.":
      "Bir hedefe kaç hafta veya ay kaldığına ilişkin tahmin sunulmaz.",
  "No measurement-noise threshold or progress-change judgement is available.":
      "Ölçüm gürültüsü eşiği veya ilerleme değişikliği değerlendirmesi sunulmaz.",
  "No routine-weighted movement tests or personalised programmes are available in this build.":
      "Bu sürümde rutinine göre ağırlıklandırılmış hareket testi veya kişiselleştirilmiş program bulunmaz.",
  "No occupation-specific injury-risk assessment is available.":
      "Mesleğe özgü sakatlanma riski değerlendirmesi sunulmaz.",
  "No partner-app mobility checks or app handoffs are available in this build.":
      "Bu sürümde diğer uygulamalara yönelik hareketlilik kontrolü veya uygulamaya aktarım bulunmaz.",
  "Sports coaching is not provided by this family in this build.":
      "Bu bölüm bu sürümde spor koçluğu sunmaz.",
  "No audio-guided or timed sessions are available in this build. The camera is off.":
      "Bu sürümde sesli rehberli veya zamanlayıcılı oturum bulunmaz. Kamera kapalıdır.",
  'Breath rate, depth or quality — a phone camera cannot measure breathing and we do not pretend otherwise':
      'Nefes hızı, derinliği veya kalitesi ölçülmez; telefon kamerası bunu güvenilir biçimde ölçemez.',
  'Meditation state or relaxation of any kind':
      'Meditasyon durumu veya gevşeme düzeyi ölçülmez.',
  _assessmentIntro:
      'On iki hareket değerlendirmesi listelenir; bu sürümde üçünün kamera ölçüm yolu vardır. Her test mevcut sınırlarını açıklar.',
  'Yoga Styles': 'Yoga türleri',
  'Written Hatha and chair/office beginner paths are available. Demonstration and physical acceptance remain separate; Vinyasa, Yin and beginner Ashtanga courses remain pending. Yoga postures are not camera-scored.':
      'Yazılı Hatha ve sandalye/ofis başlangıç yolları mevcut. Gösterim ve fiziksel kabul ayrıdır; Vinyasa, Yin ve başlangıç Ashtanga kursları bekliyor. Yoga pozları kamerayla puanlanmaz.',
  'A complete guided Hatha course is available. Other named styles have no classes in this build; yoga postures are not camera-scored.':
      'Tam bir rehberli Hatha kursu mevcut. Adı geçen diğer stillerin bu sürümde dersi yok; yoga pozları kamerayla puanlanmaz.',
  'No Hatha posture is graded or certified by the camera in this course':
      'Bu kursta hiçbir Hatha pozu kamerayla puanlanmaz veya onaylanmaz.',
  'Breath, pain, joint load and safety cannot be judged from the camera':
      'Nefes, ağrı, eklem yükü ve güvenlik kamera görüntüsünden değerlendirilemez.',
  'Advanced inversions are not required practice in this course':
      'İleri ters duruşlar bu kursun zorunlu pratiği değildir.',
  'Hatha': 'Hatha',
  'Vinyasa': 'Vinyasa',
  'Yin': 'Yin',
  'Ashtanga (primary series)': 'Ashtanga (temel seri)',
  'Chair / Office Yoga': 'Sandalye / ofis yogası',
  'Flexibility Goals': 'Esneklik hedefleri',
  'Path to Front Split': 'Öne açılma yolu',
  'Path to Middle Split': 'Yana açılma yolu',
  'Hip Opening': 'Kalça açma',
  'Hamstring Length': 'Arka bacak esnekliği',
  'Backbend': 'Geriye esneme',
  'Shoulder Opening': 'Omuz açma',
  'For Your Day': 'Günlük yaşamına uygun',
  'Desk Worker': 'Masa başında çalışanlar',
  'Runner': 'Koşucular',
  'Lifter': 'Ağırlık çalışanlar',
  'Senior Mobility': 'İleri yaş hareketliliği',
  'Prenatal': 'Gebelik dönemi',
  'Warm-ups for Other Sports': 'Diğer sporlar için ısınma',
  'Fighter Warm-up': 'Dövüş sporu ısınması',
  'Dancer Warm-up': 'Dans ısınması',
  'Calisthenics Prep': 'Kalistenik hazırlık',
  'Breath & Wind-down': 'Nefes ve sakinleşme',
  'Overhead Reach': 'Yukarı uzanma',
  'Deep Squat': 'Derin çömelme',
  'Overhead Squat': 'Kollar yukarıda çömelme',
  'Ankle Mobility': 'Ayak bileği hareketliliği',
  'Standing Forward Reach': 'Ayakta öne uzanma',
  'Hip Hinge': 'Kalçadan öne eğilme',
  'Side Bend': 'Yana eğilme',
  'Single-Leg Balance': 'Tek ayak dengesi',
  'Forward Lunge': 'Öne hamle',
  'Seated Torso Rotation': 'Oturarak gövde dönüşü',
  'Active Straight Leg Raise': 'Düz bacak kaldırma',
  'Plank Hold': 'Plank duruşu',
  'Hatha, Vinyasa and Yin are listed here. Classes and course content are not available in this version.':
      'Hatha, Vinyasa ve Yin burada listelenir; ders ve kurs içerikleri bu sürümde yoktur.',
  "Flexibility goal paths are listed in the plan. No programme, trend chart or scheduled re-measurement is included in this release.":
      "Esneklik hedefleri için yollar planda listelenir. Bu sürümde program, eğilim grafiği veya zamanlanmış yeniden ölçüm bulunmaz.",
  "Day-to-day movement programmes are listed in the plan. This release does not adapt programmes or weight tests to your routine.":
      "Günlük hareket programları planda listelenir. Bu sürümde programlar veya test ağırlıkları günlük rutinine uyarlanmaz.",
  "Warm-ups for other sports are listed in the plan. No warm-up content or handoff to another app is included in this release.":
      "Diğer sporlar için hazırlıklar planda listelenir. Bu sürümde hazırlık içeriği veya başka uygulamaya aktarım bulunmaz.",
  "No breath or wind-down sessions, audio guidance or session timer are included in this release.":
      "Bu sürümde nefes veya sakinleşme oturumu, sesli rehberlik veya oturum zamanlayıcısı bulunmaz.",
  'Stand side-on to the camera. Let your arms hang. Slowly raise the arm nearest the camera as high overhead as you can, keep the elbow straight, hold for two seconds, then lower.':
      'Kameraya yan dön. Kollarını serbest bırak. Kameraya yakın kolunu dirseğini düz tutarak yavaşça yukarı kaldır, iki saniye tut ve indir.',
  'Stand side-on to the camera, feet shoulder-width apart, arms forward. Squat as low as you comfortably can, hold for two seconds, then stand back up.':
      'Kameraya yan dön; ayakların omuz genişliğinde, kolların önde olsun. Rahat edebildiğin kadar çömel, iki saniye tut ve yeniden doğrul.',
  'Stand side-on to the camera. Raise both arms straight overhead and keep them there. Squat as low as you can while keeping your arms up, then stand back up.':
      'Kameraya yan dön. İki kolunu düz biçimde yukarı kaldırıp orada tut. Kolların yukarıdayken rahatça çömelebildiğin kadar alçal ve doğrul.',
  "Face a wall, side-on to the camera. Place the foot nearest the camera about a hand's width from the wall, heel flat. Bend your knee forward to touch the wall without lifting the heel.":
      'Bir duvara dön ve kameraya yan dur. Kameraya yakın ayağını duvardan yaklaşık bir el genişliği uzağa koy; topuğun yerde kalsın. Topuğunu kaldırmadan dizini duvara doğru bük.',
  'Stand side-on to the camera with your legs straight. Bend forward from the hips and reach toward your toes. Go only as far as is comfortable, hold two seconds, then stand up slowly.':
      'Bacakların düzken kameraya yan dön. Kalçadan öne eğilip ayak parmaklarına uzan. Yalnız rahat ettiğin kadar ilerle, iki saniye tut ve yavaşça doğrul.',
  'Stand side-on to the camera with hands on your hips. Push your hips backward and fold forward while keeping your back flat, then return upright.':
      'Ellerin kalçandayken kameraya yan dön. Sırtını düz tutarak kalçanı geriye it ve öne eğil; ardından doğrul.',
  'Stand facing the camera, feet hip-width apart, arms relaxed at your sides. Slide one hand down the side of your leg, bending sideways as far as is comfortable. Return upright, then repeat to the other side.':
      'Kameraya dön; ayakların kalça genişliğinde, kolların yanda rahat olsun. Bir elini bacağının yanından aşağı kaydırarak rahat ettiğin kadar yana eğil. Doğrulup diğer yana tekrarla.',
  'Stand facing the camera with your hands on your hips. Lift one foot off the floor and hold as steady as you can for up to 30 seconds. Put the foot down if you need to.':
      'Ellerin kalçandayken kameraya dön. Bir ayağını yerden kaldır ve en fazla 30 saniye dengede durmaya çalış. Gerektiğinde ayağını yere koy.',
  'Stand facing the camera. Step forward into a lunge, lowering your back knee toward the floor while keeping your torso upright. Push back to standing.':
      'Kameraya dön. Bir adım öne atıp gövdeni dik tutarak arka dizini yere doğru indir. Ardından ayakta duruşa dön.',
  'Sit on a chair facing the camera with your arms crossed over your chest and your knees pointing forward. Turn your upper body to one side as far as is comfortable, return to centre, then turn the other way.':
      'Kameraya dönük bir sandalyeye otur. Kollarını göğsünde çaprazla, dizlerin öne baksın. Gövdeni rahat ettiğin kadar bir yana çevir, ortaya dön, sonra diğer yana çevir.',
  'Lie on your back, side-on to the camera, with both legs straight. Keeping the other leg flat on the floor, raise the leg nearest the camera as high as you can with the knee straight. Lower it slowly.':
      'Kameraya yan olacak biçimde sırtüstü yat, iki bacağın düz olsun. Diğer bacağını yerde tutarken kameraya yakın bacağını dizini bükmeden rahatça kaldırabildiğin kadar kaldır ve yavaşça indir.',
  'Set up side-on to the camera in a forearm plank, body in one straight line from head to heels. Hold as steady as you can for up to 45 seconds. Come down when your form breaks or you need to stop.':
      'Kameraya yan dönerek dirsek plankına geç; başından topuklarına kadar düz bir çizgi oluştur. En fazla 45 saniye dengede kal. Duruşun bozulursa veya durman gerekirse bırak.',
};

const Map<String, String> _turkishBlockerParts = <String, String>{
  'Forward trunk lean': 'Gövdenin öne eğimi',
  'Sideways trunk tilt': 'Gövdenin yana eğimi',
  'Shin angle': 'Kaval kemiği açısı',
  'Heel lift': 'Topuk yükselmesi',
  'Knee height': 'Diz yüksekliği',
  'Reach depth': 'Uzanma mesafesi',
  'Shoulder-line width': 'Omuz çizgisinin genişliği',
  'Hip line in the plank': 'Plank sırasında kalça çizgisi',
  'Hold time': 'Duruş süresi',
  'the measurement engine reads angles between body points, and this is '
          'a distance rather than an angle':
      'ölçüm motoru vücut noktaları arasındaki açıları okur; bu ise bir mesafedir',
  'the measurement engine keeps a single tilt figure and cannot tell '
          'forward lean apart from sideways lean':
      'ölçüm motoru tek bir eğim değeri tutar; öne ve yana eğimi ayıramaz',
  'the measurement engine reads a limb against the line of your torso, '
          'not against upright, so it cannot say how far this one is from '
          'vertical':
      'ölçüm motoru uzvu dikey çizgiye değil gövdeye göre okur; dikeyden sapmayı söyleyemez',
  'this test is timed by the session rather than measured from camera '
          'angles, and the camera-measurement bridge does not cover it':
      'bu test kamera açılarıyla değil oturum süresiyle değerlendirilir; kamera ölçüm bağlantısı bu değeri kapsamıyor',
  'one of the readings this test needs is not declared anywhere in the '
          'app, so we cannot say what it would take to run it':
      'bu testin gerektirdiği değerlerden biri uygulamada tanımlı değil; çalışması için ne gerektiğini söyleyemiyoruz',
  ' and ': ' ve ',
};
