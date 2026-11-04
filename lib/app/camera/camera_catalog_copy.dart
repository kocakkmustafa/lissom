import 'package:flutter/widgets.dart';

import '../locale_text.dart';

/// Pose names and corrections of `config/yoga/camera-poses.v1.json`, written
/// out as literal `localeText` pairs so the fourteen-language catalog check
/// sees them (`tools/extract_ui_localization.py` reads only literals).
/// `camera_catalog_copy_test.dart` keeps this list equal to the catalog.
String cameraCatalogText(
  BuildContext context,
  String english,
  String turkish,
) => switch (english) {
  'Mountain stance' => localeText(context, 'Mountain stance', 'Dağ duruşu'),
  'Bring your shoulders over your hips.' => localeText(
    context,
    'Bring your shoulders over your hips.',
    'Omuzlarını kalçalarının üstüne getir.',
  ),
  'Let your ribs come back over your pelvis.' => localeText(
    context,
    'Let your ribs come back over your pelvis.',
    'Kaburgaların leğeninin üstüne geri gelsin.',
  ),
  'Let your head rest above your shoulders.' => localeText(
    context,
    'Let your head rest above your shoulders.',
    'Başın omuzlarının üstünde dursun.',
  ),
  'Standing with arms raised' => localeText(
    context,
    'Standing with arms raised',
    'Kollar kalkık ayakta duruş',
  ),
  'Chair-supported forward fold' => localeText(
    context,
    'Chair-supported forward fold',
    'Sandalye destekli öne eğilme',
  ),
  'Soften your knees a little.' => localeText(
    context,
    'Soften your knees a little.',
    'Dizlerini biraz yumuşat.',
  ),
  'Keep your neck in line with your back.' => localeText(
    context,
    'Keep your neck in line with your back.',
    'Boynunu sırtınla aynı hizada tut.',
  ),
  'Shallow fold, hands on thighs' => localeText(
    context,
    'Shallow fold, hands on thighs',
    'Eller uylukta sığ öne eğilme',
  ),
  'Halfway lift' => localeText(context, 'Halfway lift', 'Yarım kalkış'),
  'Wall-supported half hinge' => localeText(
    context,
    'Wall-supported half hinge',
    'Duvar destekli yarım menteşe',
  ),
  'Make the hinge smaller.' => localeText(
    context,
    'Make the hinge smaller.',
    'Öne eğilmeyi küçült.',
  ),
  'Wall dog preparation' => localeText(
    context,
    'Wall dog preparation',
    'Duvarda köpek hazırlığı',
  ),
  'Small chair pose (Utkatasana adaptation)' => localeText(
    context,
    'Small chair pose (Utkatasana adaptation)',
    'Küçük sandalye duruşu (Utkatasana uyarlaması)',
  ),
  'Choose a smaller knee bend.' => localeText(
    context,
    'Choose a smaller knee bend.',
    'Dizlerini daha az bük.',
  ),
  'Lift your chest a little.' => localeText(
    context,
    'Lift your chest a little.',
    'Göğsünü biraz kaldır.',
  ),
  'Shin-supported forward fold' => localeText(
    context,
    'Shin-supported forward fold',
    'Eller kaval kemiğinde öne eğilme',
  ),
  'Keep your knees clearly bent.' => localeText(
    context,
    'Keep your knees clearly bent.',
    'Dizlerini belirgin biçimde bükük tut.',
  ),
  'Wide-leg fold to a chair' => localeText(
    context,
    'Wide-leg fold to a chair',
    'Geniş bacakla sandalyeye öne eğilme',
  ),
  'Keep your head above your hips; fold a little less.' => localeText(
    context,
    'Keep your head above your hips; fold a little less.',
    'Başını kalçalarının üstünde tut; biraz daha az eğil.',
  ),
  'Warrior I with a short stance' => localeText(
    context,
    'Warrior I with a short stance',
    'Kısa adımlı Savaşçı I',
  ),
  'Bend the front knee a little less.' => localeText(
    context,
    'Bend the front knee a little less.',
    'Öndeki dizini biraz daha az bük.',
  ),
  'Supported staggered stance' => localeText(
    context,
    'Supported staggered stance',
    'Destekli kademeli duruş',
  ),
  'Keep your torso upright.' => localeText(
    context,
    'Keep your torso upright.',
    'Gövdeni dik tut.',
  ),
  'Supported hinge balance' => localeText(
    context,
    'Supported hinge balance',
    'Destekli menteşe dengesi',
  ),
  'Keep the standing knee soft.' => localeText(
    context,
    'Keep the standing knee soft.',
    'Bastığın dizi yumuşak tut.',
  ),
  'Small standing back extension' => localeText(
    context,
    'Small standing back extension',
    'Ayakta küçük geriye uzanma',
  ),
  'Make the extension smaller.' => localeText(
    context,
    'Make the extension smaller.',
    'Geriye uzanmayı küçült.',
  ),
  'Keep your neck long; look forward.' => localeText(
    context,
    'Keep your neck long; look forward.',
    'Boynunu uzun tut; ileri bak.',
  ),
  'Tree with a wall' => localeText(
    context,
    'Tree with a wall',
    'Duvarla ağaç duruşu',
  ),
  'Upright seat on a chair' => localeText(
    context,
    'Upright seat on a chair',
    'Sandalyede dik oturuş',
  ),
  'Sit tall: shoulders over hips.' => localeText(
    context,
    'Sit tall: shoulders over hips.',
    'Dik otur: omuzlar kalçaların üstünde.',
  ),
  'Seated small arm arc' => localeText(
    context,
    'Seated small arm arc',
    'Oturarak küçük kol yayı',
  ),
  'Keep the arm below shoulder height.' => localeText(
    context,
    'Keep the arm below shoulder height.',
    'Kolunu omuz hizasının altında tut.',
  ),
  'Keep your trunk still; a smaller movement is fine.' => localeText(
    context,
    'Keep your trunk still; a smaller movement is fine.',
    'Gövdeni sabit tut; daha küçük bir hareket de olur.',
  ),
  'Seated foot lift' => localeText(
    context,
    'Seated foot lift',
    'Oturarak ayak kaldırma',
  ),
  'Seated spine rounding' => localeText(
    context,
    'Seated spine rounding',
    'Oturarak omurgayı yuvarlama',
  ),
  'Let your head follow your spine; no lower.' => localeText(
    context,
    'Let your head follow your spine; no lower.',
    'Başın omurganı izlesin; daha aşağı inmesin.',
  ),
  'Seated spine lengthening' => localeText(
    context,
    'Seated spine lengthening',
    'Oturarak omurgayı uzatma',
  ),
  'Look ahead, not up.' => localeText(
    context,
    'Look ahead, not up.',
    'Yukarı değil, ileri bak.',
  ),
  _ => localeText(context, english, turkish),
};

/// English keys covered above (for the drift test).
const Set<String> kCameraCatalogCopyKeys = <String>{
  'Mountain stance',
  'Bring your shoulders over your hips.',
  'Let your ribs come back over your pelvis.',
  'Let your head rest above your shoulders.',
  'Standing with arms raised',
  'Chair-supported forward fold',
  'Soften your knees a little.',
  'Keep your neck in line with your back.',
  'Shallow fold, hands on thighs',
  'Halfway lift',
  'Wall-supported half hinge',
  'Make the hinge smaller.',
  'Wall dog preparation',
  'Small chair pose (Utkatasana adaptation)',
  'Choose a smaller knee bend.',
  'Lift your chest a little.',
  'Shin-supported forward fold',
  'Keep your knees clearly bent.',
  'Wide-leg fold to a chair',
  'Keep your head above your hips; fold a little less.',
  'Warrior I with a short stance',
  'Bend the front knee a little less.',
  'Supported staggered stance',
  'Keep your torso upright.',
  'Supported hinge balance',
  'Keep the standing knee soft.',
  'Small standing back extension',
  'Make the extension smaller.',
  'Keep your neck long; look forward.',
  'Tree with a wall',
  'Upright seat on a chair',
  'Sit tall: shoulders over hips.',
  'Seated small arm arc',
  'Keep the arm below shoulder height.',
  'Keep your trunk still; a smaller movement is fine.',
  'Seated foot lift',
  'Seated spine rounding',
  'Let your head follow your spine; no lower.',
  'Seated spine lengthening',
  'Look ahead, not up.',
};
