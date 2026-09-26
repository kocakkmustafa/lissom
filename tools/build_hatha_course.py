#!/usr/bin/env python3
"""Build the original, bilingual Hatha course asset from reviewed lesson copy.

Each lesson has its own teaching, practice, reflection, adaptation and media
shot. The JSON is checked into the app; this script keeps it reproducible.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUTPUT = ROOT / "config/courses/hatha.v1.json"


def text_pair(raw):
    parts = raw.split(" | ")
    if len(parts) != 2 or any(not part.strip() for part in parts):
        raise ValueError(f"Expected English | Turkish: {raw}")
    return {"en": parts[0].strip(), "tr": parts[1].strip()}


def lesson(lesson_id, title, objective, step_a, step_b, practice, check,
           adaptation, shot, minutes=10, stop=None, sources=None):
    stop = stop or (
        "Stop if sharp pain, dizziness, or unusual breathlessness appears."
        " | Keskin ağrı, baş dönmesi veya alışılmadık nefes darlığı olursa dur."
    )
    return {
        "id": lesson_id,
        "title": text_pair(title),
        "objective": text_pair(objective),
        "steps": [text_pair(step_a), text_pair(step_b)],
        "practice": text_pair(practice),
        "selfCheck": text_pair(check),
        "adaptation": text_pair(adaptation),
        "stopSignal": text_pair(stop),
        "mediaBrief": text_pair(shot),
        "minutes": minutes,
        "sourceIds": list(sources or ("ycb", "nccih")),
        "evidenceMode": "self_report",
    }


def module(module_id, title, outcome, lessons):
    return {
        "id": module_id,
        "title": text_pair(title),
        "outcome": text_pair(outcome),
        "lessons": lessons,
    }


MODULES = [
    module("arrival", "Arrival and choice | Başlangıç ve seçim",
           "Set up a comfortable space and practice without forcing a shape."
           " | Rahat bir alan kur ve bedeni bir şekle zorlamadan çalış.", [
        lesson("h01", "Practice boundaries | Çalışma sınırları",
               "Recognize what a phone course can guide and when to stop."
               " | Telefon kursunun neyi yönlendirdiğini ve ne zaman duracağını ayırt et.",
               "Clear a stable floor space and choose a mat, chair and wall within reach."
               " | Sabit bir zemin aç; mat, sandalye ve duvarı erişilebilir tut.",
               "Practice is optional at each step; pain is not a target and the camera does not judge safety."
               " | Her adım seçime bağlıdır; ağrı hedef değildir ve kamera güvenlik hükmü vermez.",
               "Point to your support, an exit route and a comfortable rest position before moving."
               " | Hareket etmeden destek noktanı, çıkış yolunu ve rahat dinlenme konumunu belirle.",
               "Can you describe one reason to pause and one easier option?"
               " | Durmak için bir neden ve daha kolay bir seçenek söyleyebiliyor musun?",
               "With pregnancy, injury or a chronic condition, choose gentle options and ask a qualified clinician about personal limits."
               " | Gebelik, sakatlık veya kronik durumda hafif seçenekleri seç; kişisel sınırları sağlık uzmanına danış.",
               "Show mat, stable chair and wall, then a learner choosing rest; no camera score overlay."
               " | Matı, sabit sandalyeyi ve duvarı, ardından dinlenmeyi seçen kişiyi göster; kamera puanı bindirme.",
               minutes=6, sources=("ycb", "nccih", "acog")),
        lesson("h02", "Natural breath | Doğal nefes",
               "Notice breathing without controlling or holding it."
               " | Nefesi tutmadan veya zorlamadan fark et.",
               "Sit supported or lie comfortably; allow the inhale and exhale to arrive at their own pace."
               " | Destekli otur veya rahat uzan; nefesin geliş gidişini kendi ritminde izle.",
               "Notice movement around the ribs and abdomen without trying to make breaths deep."
               " | Nefesi derinleştirmeye çalışmadan kaburga ve karın çevresindeki hareketi gözle.",
               "For two minutes, name each exhale silently and return attention when it wanders."
               " | İki dakika her verişi içinden adlandır; dikkat dağılınca geri dön.",
               "Could you breathe and speak comfortably throughout?"
               " | Çalışma boyunca rahat nefes alıp konuşabildin mi?",
               "Use a chair, side lying or shorter observation; avoid any breath retention."
               " | Sandalye, yan yatış veya kısa gözlem seç; nefes tutma.",
               "Close view of relaxed ribs then wide supported-seat view; depict natural pace, not a forced timer."
               " | Rahat kaburgaya yakın, destekli oturuşa geniş açı; zorunlu zamanlayıcı değil doğal ritim göster.",
               minutes=6),
        lesson("h03", "Mountain stance | Dağ duruşu",
               "Find a balanced standing base for later poses."
               " | Sonraki pozlar için dengeli ayakta temel bul.",
               "Stand with feet about hip width apart and soften the knees; feel heel and forefoot contact."
               " | Ayakları yaklaşık kalça genişliğinde aç, dizleri rahat bırak; topuk ve ön ayak temasını hisset.",
               "Let arms rest and lengthen through the crown without pushing the ribs forward."
               " | Kolları serbest bırak, kaburgayı öne itmeden baş tepesinden uzamayı düşün.",
               "Stand for three easy breaths, step away, then return twice and compare the feeling."
               " | Üç rahat nefes dur, ayrıl, sonra iki kez dönüp hissi karşılaştır.",
               "Can you shift weight gently without gripping your toes or locking the knees?"
               " | Parmakları sıkmadan veya dizleri kilitlemeden ağırlığı hafifçe değiştirebiliyor musun?",
               "Keep a hand on the wall or practise seated foot contact if standing is uncomfortable."
               " | Ayakta durmak rahatsızsa elini duvara koy veya oturarak ayak temasını çalış.",
               "Front and side full-body Tadasana; show foot-contact close-up and a wall-supported option."
               " | Önden ve yandan tam beden Tadasana; ayak teması yakın planı ve duvar desteğini göster.",
               minutes=8, sources=("ycb", "nccih", "adriene_tadasana")),
        lesson("h04", "Supported easy seat | Destekli rahat oturuş",
               "Choose a seat that permits an unforced upright spine."
               " | Zorlamadan dik oturabildiğin bir yer seç.",
               "Sit on a folded blanket with shins loosely crossed, or on a chair with feet grounded."
               " | Kaval kemiklerini gevşek çaprazlayıp katlı battaniyeye ya da ayaklar yerde sandalyeye otur.",
               "Rest hands on thighs and let the shoulders settle while breathing normally."
               " | Elleri uyluklara bırak, normal nefes alırken omuzların yerleşmesine izin ver.",
               "Try two one-minute seats, changing the cross of the legs between them."
               " | İki kez birer dakika otur; arada bacakların çaprazını değiştir.",
               "Do hips and knees have a comfortable support, without pressure to look symmetrical?"
               " | Simetrik görünme zorunluluğu olmadan kalça ve dizlerin rahat destek buluyor mu?",
               "Choose a chair or cushions under the knees; do not force lotus position."
               " | Sandalye veya diz altı minder seç; lotus pozuna zorlama.",
               "Compare blanket-supported Sukhasana and chair seat at front and side views."
               " | Battaniye destekli Sukhasana ile sandalye oturuşunu önden ve yandan karşılaştır.",
               minutes=7),
        lesson("h05", "Gentle joint preparation | Hafif eklem hazırlığı",
               "Move neck, shoulders, wrists and ankles within a comfortable range."
               " | Boyun, omuz, bilek ve ayak bileklerini rahat aralıkta hareket ettir.",
               "In a chair, turn the head a little each way and roll shoulders slowly without tipping back."
               " | Sandalyede başı az sağa sola çevir, geriye atmadan omuzları yavaş yuvarla.",
               "Open and close the hands, then circle each ankle with the foot lifted slightly."
               " | Elleri açıp kapat, sonra ayağı hafif kaldırarak her ayak bileğini çevir.",
               "Make five unhurried movements in each comfortable direction; rest between regions."
               " | Her rahat yönde acele etmeden beş hareket yap; bölgeler arasında dinlen.",
               "Can you stop short of a pinching sensation and keep the breath easy?"
               " | Sıkışma hissinden önce durup nefesi rahat tutabiliyor musun?",
               "Make smaller motions or omit a region that feels uncomfortable; seek individual advice for recent injury."
               " | Hareketi küçült veya belirti veren bölgeyi atla; yeni sakatlıkta kişisel görüş al.",
               "Seated close-ups of four regions, one at a time, with small-range and rest alternatives."
               " | Dört bölgeyi sırayla oturarak yakın planda göster; küçük aralık ve dinlenme seçeneği ekle.",
               minutes=8),
        lesson("h06", "First eight-minute practice | İlk sekiz dakikalık çalışma",
               "Connect setup, natural breath, mountain and supported rest."
               " | Hazırlık, doğal nefes, dağ duruşu ve destekli dinlenmeyi bağla.",
               "Start seated for two minutes, prepare the joints, then rise slowly into mountain."
               " | İki dakika otur, eklemleri hazırla, sonra yavaşça dağ duruşuna kalk.",
               "Return to the chair or mat for quiet breathing; record effort, not a pose grade."
               " | Sessiz nefes için sandalyeye veya mata dön; poz puanı değil çalışma kaydı tut.",
               "Follow the sequence once and repeat only if it still feels comfortable."
               " | Sırayı bir kez uygula; yalnız hâlâ rahat geliyorsa tekrarla.",
               "Could you choose a smaller range or rest without losing the sequence?"
               " | Sırayı kaybetmeden daha küçük hareket veya dinlenme seçebildin mi?",
               "All standing moments may be done beside a wall or replaced by chair sitting."
               " | Ayakta bölümler duvar yanında yapılabilir veya sandalyede oturuşla değiştirilebilir.",
               "Uncut wide shot of seat-to-stand-to-rest sequence with optional chair branch."
               " | Otur-kalk-dinlen dizisini ve sandalye seçeneğini kesintisiz geniş açıyla göster.",
               minutes=8),
    ]),
    module("standing", "Standing foundations | Ayakta temel duruşlar",
           "Explore controlled standing shapes with support before combining them."
           " | Pozları birleştirmeden önce destekle ayakta kontrollü şekilleri öğren.", [
        lesson("h07", "Supported side reach | Destekli yana uzanma",
               "Distinguish a gentle side reach from pushing the lower back."
               " | Hafif yana uzanmayı bele yüklenmekten ayır.",
               "From mountain, place one hand at the hip and raise the other arm only as far as comfortable."
               " | Dağ duruşundan bir eli kalçaya koy, öteki kolu yalnız rahat ettiği kadar kaldır.",
               "Reach upward first, then a little sideways; return to centre before changing sides."
               " | Önce yukarı, sonra biraz yana uzan; taraf değiştirmeden merkeze dön.",
               "Do three slow reaches each way with a normal breath."
               " | Normal nefesle her yana üç yavaş uzanma yap.",
               "Is the movement spread along the side body rather than jammed at one point?"
               " | Hareket tek noktada sıkışmak yerine yan gövdeye dağılıyor mu?",
               "Keep the reaching hand below shoulder height or sit in a chair."
               " | Uzanma kolunu omuzun altında tut veya sandalyede otur.",
               "Front view shows short and longer side reach; side view shows return to centre."
               " | Önden kısa ve uzun yana uzanma, yandan merkeze dönüş göster.",
               minutes=8),
        lesson("h08", "Gentle standing turn | Hafif ayakta dönüş",
               "Turn through a comfortable range while the feet stay grounded."
               " | Ayaklar yerde kalırken rahat bir aralıkta dön.",
               "Place feet hip width apart, soften knees and let arms rest near the ribs."
               " | Ayakları kalça genişliğinde aç, dizleri yumuşat, kolları kaburgaya yakın tut.",
               "Look and turn a little to one side; come back through centre before the other."
               " | Bir yana az bakıp dön; diğer yana geçmeden merkezden geç.",
               "Repeat three alternating turns without swinging the arms for momentum."
               " | Kolları savurmadan üç dönüş çifti yap.",
               "Can you keep the movement smooth and stop before a pinch in back or neck?"
               " | Hareketi akıcı tutup sırt veya boyunda sıkışmadan önce durabiliyor musun?",
               "Use a chair and turn the head less; skip twisting if advised against it."
               " | Sandalye kullanıp başı daha az çevir; dönüşten kaçınman söylendiyse atla.",
               "Front and overhead-friendly view of Kati Chakrasana range, no extreme end position."
               " | Kati Chakrasana aralığını önden ve üstten anlaşılır göster; uç konuma zorlama.",
               minutes=8),
        lesson("h09", "Supported triangle | Destekli üçgen",
               "Learn the hip-led reach of Trikonasana without chasing the floor."
               " | Zemine yetişmeye çalışmadan Trikonasana'nın kalçadan uzanışını öğren.",
               "Take a comfortable wide stance and turn the front foot out slightly; keep a chair beside it."
               " | Rahat geniş dur, öndeki ayağı biraz dışa çevir; yanına sandalye koy.",
               "Reach over the front leg, rest the lower hand on a chair and rise back with control."
               " | Ön bacak üzerinden uzan, alt eli sandalyeye koy ve kontrollü doğrul.",
               "Hold for two natural breaths per side, then repeat once."
               " | Her tarafta iki doğal nefes kal, sonra bir kez tekrarla.",
               "Can you see both feet grounded and speak comfortably without straining the neck?"
               " | İki ayağın da yerde mi; boynu zorlamadan rahat konuşabiliyor musun?",
               "Narrow the stance and keep both hands on the chair if balance is uncertain."
               " | Denge belirsizse adımı daraltıp iki eli sandalyede tut.",
               "Wide front and side views of supported Trikonasana, chair height and short stance."
               " | Destekli Trikonasana'yı önden/yandan, sandalye yüksekliği ve kısa adımla göster.",
               minutes=11),
        lesson("h10", "Tree with a wall | Duvar yanında ağaç",
               "Develop a calm balance choice without forcing the standing knee."
               " | Destek bacağını zorlamadan sakin denge seçeneği geliştir.",
               "Stand next to a wall; shift weight into one foot and place the other toes on the floor."
               " | Duvar yanında dur; ağırlığı bir ayağa al, öteki ayağın parmakları yerde kalsın.",
               "If steady, rest the free foot against the ankle or calf, never pressing into the knee joint."
               " | Dengeliyse boş ayağı ayak bileğine veya baldıra koy; diz eklemine bastırma.",
               "Try three easy breaths each side, hand on wall whenever needed."
               " | Gerektiğinde el duvardayken her yanda üç rahat nefes dene.",
               "Did you choose a foot height that allowed a soft standing knee and easy breath?"
               " | Destek dizini rahat ve nefesi kolay tutan ayak yüksekliği seçtin mi?",
               "Keep toes on the floor or both hands on a stable chair."
               " | Parmakları yerde tut veya iki eli sabit sandalyeye koy.",
               "Full-body Vrikshasana progression: toe kickstand, ankle/calf, wall; no knee placement."
               " | Tam beden Vrikshasana sırası: parmak yerde, bilek/baldır, duvar; diz üzerine ayak yok.",
               minutes=10),
        lesson("h11", "Gentle forward fold | Hafif öne katlanma",
               "Fold from the hips with an easy return rather than reaching the toes."
               " | Ayak parmaklarına yetişmeye uğraşmadan kalçadan katlanıp rahat doğrul.",
               "Place hands on a chair, bend knees and send hips back while keeping space in the abdomen."
               " | Elleri sandalyeye koy, dizleri büküp karın için alan bırakarak kalçayı geriye gönder.",
               "Pause at your own comfortable depth, then press through the feet to stand."
               " | Kendi rahat derinliğinde dur, ardından ayaklardan güç alıp doğrul.",
               "Do four short folds, using the same controlled return each time."
               " | Her seferinde kontrollü doğrularak dört kısa katlanma yap.",
               "Could you keep breathing without pulling on the back or bouncing?"
               " | Sırtı çekiştirmeden veya zıplamadan nefes alabiliyor musun?",
               "Raise the chair support or perform a seated hip hinge."
               " | Sandalye desteğini yükselt veya oturarak kalçadan öne eğil.",
               "Side view of Padahastasana preparation with bent knees and chair; show controlled exit."
               " | Bükülü diz ve sandalyeyle Padahastasana hazırlığını yandan göster; kontrollü çıkışı ekle.",
               minutes=9),
        lesson("h12", "Standing sequence | Ayakta duruş dizisi",
               "Connect mountain, reach, triangle, tree and fold without losing options."
               " | Dağ, uzanma, üçgen, ağaç ve katlanmayı seçeneklerini koruyarak bağla.",
               "Start and finish in mountain; practise each side before changing posture."
               " | Dağ duruşuyla başla ve bitir; poz değiştirmeden önce iki tarafı da çalış.",
               "Pause at a chair between balance and fold; there is no required pace."
               " | Denge ile katlanma arasında sandalyede dur; zorunlu tempo yok.",
               "Run one 12-minute sequence, note which support helped and repeat on another day."
               " | Bir 12 dakikalık dizi yap, hangi desteğin yardım ettiğini not et ve başka gün tekrarla.",
               "Could you name the easier form of each posture before entering it?"
               " | Her poza girmeden kolay biçimini söyleyebiliyor musun?",
               "Use wall and chair for the whole sequence, or practise it seated."
               " | Tüm dizide duvar ve sandalye kullan veya oturarak çalış.",
               "Uncut 12-minute front/side sequence; lower corner labels each choice and rest branch."
               " | Kesintisiz 12 dakikalık ön/yan dizi; köşede her seçenek ve dinlenme dalı göster.",
               minutes=12),
    ]),
    module("floor_preparation", "Hands, knees and prone work | El, diz ve yüzüstü çalışmalar",
           "Enter and leave low postures with choices for wrists, knees and abdomen."
           " | Alçak pozlara bilek, diz ve karın seçenekleriyle girip çık.", [
        lesson("h13", "Tabletop foundation | Masa pozunun temeli",
               "Set up hands and knees without treating one alignment as universal."
               " | Tek bir hizayı herkese dayatmadan el ve diz yerleşimini kur.",
               "Place a folded blanket under the knees and hands beneath comfortable shoulder reach."
               " | Diz altına katlı battaniye koy, elleri omuzların rahat uzandığı yere yerleştir.",
               "Move hips slightly back and forward to find a position where wrists and knees can rest."
               " | Bilek ve dizlerin rahat ettiği yeri bulmak için kalçayı az geriye ve öne taşı.",
               "Try three short tabletop holds with seated rest between them."
               " | Aralarında oturarak dinlenip üç kısa masa duruşu dene.",
               "Can you unload the hands by moving back or widening them when needed?"
               " | Gerektiğinde geriye giderek veya elleri açarak yükü azaltabiliyor musun?",
               "Place forearms on a chair or skip weight bearing for sensitive wrists or knees."
               " | Bilek veya diz hassassa ön kolları sandalyeye koy ya da yük bindiren kısmı atla.",
               "Side and front setup; show knee blanket, hand spacing and chair-on-forearms option."
               " | Yandan/önden kurulum; diz battaniyesi, el açıklığı ve sandalyede ön kol seçeneği.",
               minutes=8),
        lesson("h14", "Cat and cow | Kedi ve inek",
               "Coordinate gentle spinal movement with an ordinary breath."
               " | Yumuşak omurga hareketini olağan nefesle eşleştir.",
               "From tabletop, exhale while rounding only as much as comfortable."
               " | Masadan nefes verirken yalnız rahat olduğu kadar yuvarlan.",
               "Inhale and return through neutral into a small opening; avoid throwing the head back."
               " | Nefes alıp nötrden küçük bir açılmaya geç; başı geriye fırlatma.",
               "Move slowly for six cycles, then rest on a chair or mat."
               " | Altı çevrim yavaş hareket et; sonra sandalye veya matta dinlen.",
               "Did the breath continue without a forced arch or held end point?"
               " | Nefes, zorlanmış bel kavsi veya tutulmuş uç poz olmadan sürdü mü?",
               "Perform the same small spinal motion seated with hands on thighs."
               " | Aynı küçük omurga hareketini eller uylukta oturarak yap.",
               "Continuous side view of small and seated Marjaryasana-Bitilasana cycles, with breath labels."
               " | Küçük ve oturarak yapılan Marjaryasana-Bitilasana çevrimlerini yandan kesintisiz göster; nefes etiketleri ekle.",
               minutes=9),
        lesson("h15", "Resting child shape | Dinlenme çocuk biçimi",
               "Use Shashankasana as an optional rest, not a required depth."
               " | Shashankasana'yı zorunlu derinlik değil, seçilebilir dinlenme olarak kullan.",
               "From hands and knees, bring hips toward heels only as far as knees and abdomen permit."
               " | El-dizden kalçayı yalnız diz ve karnın izin verdiği kadar topuklara götür.",
               "Rest forehead on stacked hands or a cushion and return through tabletop slowly."
               " | Alnı üst üste ellere veya mindere yasla, masadan yavaşça çık.",
               "Take three comfortable breaths, then choose a chair rest for comparison."
               " | Üç rahat nefes al; sonra karşılaştırmak için sandalyede dinlenmeyi seç.",
               "Which rest position kept breathing easy and the knees comfortable?"
               " | Hangi dinlenme konumu nefesi kolay, dizleri rahat tuttu?",
               "Widen knees only if comfortable; use a chair or side rest for pregnancy or knee discomfort."
               " | Rahatsa dizleri aç; gebelik veya diz belirtisinde sandalye ya da yan dinlenme seç.",
               "Side view of cushion-supported Shashankasana and side-by-side chair-rest choice."
               " | Minder destekli Shashankasana'yı yandan, sandalye dinlenmesini yanında göster.",
               minutes=8, sources=("ycb", "nccih", "acog")),
        lesson("h16", "Crocodile rest | Timsah dinlenmesi",
               "Explore a prone rest and recognize when another position is better."
               " | Yüzüstü dinlenmeyi dene ve başka konumun ne zaman daha iyi olduğunu ayırt et.",
               "Lie face down only if comfortable, with forearms folded and head turned gently to one side."
               " | Rahatsa yüzüstü yat, ön kolları katla ve başı hafifçe bir yana çevir.",
               "Change the head direction after several breaths; leave the posture through the side."
               " | Birkaç nefes sonra baş yönünü değiştir; pozdan yana dönerek çık.",
               "Rest for one minute, then compare with side lying or a supported chair."
               " | Bir dakika dinlen, sonra yan yatış veya destekli sandalyeyle karşılaştır.",
               "Is the abdomen uncompressed and the neck comfortable?"
               " | Karın sıkışmadan, boyun rahat kalıyor mu?",
               "Skip prone lying in pregnancy or if it feels uncomfortable; use side lying or a chair."
               " | Gebelikte veya rahatsız hissettiğinde yüzüstünü atla; yan yatış veya sandalye kullan.",
               "Wide Makarasana entry/exit and immediate side-lying alternative; no claim that it suits everyone."
               " | Makarasana giriş/çıkışını ve yan yatış seçeneğini geniş açıyla göster; herkese uygunluk iddiası kurma.",
               minutes=7, sources=("ycb", "nccih", "acog")),
        lesson("h17", "Low cobra | Alçak kobra",
               "Lift the chest a little without pushing through the lower back."
               " | Bele yüklenmeden göğsü az kaldır.",
               "From comfortable prone rest, place hands beside the ribs and keep elbows near the sides."
               " | Rahat yüzüstü dinlenmeden elleri kaburga yanına koy, dirsekleri gövdeye yakın tut.",
               "Raise the chest a little using the upper back; lower with control before the breath strains."
               " | Üst sırtla göğsü az kaldır; nefes zorlanmadan kontrollü indir.",
               "Try three short lifts without pressing the hands hard into the floor."
               " | Elleri zemine sert bastırmadan üç kısa yükseliş dene.",
               "Can you lower smoothly and avoid pinching in the lower back?"
               " | Yumuşak inip belde sıkışmadan kalabiliyor musun?",
               "For wrist or back discomfort, use a smaller chest lift or stay in side rest; skip prone during pregnancy."
               " | Bilek veya bel rahatsızlığında kaldırmayı küçült ya da yan dinlen; gebelikte yüzüstünü atla.",
               "Side close view of low Bhujangasana, small chest lift and controlled return; show skip branch."
               " | Alçak Bhujangasana'yı yandan yakın göster; küçük yükseliş, kontrollü iniş ve atlama dalı ekle.",
               minutes=9, sources=("ycb", "nccih", "acog")),
        lesson("h18", "Low-posture sequence | Alçak poz dizisi",
               "Move through tabletop, cat-cow, optional child rest and low cobra."
               " | Masa, kedi-inek, seçmeli çocuk dinlenmesi ve alçak kobrayı birleştir.",
               "Set supports first; use the breath to slow transitions, not to force their timing."
               " | Destekleri önce yerleştir; nefesi geçişleri yavaşlatmak için kullan, zamana zorlama.",
               "After each shape, return to a stable neutral or chair before the next."
               " | Her şekilden sonra sonrakine geçmeden sabit nötre veya sandalyeye dön.",
               "Practise one 12-minute circuit with your chosen exclusions and rests."
               " | Seçtiğin atlamalar ve dinlenmelerle bir 12 dakikalık tur yap.",
               "Can you explain why you chose or skipped prone work today?"
               " | Bugün yüzüstü çalışmayı neden seçtiğini veya atladığını açıklayabiliyor musun?",
               "The whole circuit may stay seated: small cat-cow followed by chair rest."
               " | Tüm tur oturarak yapılabilir: küçük kedi-inek ve sandalye dinlenmesi.",
               "Uncut low-posture circuit with clear seated/prone-skip branch and neutral between poses."
               " | Alçak dizi kesintisiz göster; oturma/yüzüstünü atlama dalı ve aralarda nötr duruş olsun.",
               minutes=12),
    ]),
    module("seated", "Seated mobility and choices | Oturarak hareket ve seçenekler",
           "Practice seated postures with support and learn to leave stretches gently."
           " | Oturarak pozları destekle uygula ve esnemeden yumuşak çıkmayı öğren.", [
        lesson("h19", "Staff pose with support | Destekli asa duruşu",
               "Sit upright with legs extended without forcing knees flat."
               " | Dizleri yere bastırmadan bacaklar uzanmış şekilde otur.",
               "Sit on a folded blanket, bend knees a little and place hands beside the hips."
               " | Katlı battaniyeye otur, dizleri az bük ve elleri kalçanın yanına koy.",
               "Lengthen through the crown as you breathe, then shake out the legs."
               " | Nefes alırken baş tepesinden uzamayı düşün, sonra bacakları gevşet.",
               "Hold Dandasana for three easy breaths, twice, resting between attempts."
               " | Dandasana'da üç rahat nefes, iki kez kal; arada dinlen.",
               "Can you sit without rounding from effort or gripping the thighs?"
               " | Çabayla yuvarlanmadan veya uylukları sıkmadan oturabiliyor musun?",
               "Use a higher blanket or sit on a chair with feet grounded."
               " | Daha yüksek battaniye veya ayaklar yerde sandalye kullan.",
               "Side view of Dandasana with straight and softly bent knees, then a chair equivalent."
               " | Düz ve hafif bükülü dizli Dandasana'yı yandan, ardından sandalye eşdeğerini göster.",
               minutes=8),
        lesson("h20", "Supported bound-angle seat | Destekli kelebek oturuşu",
               "Explore hip opening without pressing the knees down."
               " | Dizleri aşağı bastırmadan kalça açıklığını keşfet.",
               "Bring soles near each other at a comfortable distance and place cushions beneath the knees."
               " | Ayak tabanlarını rahat uzaklıkta yaklaştır, diz altına minder koy.",
               "Hold the ankles lightly, stay upright and release by bringing knees together with the hands."
               " | Ayak bileklerini hafif tut, dik kal ve dizleri ellerle birleştirerek çık.",
               "Take five natural breaths, then stretch legs out and compare sides."
               " | Beş doğal nefes al, bacakları uzat ve iki tarafın hissini karşılaştır.",
               "Could you avoid bouncing and keep knees supported throughout?"
               " | Zıplamadan ve dizleri baştan sona destekleyerek kalabildin mi?",
               "Sit on a chair with feet apart if floor sitting or hip opening is uncomfortable."
               " | Yerde oturma veya kalça açılması rahatsızsa ayaklar açık sandalyeye otur.",
               "Front view of Bhadrasana with knee cushions and a no-pressure exit; chair option."
               " | Diz minderli Bhadrasana'yı önden, baskısız çıkışla ve sandalye seçeneğiyle göster.",
               minutes=9),
        lesson("h21", "Kneeling seat or chair | Diz üstü oturuş veya sandalye",
               "Choose between a brief Vajrasana and an equally valid chair seat."
               " | Kısa Vajrasana ile eşdeğer sandalye oturuşu arasında seçim yap.",
               "Place a folded blanket beneath shins or between heels and seat; enter slowly with a wall nearby."
               " | Kaval altına veya topukla oturma arasına katlı battaniye koy; duvar yakındayken yavaş gir.",
               "Rest hands on thighs for two breaths, then lift through hands and change to the chair."
               " | İki nefes elleri uylukta tut, sonra ellerle yükselip sandalyeye geç.",
               "Compare two short, comfortable seats rather than increasing hold time."
               " | Tutma süresini uzatmak yerine iki kısa rahat oturuşu karşılaştır.",
               "Are knees and ankles free of pressure, and is leaving the posture easy?"
               " | Diz ve ayak bilekleri baskısız mı, pozdan çıkmak kolay mı?",
               "Use the chair for knee, ankle or pregnancy discomfort; no kneeling is required."
               " | Diz, bilek veya gebelik rahatsızlığında sandalye seç; diz üstü zorunlu değil.",
               "Side view of blanket-supported Vajrasana and equal-size chair demonstration, including exit."
               " | Battaniyeli Vajrasana ve eşit ağırlıkta sandalye gösterimi; çıkış da gösterilsin.",
               minutes=7, sources=("ycb", "nccih", "acog")),
        lesson("h22", "Seated gentle turn | Oturarak hafif dönüş",
               "Initiate a small Vakrasana turn without using the arms as levers."
               " | Kolları kaldıraç yapmadan küçük Vakrasana dönüşü başlat.",
               "Sit tall on a chair or blanket and place hands loosely on thighs."
               " | Sandalye veya battaniyede dik otur, elleri gevşekçe uyluklara koy.",
               "Turn the chest a little on an exhale; return to centre before turning the other way."
               " | Nefes verirken göğsü az çevir; öteki yöne dönmeden merkeze gel.",
               "Do three small turns per side, pausing at centre each time."
               " | Her yana üç küçük dönüş yap; her seferinde merkezde dur.",
               "Can you keep both sitting bones supported and breathe without strain?"
               " | İki oturma kemiği destekli kalırken zorlanmadan nefes alabiliyor musun?",
               "Reduce range or choose only head-and-eye turning if spinal rotation is uncomfortable."
               " | Omurga dönüşü rahatsızsa aralığı küçült veya yalnız baş-göz dönüşü yap.",
               "Front and rear three-quarter view of chair Vakrasana, no arm pull or forced end range."
               " | Sandalye Vakrasana'yı önden ve üç çeyrek arkadan göster; kol çekişi/uç zorlama olmasın.",
               minutes=9),
        lesson("h23", "Seated forward reach | Oturarak öne uzanma",
               "Use a hip-led Paschimottanasana preparation without chasing the feet."
               " | Ayaklara yetişmeye uğraşmadan kalçadan Paschimottanasana hazırlığı yap.",
               "Sit on a blanket with bent knees and place hands on shins or a chair in front."
               " | Bükülü dizlerle battaniyeye otur, elleri kaval kemiğine veya öndeki sandalyeye koy.",
               "Reach the chest gently forward from hips and return upright before the breath tightens."
               " | Göğsü kalçadan yumuşakça öne uzat; nefes sıkışmadan dikleş.",
               "Try four short reaches with a pause between them; avoid bouncing."
               " | Aralarda durarak dört kısa uzanma dene; zıplama.",
               "Can you return to upright without pulling on the legs?"
               " | Bacakları çekiştirmeden dik oturuşa dönebiliyor musun?",
               "Use a chair and fold only slightly, or skip if it worsens discomfort."
               " | Sandalyede yalnız biraz öne eğil veya belirtileri artırıyorsa atla.",
               "Side view shows bent knees, hand support and a short reach, then controlled return."
               " | Yandan bükülü diz, el desteği ve kısa uzanma; ardından kontrollü dönüş göster.",
               minutes=9),
        lesson("h24", "Seated sequence | Oturma dizisi",
               "Combine staff, supported bound angle, gentle turn and forward reach."
               " | Asa, destekli kelebek, hafif dönüş ve öne uzanmayı birleştir.",
               "Choose chair or floor before starting and put supports within reach."
               " | Başlamadan sandalye veya zemini seç, destekleri yakına koy.",
               "Return to a neutral seat after each shape and change sides deliberately."
               " | Her şekilden sonra nötr oturuşa dön ve tarafı bilinçli değiştir.",
               "Follow one 14-minute sequence and note which options you kept."
               " | Bir 14 dakikalık dizi uygula ve kullandığın seçenekleri not et.",
               "Did you leave each posture as comfortably as you entered it?"
               " | Her pozdan girdiğin kadar rahat çıkabildin mi?",
               "Use only the chair versions; none of the floor shapes is compulsory."
               " | Yalnız sandalye biçimlerini kullan; yerdeki pozların hiçbiri zorunlu değil.",
               "Uncut chair and floor branches, both with neutral pauses; show supported exit from every pose."
               " | Sandalye ve zemin dalları kesintisiz; nötr aralar ve her pozdan destekli çıkış göster.",
               minutes=14),
    ]),
    module("supine", "Supine support and rest | Sırtüstü destek ve dinlenme",
           "Use small floor movements and recover without chasing a stretch."
           " | Esneme peşinde koşmadan küçük yer hareketleri ve toparlanma uygula.", [
        lesson("h25", "One-knee release | Tek dizle rahatlama",
               "Move a leg toward the trunk without compressing the abdomen."
               " | Karnı sıkıştırmadan bir bacağı gövdeye doğru hareket ettir.",
               "Lie on your back only if comfortable; keep one foot on the floor and guide the other knee gently inward."
               " | Yalnız rahatsa sırtüstü yat; bir ayak yerdeyken öteki dizi hafifçe yaklaştır.",
               "Release the leg slowly and compare sides without pulling the knee against the chest."
               " | Dizi göğse çekiştirmeden bacağı yavaş bırak ve tarafları karşılaştır.",
               "Take three easy breaths per side, once or twice."
               " | Her yanda üç rahat nefes, bir veya iki tur yap.",
               "Can the abdomen and lower back remain comfortable as the leg returns?"
               " | Bacak dönerken karın ve bel rahat kalabiliyor mu?",
               "Use a strap behind the thigh, smaller range, or side-lying rest; avoid supine pressure when pregnant."
               " | Uyluk arkasına kayış, daha küçük aralık veya yan dinlenme seç; gebelikte sırtüstü baskıdan kaçın.",
               "Side view of gentle single-leg Pavanamuktasana, no knee force; side-lying alternative."
               " | Tek bacak Pavanamuktasana'yı yandan, dizi zorlamadan ve yan yatış seçeneğiyle göster.",
               minutes=8, sources=("ycb", "nccih", "acog")),
        lesson("h26", "Small supported bridge | Küçük destekli köprü",
               "Lift and lower the pelvis with a controlled range."
               " | Leğen kemiğini kontrollü aralıkta kaldırıp indir.",
               "Lie with feet on the floor and knees bent; keep arms relaxed beside the body."
               " | Ayaklar yerde, dizler bükülü yat; kolları gövde yanında rahat bırak.",
               "Press through the feet, lift the pelvis a little, then lower one part at a time."
               " | Ayaklardan destek al, kalçayı az kaldır, sonra sırayla yavaş indir.",
               "Try four small bridges with a pause on the floor between them."
               " | Aralarda yerde durarak dört küçük köprü dene.",
               "Could you lower smoothly without neck pressure or breath holding?"
               " | Boyna baskı veya nefes tutma olmadan yavaş inebildin mi?",
               "Keep the lift very small or practise a seated pelvic tilt instead."
               " | Yükselişi çok küçük tut veya oturarak leğen kemiğini hafifçe hareket ettir.",
               "Side full-body Setubandhasana preparation; show small range, feet and slow descent."
               " | Setubandhasana hazırlığını yandan tam beden göster; küçük aralık, ayaklar ve yavaş iniş.",
               minutes=10, sources=("ycb", "nccih", "acog")),
        lesson("h27", "Bent-knee leg lift | Bükülü dizle bacak kaldırma",
               "Control one leg at a time before a straight-leg version."
               " | Düz bacak biçiminden önce tek bacağı kontrollü kaldır.",
               "Lie comfortably with both feet on the floor and bring one knee above the hip only as far as easy."
               " | İki ayak yerde rahat yat; bir dizi yalnız kolay olduğu kadar kalça üstüne getir.",
               "Lower the foot slowly and switch sides without arching to gain height."
               " | Yükseklik için beli kavislemeyip ayağı yavaş indir ve taraf değiştir.",
               "Alternate six small lifts; take a full rest before repeating."
               " | Altı küçük kaldırmayı sırayla yap; tekrarlamadan önce tam dinlen.",
               "Could you make the same controlled return on both sides?"
               " | İki tarafta da aynı kontrollü dönüşü yapabildin mi?",
               "Reduce the lift or do a seated march; no straight-leg lift is required."
               " | Kaldırmayı küçült veya oturarak diz kaldır; düz bacak kaldırma zorunlu değil.",
               "Side view of Uttanapadasana preparation, one bent knee at a time, then seated march."
               " | Uttanapadasana hazırlığını yandan tek bükülü dizle, sonra oturarak diz kaldırmayla göster.",
               minutes=9),
        lesson("h28", "Legs supported at a wall | Duvar destekli bacaklar",
               "Choose a restful leg position without turning it into an inversion goal."
               " | Dinlendirici bacak konumunu ters duruş hedefine çevirmeden seç.",
               "Sit near a wall and turn onto the side before bringing legs up only as far as comfortable."
               " | Duvar yakınına oturup yana dön; bacakları yalnız rahat olduğu kadar yükselt.",
               "Keep knees soft and leave by rolling onto the side rather than sitting straight up."
               " | Dizleri rahat tut; doğruca kalkmak yerine yana dönerek çık.",
               "Rest briefly, then compare with legs on a chair or ordinary side lying."
               " | Kısa dinlen, sonra bacaklar sandalyede veya normal yan yatışla karşılaştır.",
               "Is breathing easy, and is there any pressure in head or eyes?"
               " | Nefes kolay mı; baş veya gözlerde baskı var mı?",
               "Choose chair-leg or side-lying rest for pregnancy or any discomfort; skip wall position."
               " | Gebelikte veya rahatsızlıkta sandalye-bacak ya da yan yatış seç; duvar konumunu atla.",
               "Wide Viparita Karani support and side exit; equal-length chair-leg and side-rest alternatives."
               " | Destekli Viparita Karani ve yandan çıkış; sandalye-bacak ve yan dinlenmeye eşit süre ver.",
               minutes=8, stop="Leave the position if head or eye pressure, dizziness, pain or unusual breathlessness appears."
                    " | Baş/göz baskısı, baş dönmesi, ağrı veya alışılmadık nefes darlığı olursa çık.",
               sources=("ycb", "nccih", "acog")),
        lesson("h29", "Resting pose | Dinlenme pozu",
               "Make Shavasana a supported, optional period of rest."
               " | Shavasana'yı destekli ve seçilebilir dinlenme olarak kur.",
               "Lie in a comfortable position with support under knees, or choose side lying or a chair."
               " | Diz altı destekle rahat uzan veya yan yatış ya da sandalye seç.",
               "Let arms and jaw relax; keep the breath ordinary and leave slowly through the side."
               " | Kolları ve çeneyi rahat bırak; nefes doğal kalsın, yandan yavaş çık.",
               "Rest for three minutes and notice whether a different support would help."
               " | Üç dakika dinlen ve başka desteğin yararlı olup olmayacağını gözle.",
               "Did the position allow comfort, and could you change it when needed?"
               " | Konum rahat mıydı ve gerektiğinde değiştirebildin mi?",
               "Use side lying or chair for pregnancy, back discomfort or difficulty lying still."
               " | Gebelikte, bel rahatsızlığında veya sabit yatmak zor gelirse yan yatış ya da sandalye seç.",
               "Uncut quiet Shavasana setup, knee bolster, side-lying/chair alternatives and slow exit."
               " | Kesintisiz sakin Shavasana kurulumu, diz desteği, yan/sandalye seçenekleri ve yavaş çıkış.",
               minutes=7, sources=("ycb", "nccih", "acog")),
        lesson("h30", "Floor-to-rest sequence | Yer hareketinden dinlenmeye",
               "Combine small leg motion, bridge and rest with easy transitions."
               " | Küçük bacak hareketi, köprü ve dinlenmeyi rahat geçişlerle bağla.",
               "Set a chair or cushion nearby before choosing which floor movements to include."
               " | Hangi yer hareketlerini yapacağını seçmeden sandalyeyi veya minderi yakına koy.",
               "Move from one-leg release to small bridges, pause, then choose a rest shape."
               " | Tek bacak rahatlamasından küçük köprülere geç, dur, sonra dinlenme biçimi seç.",
               "Practise one 12-minute sequence without trying to match a model's range."
               " | Modelin hareket aralığını taklit etmeye çalışmadan 12 dakikalık bir dizi yap.",
               "Which part did you reduce or skip, and did rest remain available?"
               " | Hangi bölümü küçülttün veya atladın; dinlenme seçeneği açık kaldı mı?",
               "Use a fully seated sequence: march, gentle pelvic movement and chair rest."
               " | Tamamen oturarak çalış: diz kaldır, hafif leğen hareketi ve sandalye dinlenmesi.",
               "Continuous floor and chair branches with clear pause/exit after each shape."
               " | Her şekilden sonra durma/çıkış gösteren kesintisiz yer ve sandalye dalları.",
               minutes=12),
    ]),
    module("breath_flow", "Breath and gentle flow | Nefes ve yumuşak akış",
           "Use breath awareness to connect familiar movements, without breath holds."
           " | Nefes tutmadan, tanıdık hareketleri nefes farkındalığıyla bağla.", [
        lesson("h31", "Three-area breathing awareness | Üç bölgede nefes farkındalığı",
               "Notice belly, ribs and upper chest without forcing a large breath."
               " | Büyük nefes zorlamadan karın, kaburga ve üst göğsü fark et.",
               "Sit supported, place one hand lightly on the lower ribs and observe a few natural breaths."
               " | Destekli otur, bir eli alt kaburgaya hafif koy ve birkaç doğal nefesi izle.",
               "Move attention from abdomen to side ribs to upper chest; do not try to fill each region."
               " | Dikkati karından yan kaburgaya ve üst göğse taşı; her bölgeyi doldurmaya çalışma.",
               "Spend about a minute on each area, resting whenever attention or breath feels strained."
               " | Her bölgeye yaklaşık bir dakika ayır; dikkat veya nefes zorlanırsa dinlen.",
               "Can you distinguish observation from deliberately making breaths deeper?"
               " | Gözlemlemeyi bilerek daha derin nefes almaktan ayırabiliyor musun?",
               "Keep hands in the lap and shorten the lesson if breath focus is uncomfortable."
               " | Nefes odağı rahatsızsa elleri kucakta tut ve dersi kısalt.",
               "Supported seated view with hand positions and gentle labels; no breath-volume graphics."
               " | El yerlerini destekli oturuşta göster; nefes hacmi grafiği kullanma.",
               minutes=7),
        lesson("h32", "Alternate-nostril awareness | Burun delikleriyle dönüşümlü farkındalık",
               "Learn a gentle Nadi Shodhana pattern without retaining breath."
               " | Nefes tutmadan yumuşak Nadi Shodhana düzenini öğren.",
               "Sit comfortably and first observe three normal breaths with both nostrils open."
               " | Rahat otur, önce iki burun deliği açık üç normal nefesi gözle.",
               "If comfortable, lightly alternate nostril contact; keep exhale and inhale natural, never hold."
               " | Rahatsa burun deliği temasını hafifçe değiştir; alış veriş doğal kalsın, nefes tutma.",
               "Try four easy alternations, then return to ordinary breathing."
               " | Dört rahat dönüşüm dene, sonra normal nefese dön.",
               "Could you end at any point without air hunger or pressure?"
               " | Hava açlığı veya baskı olmadan dilediğin anda bitirebildin mi?",
               "Use mental left-right attention with both nostrils open; skip if congested or distressed."
               " | İki burun deliği açıkken soldan sağa zihinsel dikkat kullan; tıkanma veya sıkıntıda atla.",
               "Close hand position and wide supported seat; label no retention and open-nostril alternative."
               " | El yerini yakın, destekli oturuşu geniş göster; nefes tutmama ve açık burun seçeneğini etiketle.",
               minutes=8, stop="Stop if light-headed, breathless or anxious; return to ordinary breathing."
                    " | Başın dönerse, nefesin daralırsa veya kaygı hissedersen dur; doğal nefese dön."),
        lesson("h33", "Gentle humming exhale | Hafif mırıldanarak nefes verme",
               "Explore a quiet Bhramari exhale without breath pressure."
               " | Nefes baskısı yaratmadan sessiz Bhramari verişini dene.",
               "Sit comfortably and take a natural inhale through the nose or mouth as needed."
               " | Rahat otur, gerektiği gibi burun veya ağızdan doğal nefes al.",
               "Hum very softly on the exhale; stop the sound before the breath feels empty."
               " | Nefes verirken çok hafif mırıldan; nefes tamamen bitmeden sesi kes.",
               "Try three gentle hums with ordinary breaths between them."
               " | Aralarında normal nefeslerle üç hafif mırıldanma dene.",
               "Did the sound stay easy, without ear pressure or a forced long exhale?"
               " | Ses kulak baskısı veya zorunlu uzun veriş olmadan rahat kaldı mı?",
               "Simply listen to the breath if humming is uncomfortable; no ear-closing hand position is required."
               " | Mırıldanma rahatsızsa yalnız nefesi dinle; kulak kapatma eli zorunlu değil.",
               "Seated close view with tiny sound waveform only; visibly return to ordinary breathing."
               " | Oturarak yakın görüntüde yalnız küçük ses dalgası; normal nefese dönüş açıkça gösterilsin.",
               minutes=7, stop="Stop for dizziness, ear discomfort or breath strain."
                    " | Baş dönmesi, kulak rahatsızlığı veya nefes zorlanmasında dur."),
        lesson("h34", "Sun-salutation map | Güneşe selam haritası",
               "Understand transition order before trying any continuous sequence."
               " | Kesintisiz diziye geçmeden geçiş sırasını anla.",
               "Lay out mountain, supported forward fold, tabletop, small cobra and rest as separate stations."
               " | Dağ, destekli öne katlanma, masa, küçük kobra ve dinlenmeyi ayrı duraklar olarak yerleştir.",
               "Walk between stations slowly; this is a map, not a required full Surya Namaskara."
               " | Duraklar arasında yavaş geç; bu tam Surya Namaskara zorunluluğu değil, haritadır.",
               "Rehearse the order twice without holding poses or adding speed."
               " | Poz tutmadan veya hız eklemeden sırayı iki kez prova et.",
               "Can you name a rest or chair alternative at each transition?"
               " | Her geçişte bir dinlenme veya sandalye seçeneği söyleyebiliyor musun?",
               "Use chair fold and chair cat-cow; omit prone work entirely if needed."
               " | Sandalyede katlanma ve kedi-inek yap; gerekirse yüzüstünü tümden çıkar.",
               "Animated route map then wide slow human demo; highlight optional branches and exits."
               " | Önce animasyonlu yol haritası, sonra geniş yavaş insan gösterimi; seçmeli dallar ve çıkışlar işaretli.",
               minutes=10, sources=("ycb", "ayush", "nccih")),
        lesson("h35", "Transitions without rush | Acele etmeden geçişler",
               "Connect three familiar shapes while preserving support and breath."
               " | Destek ve nefesi koruyarak üç tanıdık şekli bağla.",
               "From mountain, use a chair-supported fold and pause before moving to tabletop or chair cat-cow."
               " | Dağdan sandalyeli katlanmaya geç, sonra masa veya sandalye kedi-ineğe geçmeden dur.",
               "Return through a stable seat before standing again; there is no fixed breath count."
               " | Yeniden ayağa kalkmadan sabit oturuştan geç; belirlenmiş nefes sayısı yok.",
               "Practise three slow rounds with a pause after each return."
               " | Her dönüşten sonra durarak üç yavaş tur yap.",
               "Did any transition make you hold your breath or lose support?"
               " | Herhangi bir geçiş nefesi tutmana veya desteği kaybetmene yol açtı mı?",
               "Do the entire path with a chair and omit going to the floor."
               " | Yolun tamamını sandalyeyle yap, yere inmeyi atla.",
               "Uncut front/side sequence at realistic pace; explicitly show a chair-only parallel route."
               " | Gerçekçi tempoda kesintisiz ön/yan dizi; paralel yalnız-sandalye yolu açıkça göster.",
               minutes=12),
        lesson("h36", "Twenty-minute independent plan | Yirmi dakikalık bağımsız plan",
               "Build a balanced session from preparation, standing, floor or chair, breath and rest."
               " | Hazırlık, ayakta, yer veya sandalye, nefes ve dinlenmeden dengeli bir oturum kur.",
               "Choose one familiar posture from each part before starting and place supports nearby."
               " | Başlamadan her bölümden tanıdık bir poz seç ve destekleri yakına koy.",
               "Use a simple order: prepare, move, breathe naturally, rest; change the plan when the body asks."
               " | Basit sırayı izle: hazırlan, hareket et, doğal nefes al, dinlen; gerektiğinde planı değiştir.",
               "Carry out one 20-minute session and write down what you chose rather than a score."
               " | Bir 20 dakikalık oturum yap ve puan yerine seçtiklerini kaydet.",
               "Could you explain why your chosen option fitted today's comfort and energy?"
               " | Seçtiğin biçimin bugünkü rahatlık ve enerjine neden uyduğunu açıklayabiliyor musun?",
               "The session can be entirely seated and shorter on a difficult day."
               " | Zor bir günde oturum tamamen oturarak ve daha kısa olabilir.",
               "Editable five-part timeline with human demo fragments and visible rest/skip choices."
               " | İnsan gösterimi parçalarıyla düzenlenebilir beş bölümlü zaman çizelgesi; dinlen/atla seçenekleri görünür.",
               minutes=20, sources=("ycb", "ayush", "nccih")),
    ]),
    module("intermediate", "Intermediate choices | Orta seviye seçenekleri",
           "Explore more demanding shapes through smaller preparations and an independent capstone."
           " | Daha zor şekilleri küçük hazırlıklarla incele ve bağımsız bitirme çalışması yap.", [
        lesson("h37", "Cow-face arm pathway | Gomukhasana kol yolu",
               "Explore opposite shoulder directions without forcing hands to meet."
               " | Elleri buluşturmaya zorlamadan omuzları ters yönlerde çalıştır.",
               "Sit on a chair, lift one arm only as comfortable and bring the other hand toward the back waist."
               " | Sandalyede otur, bir kolu yalnız rahatça kaldır, öteki eli bel arkasına yaklaştır.",
               "Hold a strap loosely between hands if available; release both arms before swapping sides."
               " | Varsa kayışı eller arasında gevşek tut; taraf değiştirmeden iki kolu da bırak.",
               "Try two short holds per side without pulling on the strap."
               " | Kayışı çekiştirmeden her yanda iki kısa tutuş dene.",
               "Could both shoulders move without a sharp pinch or head jutting forward?"
               " | İki omuz keskin sıkışma veya başı öne itme olmadan hareket etti mi?",
               "Keep both hands in front of the body, or omit the overhead arm."
               " | İki eli gövde önünde tut veya üstteki kolu atla.",
               "Rear three-quarter Gomukhasana arms with strap gap visible; front-hand alternative."
               " | Kayış aralığı görünür arkadan üç çeyrek Gomukhasana kolları; önde-el seçeneği.",
               minutes=10),
        lesson("h38", "Supported camel preparation | Destekli deve hazırlığı",
               "Practise a small kneeling chest opening without dropping the head back."
               " | Başı geriye atmadan küçük diz üstü göğüs açma çalış.",
               "Kneel on padding only if comfortable and place hands at the back of the pelvis."
               " | Yalnız rahatsa yastıklı zeminde diz çök ve elleri leğen kemiğinin arkasına koy.",
               "Lengthen up, move the chest slightly forward and return upright before any back pinch."
               " | Yukarı uzan, göğsü az öne taşı ve belde sıkışma olmadan dikleş.",
               "Try three small openings with upright rest between them; no heel reach is required."
               " | Aralarında dik dinlenerek üç küçük açılma dene; topuğa uzanmak zorunlu değil.",
               "Can you keep the neck long and exit without pushing through discomfort?"
               " | Boynu uzun tutup rahatsızlığı zorlamadan çıkabiliyor musun?",
               "Perform the same small chest opening in a chair or skip kneeling."
               " | Aynı küçük göğüs açmayı sandalyede yap veya diz üstünü atla.",
               "Side view of small Ushtrasana preparation and chair version; explicitly omit full backbend."
               " | Küçük Ushtrasana hazırlığını yandan ve sandalye biçiminde göster; tam geriye bükülme yok.",
               minutes=10),
        lesson("h39", "Reverse-table preparation | Ters masa hazırlığı",
               "Load the arms gently before any Purvottanasana variation."
               " | Purvottanasana çeşidinden önce kollara hafif yük ver.",
               "Sit with knees bent and hands behind on stable floor; point fingers to a comfortable direction."
               " | Dizler bükülü, eller arkada sabit zeminde otur; parmakları rahat yöne çevir.",
               "Press lightly into hands and feet, lift the pelvis a little, and lower without neck strain."
               " | El ve ayaklara hafif bas, kalçayı az kaldır, boynu zorlamadan indir.",
               "Make three small lifts separated by complete seated rest."
               " | Aralarında tam oturarak dinlenip üç küçük yükseliş yap.",
               "Can wrists and shoulders tolerate the load, and does the neck stay neutral?"
               " | Bilek ve omuz yükü tolere ediyor mu, boyun nötr kalıyor mu?",
               "Use a chair-supported seated chest opening instead; skip weight bearing with wrist discomfort."
               " | Sandalyede destekli göğüs açmayı seç; bilek belirtisinde yük bindirmeyi atla.",
               "Side view of short reverse-table lift, neutral neck and chair-supported substitute."
               " | Kısa ters masa yükselişini yandan, nötr boyunla ve sandalye eşdeğeriyle göster.",
               minutes=10),
        lesson("h40", "Locust preparation | Çekirge hazırlığı",
               "Use a small posterior-chain activation without a high leg lift."
               " | Bacağı yükseğe kaldırmadan küçük arka zincir aktivasyonu yap.",
               "Rest prone only if comfortable with forehead supported and arms by the sides."
               " | Yalnız rahatsa alın destekli, kollar yanda yüzüstü dinlen.",
               "Reach one leg long along the floor, lift it slightly, lower, then switch."
               " | Bir bacağı yerde uzat, az kaldır, indir ve taraf değiştir.",
               "Try three small lifts per leg, breathing normally and resting afterward."
               " | Normal nefesle her bacakta üç küçük yükseliş yap, sonra dinlen.",
               "Can the pelvis stay comfortable without arching hard through the lower back?"
               " | Belden sert kavis yapmadan leğen kemiği rahat kalabiliyor mu?",
               "Do a seated backward leg reach at a chair or skip prone during pregnancy."
               " | Sandalye yanında oturarak bacağı geriye uzat veya gebelikte yüzüstünü atla.",
               "Side Shalabhasana preparation, tiny one-leg lift and chair option; no high-lift target."
               " | Çekirge hazırlığını yandan, küçük tek bacak kaldırma ve sandalye seçeneğiyle göster; yüksek hedef yok.",
               minutes=10, sources=("ycb", "nccih", "acog")),
        lesson("h41", "Choose a route | Kendi yolunu seç",
               "Select suitable standing, seated and optional intermediate elements."
               " | Uygun ayakta, oturarak ve seçmeli orta seviye parçaları seç.",
               "Review the comfortable range and support used in the previous lessons."
               " | Önceki derslerde kullandığın rahat aralık ve destekleri gözden geçir.",
               "Choose two standing shapes, two seated/low shapes, one breathing pause and rest."
               " | İki ayakta, iki oturarak/alçak şekil, bir nefes molası ve dinlenme seç.",
               "Write a 25-minute route and rehearse only the transitions once."
               " | 25 dakikalık yol yaz ve yalnız geçişleri bir kez prova et.",
               "Are alternatives and exit routes written next to the difficult shapes?"
               " | Zor şekillerin yanında kolay seçenek ve çıkış yolu yazılı mı?",
               "Keep only familiar basic shapes; optional intermediate preparations are not a test."
               " | Yalnız tanıdık temel şekilleri tut; orta seviye hazırlıklar sınav değil.",
               "Course-map animation arranging chosen poses, supports and exit cards; no proficiency badge."
               " | Seçilen pozları, destekleri ve çıkış kartlarını yerleştiren kurs haritası animasyonu; ustalık rozeti yok.",
               minutes=10),
        lesson("h42", "Independent Hatha capstone | Bağımsız Hatha bitirme çalışması",
               "Complete a chosen session and describe what you learned, without a camera verdict."
               " | Seçtiğin oturumu bitir ve kamera hükmü olmadan öğrendiklerini anlat.",
               "Set up space and supports, then follow your own preparation-movement-breath-rest plan."
               " | Alan ve destekleri kur, kendi hazırlık-hareket-nefes-dinlenme planını izle.",
               "When a pose does not suit today, use the planned alternative and continue or stop."
               " | Bir poz bugün uymuyorsa planlı seçeneği kullan ve sürdür veya dur.",
               "Practise 25-30 minutes at your own pace; record which parts were practiced and changed."
               " | Kendi hızında 25-30 dakika çalış; yaptığın ve değiştirdiğin bölümleri kaydet.",
               "Can you name three skills gained: setup, controlled exit and choosing an adaptation?"
               " | Kazandığın üç beceriyi söyleyebiliyor musun: hazırlık, kontrollü çıkış, uyarlama seçimi?",
               "A fully chair-based or shorter capstone is a valid route."
               " | Tamamen sandalyede veya daha kısa bitirme çalışması geçerli bir yoldur.",
               "Three human examples of different valid plans, including chair route; show self-record only."
               " | Sandalye yolu dahil üç farklı geçerli planı insan örneğiyle göster; yalnız öz kayıt kullan.",
               minutes=30, sources=("ycb", "ayush", "nccih")),
    ]),
]


# Original entry/exit teaching completes each existing lesson's action and form.
FOUNDATION_ENTRIES_EXITS = {
    "h01": ("Before moving, identify a chair that cannot slide and a clear way to sit down. | Hareketten önce kaymayan sandalyeyi ve oturmak için açık yolu belirle.", "Finish by naming a stop signal and choosing observation if today's personal limits are uncertain. | Bir dur işareti söyleyerek bitir; bugünkü kişisel sınırların belirsizse gözlemi seç."),
    "h02": ("Settle into a supported chair with feet resting; loosen tight clothing around the ribs. | Ayaklar destekli sandalyeye yerleş; kaburga çevresindeki sıkı giysiyi gevşet.", "End the observation by looking around and moving fingers before changing position. | Konum değiştirmeden çevrene bakıp parmakları hareket ettirerek gözlemi bitir."),
    "h03": ("Approach the wall and place a hand on it before arranging the feet. | Ayakları yerleştirmeden duvara yaklaş ve bir elini koy.", "Release the stance with a small supported step, then sit if needed. | Küçük destekli adımla duruşu bırak, gerekirse otur."),
    "h04": ("Place the blanket before sitting and keep a chair available if the floor is difficult to reach. | Oturmadan battaniyeyi yerleştir; yere ulaşmak zorsa sandalyeyi hazır tut.", "Uncross the legs with your hands if needed, then extend one leg at a time without pulling the knee. | Gerekirse ellerle bacak çaprazını aç; dizi çekmeden birer bacağı uzat."),
    "h05": ("Sit back on a stable chair with both feet touching the floor and leave room around the arms. | Sabit sandalyeye iki ayak yerde otur; kolların çevresinde yer bırak.", "Place both feet down, open the hands and pause before standing; do not combine every joint movement at once. | İki ayağı yere koy, elleri aç ve kalkmadan bekle; tüm eklem hareketlerini birleştirme."),
    "h06": ("Write three stations on a card: chair breath, joint preparation and supported mountain. | Karta üç durak yaz: sandalyede nefes, eklem hazırlığı ve destekli dağ.", "End seated, note the support actually used and shorten the next round if transitions felt rushed. | Oturarak bitir, kullandığın desteği kaydet; geçişler acele geldiyse sonraki turu kısalt."),
    "h07": ("Stand beside a wall with both feet grounded; keep the lower hand on support when balance needs it. | İki ayak yerde duvar yanında dur; denge gerekiyorsa alttaki eli destekte tut.", "Bring the raised arm down after returning upright; pause before lifting the other arm. | Dik konuma döndükten sonra yukarıdaki kolu indir; ötekini kaldırmadan bekle."),
    "h08": ("Find mountain first and choose a small turning range that leaves both feet comfortable. | Önce dağ duruşunu bul; iki ayağı rahat bırakan küçük dönüş aralığı seç.", "Face forward, relax the arms and reset the feet before taking a step. | Öne dön, kolları bırak ve adım atmadan ayakları yeniden yerleştir."),
    "h09": ("Place a stable chair beside the forward leg; begin with a shorter stance than your maximum reach. | İleri bacak yanında sabit sandalye koy; en geniş açılışından daha kısa duruşla başla.", "Press into the feet to rise, lower the arms, then turn the feet forward before changing sides. | Ayağa basıp yüksel, kolları indir; taraf değiştirmeden ayakları öne çevir."),
    "h10": ("Keep the wall within easy reach and first transfer weight with both toes still on the floor. | Duvarı kolay erişimde tut; önce iki ayağın parmakları yerdeyken ağırlığı aktar.", "Return the raised foot to the floor before letting go of the wall; reset both feet for the other side. | Duvarı bırakmadan kalkık ayağı yere koy; öteki taraf için iki ayağı yeniden yerleştir."),
    "h11": ("Secure the chair against a wall and stand far enough away to place both palms without leaning on a moving seat. | Sandalyeyi duvara sabitle; hareketli oturağa yaslanmadan iki avucu koyabileceğin uzaklıkta dur.", "Walk closer to the chair before standing; raise the torso gradually and keep your gaze level if light-headed. | Doğrulmadan sandalyeye yaklaş; gövdeyi yavaş yükselt, sersemlikte durup destek al."),
    "h12": ("Choose mountain, side reach, wall tree and supported fold; put the wall and chair along one clear route. | Dağ, yana uzanma, duvarda ağaç ve destekli katlanmayı seç; duvarla sandalyeyi açık yol üzerinde hazırla.", "Return to mountain or sit; list which transitions needed support instead of judging the depth of poses. | Dağa dön veya otur; poz derinliğini yargılamak yerine destek gereken geçişleri yaz."),
    "h13": ("Lower to a padded kneeling seat using a stable support; place the hands before shifting weight forward. | Sabit destekle minderli diz üstüne alçal; ağırlığı öne vermeden elleri koy.", "Shift hips toward heels only as comfortable, remove weight from hands and come to a supported seat. | Kalçayı rahat olduğu kadar topuklara yaklaştır; ellerdeki yükü bırakıp destekli oturuşa geç."),
    "h14": ("Establish the tabletop taught in h13, keeping space between the knees and a relaxed neck. | h13 masa temelini kur; dizler arasında alan, boyunda rahatlık bırak.", "Finish at a neutral back, then use the h13 exit instead of dropping abruptly onto the wrists. | Sırtı nötrde bitir; bileklere aniden çökmek yerine h13 çıkışını kullan."),
    "h15": ("From tabletop, separate knees only enough for comfort and place the forehead support ahead of you. | Masadan dizleri rahatlık kadar ayır; alın desteğini önüne koy.", "Press gently through hands, lift the head with the torso and return to tabletop before sitting. | Ellere hafif bas, başı gövdeyle kaldır; oturmadan masaya dön."),
    "h16": ("Choose this prone rest only when abdomen contact is appropriate for you; otherwise stay in a chair or side rest. | Karın teması senin için uygunsa bu yüzüstü dinlenmeyi seç; değilse sandalyede ya da yan dinlenmede kal.", "Slide one hand beside the chest and roll gently to the side; pause before pushing up to sit. | Bir eli göğüs yanına kaydırıp yavaşça yana dön; oturmak için yükselmeden bekle."),
    "h17": ("Enter from the h16 prone setup and spread the legs only enough to let the pelvis settle. | h16 yüzüstü hazırlığından gir; leğen kemiğini rahat bırakacak kadar bacakları ayır.", "Lower chest and forehead first, release the hands and use the side-roll exit before sitting. | Önce göğüsle alnı indir, elleri bırak; oturmadan yana dönerek çık."),
    "h18": ("Choose tabletop, one cat-cow cycle and either child rest or a chair rest; add low cobra only if prone is appropriate. | Masa, bir kedi-inek döngüsü ve çocuk ya da sandalye dinlenmesi seç; yüzüstü uygunsa alçak kobrayı ekle.", "Finish in the chosen rest, then move through a side or supported seat before leaving the mat. | Seçtiğin dinlenmede bitir; mattan ayrılmadan yan ya da destekli oturuşa geç."),
    "h19": ("Sit sideways onto the blanket first, then bring the legs in front without locking the knees. | Önce battaniyeye yandan otur; dizleri kilitlemeden bacakları öne getir.", "Bend each knee, place feet down and change to a comfortable seat rather than pulling yourself forward by the toes. | Her dizi bük, ayakları koy; parmaklardan öne çekmek yerine rahat oturuşa geç."),
    "h20": ("From staff, bend one knee at a time and place supports where the thighs can rest without being pushed down. | Asadan birer dizi bük; uylukları aşağı itmeden dinlenebilecekleri destekleri koy.", "After bringing knees together, slide one foot away at a time and pause in staff or chair sitting. | Dizleri birleştirdikten sonra birer ayağı uzaklaştır; asa veya sandalye oturuşunda bekle."),
    "h21": ("Try kneeling beside the chair only if knee and ankle contact is comfortable; chair sitting is a separate full option. | Diz ve ayak bileği teması rahatsa sandalye yanında diz çök; sandalye oturuşu başlı başına seçenektir.", "Use hands on a stable support to unweight the knees, then change position before numbness or pressure builds. | Sabit desteğe ellerle basıp dizlerin yükünü azalt; uyuşma veya basınç artmadan konum değiştir."),
    "h22": ("Keep both sitting bones supported and make room to turn without hooking an arm around the chair. | İki oturma kemiğini destekle; sandalyeye kol dolamadan dönecek alan bırak.", "Unwind the chest and then the gaze; face forward for one ordinary breath before changing sides. | Önce göğsü sonra bakışı öne getir; taraf değiştirmeden doğal bir nefes bekle."),
    "h23": ("Begin in supported staff with a chair or cushions close enough that you do not have to reach for the toes. | Parmaklara uzanmak zorunda kalmayacağın yakınlıkta sandalye veya minderle destekli asaya başla.", "Bring hands back along the shins as the torso rises; bend the knees further to release tension. | Gövde yükselirken elleri kaval boyunca geri getir; gerginliği bırakmak için dizleri biraz daha bük."),
    "h24": ("Arrange staff, bound angle and a gentle turn on paper; choose which uses the chair. | Asa, bağlı açı ve hafif dönüşü kâğıtta sırala; hangisinde sandalye kullanılacağını seç.", "Uncross or unfold the legs fully before standing; record any shape replaced by a neutral seat. | Kalkmadan bacakların çaprazını veya katını aç; nötr oturuşla değiştirdiğin şekli kaydet."),
    "h25": ("Lower through the side onto the mat, with both knees bent; choose seated observation if back lying is unsuitable. | İki diz bükülü yana dönerek mata in; sırtüstü uygun değilse oturarak gözlem seç.", "Return both feet to the mat, roll to the side and pause before sitting up. | İki ayağı mata koy, yana dön ve oturmadan bekle."),
    "h26": ("Set feet roughly hip width with heels within easy reach; keep the back of the head resting and do not turn it during a lift. | Ayakları yaklaşık kalça genişliğinde, topuklar kolay erişimde kur; başın arkası yerde kalsın, yükselişte başı çevirme.", "Let the pelvis settle completely, rest with knees bent and use a side roll to leave. | Leğen kemiğini tamamen indir, dizler bükülü dinlen ve yana dönerek çık."),
    "h27": ("Begin with both feet grounded, arms beside you and enough room to lower a leg without hitting furniture. | İki ayak yerde, kollar yanda başla; bacağı mobilyaya çarpmadan indirecek alan bırak.", "Place each foot fully down before the other moves; finish with both knees bent and roll to the side. | Öteki hareket etmeden her ayağı tam koy; iki diz bükülü bitirip yana dön."),
    "h28": ("Place a folded blanket beside the wall; start with hips farther away so the knees can remain bent. | Duvar yanına katlı battaniye koy; dizler bükülü kalabilsin diye kalçayı duvardan uzakta başlat.", "Bend the knees, slide feet down the wall and roll sideways before using hands to sit. | Dizleri bük, ayakları duvardan kaydır; ellerle oturmadan önce yana dön."),
    "h29": ("Select chair, side lying or back lying before settling; support the head and knees as needed without covering the face. | Yerleşmeden sandalye, yan veya sırtüstü yatışı seç; yüzü örtmeden gerektiği kadar başla dizleri destekle.", "Open the eyes, move fingers and toes, then rise through a side or supported seat at your own pace. | Gözleri aç, el ve ayak parmaklarını oynat; kendi hızında yan veya destekli oturuştan yüksel."),
    "h30": ("Rehearse the side-roll entry first and decide whether the supine section belongs in today's plan. | Önce yana dönerek girişi prova et; sırtüstü bölümün bugünkü planda olup olmayacağını seç.", "End with a chosen rest; compare how easy it was to enter and leave each shape, without a flexibility score. | Seçilmiş dinlenmeyle bitir; esneklik puanı olmadan her şekle giriş ve çıkışın kolaylığını karşılaştır."),
    "h31": ("Sit with back support and release the shoulders; this is attention training, not maximum lung filling. | Sırt destekli otur, omuzları bırak; bu en çok hava alma değil dikkat çalışmasıdır.", "Put both hands on the thighs and return to unobserved natural breathing if attention becomes tiring. | Elleri uyluklara koy; gözlem yoruyorsa dikkati nefes saymadan doğal solunuma bırak."),
    "h32": ("Rest an elbow on support if needed and leave both nostrils open while finding an ordinary breath. | Gerekirse dirseği destekle; doğal nefesi bulurken iki burun deliğini açık bırak.", "Lower the hand and breathe through both nostrils; stop the exercise if air hunger or dizziness appears. | Eli indir, iki burun deliğinden nefes al; hava açlığı veya baş dönmesinde çalışmayı bırak."),
    "h33": ("Relax the jaw and lips without clenching; keep the ears uncovered and shoulders down. | Çene ve dudakları sıkmadan rahatlat; kulaklar açık, omuzlar rahat kalsın.", "Release the sound, take an ordinary breath and wait before repeating; do not lengthen the hum competitively. | Sesi bırak, doğal nefes al ve yinelemeden bekle; mırıldanmayı yarışarak uzatma."),
    "h34": ("Name the previously learned shapes before arranging the mat and chair; no new pose is required in this map. | Matla sandalyeyi kurmadan öğrenilen şekilleri adlandır; bu haritada yeni poz gerekmez.", "Return to mountain or a chair after the last station and mark where you would need extra instruction for a continuous flow. | Son duraktan dağa veya sandalyeye dön; kesintisiz akış için ek öğreti gereken yeri işaretle."),
    "h35": ("Place hands on the secured chair and practise one small hip hinge before considering the floor route. | Sabit sandalyeye elleri koy; yer yolunu düşünmeden küçük kalça katlanmasını çalış.", "Finish seated with feet grounded; describe the point where you paused before changing your level. | Ayaklar yerde oturarak bitir; seviye değiştirmeden durakladığın noktayı anlat."),
    "h36": ("Write four blocks and approximate times; leave extra room for support changes instead of filling every minute with poses. | Dört bölüm ve yaklaşık süre yaz; her dakikayı pozla doldurmak yerine destek değişimlerine yer bırak.", "Close with rest and note the actual duration and substitutions; a shorter session is not a failed test. | Dinlenmeyle kapat, gerçek süreyle değişimleri kaydet; kısa oturum başarısız sınav değildir."),
    "h37": ("Sit with feet supported and hold a long strap; this lesson teaches arms, not the full crossed-leg Gomukhasana. | Ayaklar destekli otur, uzun kayış tut; bu ders tam çapraz bacaklı Gomukhasana değil kolları öğretir.", "Release the lower hand first, then lower the raised arm slowly; shake out hands before swapping. | Önce alttaki eli bırak, sonra yukarıdaki kolu yavaş indir; değiştirmeden elleri gevşet."),
    "h38": ("Pad the knees and place a chair beside you for entry; keep hips above knees instead of reaching for heels. | Dizleri destekle, giriş için yana sandalye koy; topuklara uzanmak yerine kalçayı dizler üzerinde tut.", "Return the chest over the pelvis, take support and come to a chair or comfortable kneeling rest. | Göğsü leğen kemiği üzerine getir, destek alıp sandalyeye veya rahat diz üstü dinlenmeye geç."),
    "h39": ("From supported staff, bend knees and place feet flat before setting hands behind the hips. | Destekli asadan dizleri bük, elleri kalça arkasına koymadan ayak tabanlarını yere yerleştir.", "Lower the seat before lifting either hand, then rest wrists without rolling onto them. | Ellerden birini kaldırmadan oturma yerini indir; bileklerin üzerine yuvarlanmadan dinlendir."),
    "h40": ("Set a low forehead support and choose side or chair observation when abdomen contact is unsuitable. | Alna alçak destek koy; karın teması uygun değilse yan veya sandalye gözlemi seç.", "Lower the lifted leg completely, release the toes and use the prone side-roll exit after the last repetition. | Kalkık bacağı tam indir, parmakları bırak; son tekrardan sonra yüzüstünden yana dönerek çık."),
    "h41": ("Open your h36 plan and label this as a foundations rehearsal before the later standing and flow lessons. | h36 planını aç; bunu ilerideki ayakta ve akış derslerinden önce temel prova olarak adlandır.", "Keep the written plan for h42, with a separate note for each shape you have only observed. | Yalnız gözlemlediğin her şekil için ayrı notla yazılı planı h42 için sakla."),
    "h42": ("Read the h41 plan and select a shorter foundation route if supports or energy have changed today. | h41 planını oku; destekler veya enerjin bugün değiştiyse kısa temel yolunu seç.", "Record this as a foundation checkpoint; review unfamiliar transitions before starting the new h43–h60 skills. | Bunu temel kontrol noktası olarak kaydet; yeni h43–h60 becerilerine başlamadan tanıdık olmayan geçişleri gözden geçir."),
}

for _module in MODULES:
    for _lesson in _module["lessons"]:
        _entry, _exit = FOUNDATION_ENTRIES_EXITS[_lesson["id"]]
        _lesson["steps"] = [text_pair(_entry), *_lesson["steps"], text_pair(_exit)]

_BY_ID = {item["id"]: item for mod in MODULES for item in mod["lessons"]}
_BY_ID["h01"]["adaptation"] = text_pair("Pregnancy, injury and chronic conditions need individual advice about personal limits; gentle, chair or supported does not automatically mean suitable. Observing is a valid choice. | Gebelik, sakatlık ve kronik durumlarda kişisel sınırlar için bireysel görüş gerekir; hafif, sandalyeli veya destekli olması otomatik uygunluk değildir. Gözlem de geçerli seçimdir.")
_BY_ID["h09"]["steps"][1] = text_pair("Turn the front foot toward the short edge of the mat and angle the rear toes slightly inward; shorten the stance if either knee twists. | Ön ayağı matın kısa kenarına, arka parmakları hafif içe çevir; herhangi bir diz dönüyorsa duruşu kısalt.")
_BY_ID["h32"]["steps"][2] = text_pair("Gently close the right nostril: exhale then inhale through the left. Switch sides for an easy exhale and inhale; reopen both. Never retain or force the breath; observing without closing is an option. | Sağ burun deliğini hafif kapat: soldan ver ve al. Rahat bir veriş ve alış için taraf değiştir; ikisini aç. Nefesi tutma veya zorlama; kapatmadan gözlem seçeneği vardır.")
_BY_ID["h40"]["adaptation"] = text_pair("When prone is unsuitable, observe from a chair or try a previously comfortable supported standing leg reach. The alternative is a separate practice, not proof of locust ability. | Yüzüstü uygun değilse sandalyeden gözle veya daha önce rahat yaptığın destekli ayakta bacak uzatmayı seç. Alternatif ayrı çalışmadır; çekirge becerisi kanıtı değildir.")
_BY_ID["h39"]["mediaBrief"] = text_pair("Side view of a short reverse-table lift with neutral neck, entry and exit; show the chair chest-opening as a separate alternative, not the same skill. | Kısa ters masa yükselişini nötr boyun, giriş ve çıkışla yandan göster; sandalyede göğüs açmayı aynı beceri değil ayrı seçenek olarak göster.")
_BY_ID["h41"]["title"] = text_pair("Plan a foundations rehearsal | Temel prova planı")
_BY_ID["h42"]["title"] = text_pair("Foundations checkpoint | Temel kontrol noktası")
_BY_ID["h42"]["adaptation"] = text_pair("A shorter or chair-based checkpoint can document the practices actually chosen; it does not establish competence in omitted floor or balance skills. | Kısa veya sandalyeli kontrol noktası seçilen çalışmaları kaydedebilir; atlanan yer veya denge becerilerinde yeterlik göstermez.")
MODULES[6]["title"] = text_pair("Preparation and foundations review | Hazırlık ve temel tekrarı")
MODULES[6]["outcome"] = text_pair("Rehearse optional preparations and review foundations before new standing and flow skills. | Yeni ayakta ve akış becerilerinden önce seçmeli hazırlıkları ve temelleri tekrar et.")


def progression(lesson_id, title, objective, steps, practice, check, adaptation, shot, minutes=12, sources=None):
    item = lesson(lesson_id, title, objective, steps[1], steps[2], practice, check, adaptation, shot, minutes, sources=sources)
    item["steps"] = [text_pair(step) for step in steps]
    return item


MODULES.extend([
    module("standing_strength", "Standing and weight-bearing skills | Ayakta ve yük taşıyan beceriler",
           "Build individual actions before linking them into a flow. | Akışa bağlamadan önce tek tek eylemleri öğren.", [
        progression("h43", "Supported low lunge | Destekli alçak hamle",
            "Learn a split stance and a controlled return to tabletop. | Ayrık duruşu ve masaya kontrollü dönüşü öğren.", [
            "From padded tabletop, bring one foot between the hands in small steps; move a hand to a stable chair if reaching the floor is difficult. | Minderli masadan bir ayağı küçük adımlarla eller arasına getir; yere ulaşmak zorsa bir eli sabit sandalyeye koy.",
            "Keep the rear knee down and the front foot flat; move the pelvis forward only a little while the front knee follows the toes. | Arka diz yerde, ön taban tam yerde kalsın; ön diz parmak yönünü izlerken leğen kemiğini az öne taşı.",
            "Lengthen the torso without pressing into the lower back; breathe normally and reduce the stride if abdomen or knee feels compressed. | Bele bastırmadan gövdeyi uzat; doğal nefes al, karın veya diz sıkışıyorsa adımı kısalt.",
            "Shift back, place both hands on support and return the front knee beside the rear knee before changing sides. | Geri kay, iki eli desteğe koy; taraf değiştirmeden ön dizi arka dizin yanına getir."],
            "Try two slow entries per side with a rest in tabletop or chair between. | Arada masa veya sandalye dinlenmesiyle her tarafta iki yavaş giriş dene.",
            "Can you place and retrieve the foot without dropping onto the knee or holding your breath? | Dize düşmeden veya nefes tutmadan ayağı yerleştirip geri alabiliyor musun?",
            "Use a shorter standing split stance with both hands on a secured chair, or observe; a supported option still needs personal suitability. | Sabit sandalyede iki elle daha kısa ayakta ayrık duruşu seç veya gözle; destekli seçenek de kişisel uygunluk gerektirir.",
            "Side and three-quarter views, padded rear knee and flat front foot close-up; show hand repositioning and return in real time. | Yandan ve çapraz açı, minderli arka diz ve ön taban yakın planı; el değişimini ve dönüşü gerçek hızda göster.", sources=("ycb", "nccih", "adriene_lunge")),
        progression("h44", "Warrior I with a short stance | Kısa duruşla Savaşçı I",
            "Distinguish a grounded rear heel from the kneeling lunge. | Yerdeki arka topuğu diz üstü hamleden ayırt et.", [
            "Start in mountain beside a wall; step one foot back and angle the rear toes outward enough for comfortable full-foot contact. | Duvar yanında dağdan başla; bir ayağı geri al, rahat taban teması için arka parmakları yeterince dışa çevir.",
            "Bend the forward knee toward its toes and keep the rear leg active without locking it; shorten the stride if the heel lifts. | Ön dizi parmak yönünde bük, arka bacağı kilitlemeden canlı tut; topuk kalkıyorsa adımı kısalt.",
            "Let the pelvis face forward only as comfortable; raise arms or keep hands on hips, with ribs over pelvis and an easy breath. | Leğen kemiği rahat olduğu kadar öne baksın; kaburgalar leğen üstünde rahat nefesle kolları kaldır veya elleri kalçada tut.",
            "Lower arms, straighten the front knee softly and use the wall to step back to mountain; reset before the other side. | Kolları indir, ön dizi yumuşakça doğrult; duvarla dağa adımla, öteki taraftan önce yeniden yerleş."],
            "Practise one entry and exit per side twice, holding only two or three comfortable breaths. | İki tur her tarafta bir giriş ve çıkış çalış; yalnız iki üç rahat nefes kal.",
            "Can the heel remain grounded without twisting a knee or forcing the pelvis square? | Dizi döndürmeden veya leğeni zorla düzlemeden topuk yerde kalıyor mu?",
            "Keep a wall hand and arms low; choose mountain or the previously learned short lunge if this foot position is unsuitable. | Bir eli duvarda, kolları alçakta tut; bu ayak konumu uygun değilse dağı veya öğrenilen kısa hamleyi seç.",
            "Front plus side entry, foot-angle insert and full exit; compare short stance and wall hand without perfect-angle overlays. | Önden ve yandan giriş, ayak açısı ayrıntısı ve tam çıkış; kusursuz açı bindirmeden kısa duruş ve duvar elini karşılaştır.", sources=("nccih", "adriene_warrior1")),
        progression("h45", "Warrior II and foot reset | Savaşçı II ve ayakları yeniden kurma",
            "Learn an open standing base without turning on a loaded knee. | Yüklü diz üzerinde dönmeden açık ayakta temel öğren.", [
            "From mountain, step wide, turn the front foot toward the mat end and turn the rear toes slightly inward before bending either knee. | Dağdan geniş adımla; diz bükmeden ön ayağı mat ucuna, arka parmakları hafif içe çevir.",
            "Bend the front knee in the direction of its toes while keeping the rear foot planted; choose depth by control, not a right-angle target. | Arka ayak yerdeyken ön dizi parmak yönünde bük; derinliği dik açı hedefiyle değil kontrolle seç.",
            "Open arms only as comfortable and keep the torso upright between the feet; look ahead or over the front hand without neck strain. | Kolları rahat olduğu kadar aç, gövdeyi ayaklar arasında dik tut; boynu zorlamadan öne veya ön el üzerinden bak.",
            "Straighten gently, lower arms and turn both feet forward before stepping in or changing sides. | Yavaş doğrul, kolları indir; yaklaşmadan veya taraf değiştirmeden iki ayağı öne çevir."],
            "Rehearse the foot setup separately, then try two short holds per side. | Ayak hazırlığını ayrı prova et; sonra iki tarafta ikişer kısa kalış dene.",
            "Did you reset the feet before changing direction and keep breathing at your chosen depth? | Yön değiştirmeden ayakları yeniden kurup seçtiğin derinlikte nefes alabildin mi?",
            "Shorten stance, keep hands on hips or use a wall hand; observation is available when standing balance is uncertain. | Duruşu kısalt, elleri kalçada veya bir eli duvarda tut; ayakta denge belirsizse gözlem seç.",
            "Front full-body foot setup, side knee tracking and real-time feet-forward exit; show a shallow version first. | Önden tam beden ayak kurulumu, yandan diz yönü ve gerçek hızda ayakları öne getirerek çıkış; önce sığ seçenek.", sources=("nccih", "adriene_warrior2")),
        progression("h46", "Downward dog: wall to floor choice | Aşağı bakan köpek: duvar veya yer",
            "Learn the hip-back action with two distinct support choices. | Kalçayı geriye gönderme eylemini iki ayrı destek seçeneğiyle öğren.", [
            "First place palms on a wall at chest level, step back and soften knees; keep the floor clear behind you. | Önce avuçları göğüs düzeyinde duvara koy, geri adımla ve dizleri yumuşat; arkadaki zemini açık tut.",
            "Send hips back while lengthening the sides of the torso; stop before shoulders or breath feel compressed. | Gövdenin yanlarını uzatırken kalçayı geriye gönder; omuz veya nefes sıkışmadan dur.",
            "Only for the optional floor route, start in h13 tabletop, tuck toes and lift hips with bent knees; heels need not touch and weight stays shared through both hands. | Yalnız seçmeli yer yolunda h13 masadan parmakları tak, dizler bükülü kalçayı kaldır; topuk teması gerekmez, yük iki ele dağılsın.",
            "For the wall route walk in and stand; for the floor route lower both knees gently to padding and use the tabletop exit. | Duvar yolunda yaklaşarak doğrul; yer yolunda iki dizi yavaşça mindere indir ve masa çıkışını kullan."],
            "Compare one wall entry with observation or one short floor entry; record which route you actually practised. | Bir duvar girişini gözlemle veya kısa yer girişiyle karşılaştır; gerçekten çalıştığın yolu kaydet.",
            "Can you exit before wrist loading or breath effort increases, without forcing heels down? | Topukları zorlamadan, bilek yükü veya nefes çabası artmadan çıkabiliyor musun?",
            "Wall support reduces some loads but is not medical clearance; skip head-below-heart or hand loading if your individual advice restricts it. | Duvar bazı yükleri azaltır fakat tıbbi uygunluk değildir; kişisel önerin kısıtlıyorsa başın kalp altında oluşunu veya el yükünü atla.",
            "Side wall hinge then separately labeled floor route with bent knees; show hands and complete knee-down exit, no match-score overlay. | Yandan duvar katlanması, sonra ayrı etiketli diz bükülü yer yolu; elleri ve tam diz indirerek çıkışı göster, eşleşme puanı yok.", sources=("nccih", "adriene_dog")),
        progression("h47", "Sphinx with forearm support | Önkol destekli Sfenks",
            "Distinguish forearm support from pushing high into cobra. | Önkol desteğini kobrada yükseğe itmekten ayırt et.", [
            "If prone contact is appropriate, lower through your side to the abdomen; place forearms parallel with elbows under or slightly ahead of shoulders. | Yüzüstü temas uygunsa yandan karın üzerine in; önkolları paralel, dirsekleri omuz altında veya az önünde koy.",
            "Press forearms lightly and let the breastbone travel forward and up while the pelvis remains resting. | Önkollara hafif bas; leğen kemiği yerde kalırken göğüs kemiğini öne ve yukarı taşı.",
            "Keep the neck long, breathe without abdominal strain and slide elbows farther forward to reduce the lift. | Boynu uzun tut, karında zorlanma olmadan nefes al; yükselişi azaltmak için dirsekleri öne kaydır.",
            "Lower the chest, rest the forehead, release forearms and leave through the side-roll taught in h16. | Göğsü indir, alnı dinlendir, önkolları bırak ve h16 yana dönüşüyle çık."],
            "Try two brief lifts with a full lowering between; height is not the target. | Arada tam inişle iki kısa yükseliş dene; hedef yükseklik değil.",
            "Did the movement stay in a comfortable small range without a lower-back pinch? | Hareket belde sıkışma olmadan rahat küçük aralıkta kaldı mı?",
            "Do not use prone practice as a general pregnancy adaptation; choose chair observation when abdomen contact, back or arm loading is unsuitable. | Yüzüstünü genel gebelik uyarlaması olarak kullanma; karın teması, sırt veya kol yükü uygun değilse sandalyede gözlem seç.",
            "Side close-up of forearms and pelvis contact; include a smaller lift, normal-speed lowering and clearly separate chair observation. | Önkol ve leğen temasını yandan yakın göster; küçük yükseliş, normal hızda iniş ve ayrı sandalye gözlemi ekle.", sources=("nccih", "acog", "aol_sphinx")),
        progression("h48", "Knees-down plank and exit | Dizler yerde plank ve çıkış",
            "Control supported trunk loading before any flow transition. | Akış geçişinden önce destekli gövde yükünü kontrol et.", [
            "From padded tabletop, place hands under shoulders and walk knees back a little while keeping them on the mat. | Minderli masadan elleri omuz altına koy; dizleri yerde tutarak az geriye yürüt.",
            "Move the chest forward enough to make one comfortable line from head through hips to knees; do not let the waist sag. | Baştan kalçaya ve dizlere rahat bir hat oluşturacak kadar göğsü öne taşı; beli sarkıtma.",
            "Share pressure across the palms and breathe normally for a short pause; stop sooner if shoulders collapse or breathing becomes effortful. | Basıncı avuçlara dağıt, kısa bekleyişte doğal nefes al; omuzlar çöküyor veya nefes zorlaşıyorsa erken bitir.",
            "Shift hips back toward tabletop before taking weight off the hands; this lesson does not ask for a low push-up or full Chaturanga. | Elleri yüksüz bırakmadan kalçayı masaya doğru geri al; bu ders alçak şınav veya tam Chaturanga istemez."],
            "Perform three short enter-pause-exit cycles, resting fully between them. | Arada tam dinlenmeyle üç kısa giriş-bekleme-çıkış döngüsü yap.",
            "Can you return to tabletop before the trunk sags, with knees still supported? | Dizler destekliyken gövde sarkmadan masaya dönebiliyor musun?",
            "Use a wall plank with hands at chest height or observe; wrist, shoulder, abdominal and pregnancy-related limits require individual advice. | Eller göğüs düzeyinde duvar plankı kullan veya gözle; bilek, omuz, karın ve gebelik sınırları bireysel görüş gerektirir.",
            "Side real-time knee walk-back, brief hold and hips-back exit; show palms and wall option. Never morph knees-down plank into Chaturanga. | Yandan gerçek hızda dizleri geri yürütme, kısa kalış ve kalçayla geri çıkış; avuçlarla duvar seçeneği. Diz plankını Chaturanga'ya dönüştürme.", sources=("nccih", "adriene_plank")),
    ]),
    module("integration", "Progression with deliberate choices | Bilinçli seçimlerle ilerleme",
           "Connect learned actions and explore optional strength and balance variations. | Öğrenilen eylemleri bağla, seçmeli güç ve denge varyasyonlarını keşfet.", [
        progression("h49", "Staged Sun A variation | Aşamalı Güneşe Selam A varyasyonu",
            "Follow a taught sequence with pauses and without jumping or low push-ups. | Duraklamalı, sıçramasız ve alçak şınavsız öğretilmiş sırayı izle.", [
            "Start in mountain, raise arms only comfortably, then hinge into h11 with hands on the secured chair or bent-knee floor support. | Dağdan kolları rahat kaldır; sonra sabit sandalyede ellerle veya diz bükülü yer desteğiyle h11 katlanmasına geç.",
            "Pause and lower one knee then the other to tabletop using support. Choose h48 knees-down plank, return to tabletop, then deliberately lower through a side rest to prone only if appropriate. | Dur ve destekle birer dizi masaya indir. h48 diz plankını seç, masaya dön; yüzüstü uygunsa bilinçli yan dinlenmeden karın üzerine geç.",
            "Choose small cobra h17 or rest, return via side sitting to tabletop, and choose h46 floor dog or tabletop. These are separate stations; keep ordinary breathing rather than chasing one breath per move. | Küçük kobra h17 veya dinlenme seç, yan oturuştan masaya dön; h46 yer köpeğini veya masayı seç. Bunlar ayrı duraklar; her harekete bir nefes yetiştirme yerine doğal solunumu koru.",
            "Lower knees, use the chair to reach a supported seat, then stand slowly into mountain. A standing-only wall sequence may end here without floor stations. | Dizleri indir, sandalyeyle destekli oturuşa geç; yavaşça dağa kalk. Yalnız ayakta duvar sırası yer durakları olmadan burada bitebilir."],
            "Rehearse one round as separate stations, then repeat only if entries and exits remain controlled. | Bir turu ayrı duraklar olarak prova et; yalnız giriş ve çıkışlar kontrollüyse yinele.",
            "Can you name each transition and the floor stations you replaced or observed? | Her geçişi ve değiştirdiğin ya da gözlediğin yer duraklarını adlandırabilir misin?",
            "This is an adapted learning sequence, not the complete traditional vinyasa; choose wall hinge and mountain if floor, prone or balance demands are unsuitable. | Bu uyarlanmış öğrenme sırasıdır, tam geleneksel vinyasa değildir; yer, yüzüstü veya denge gereksinimleri uygun değilse duvar katlanması ve dağı seç.",
            "Unbroken wide take with numbered stations; insert slow replays for knee lowering and chair-assisted rising. Label adapted Sun A, no jumps, no Chaturanga or upward dog. | Numaralı duraklarla kesintisiz geniş çekim; diz inişi ve sandalyeyle kalkışı yavaş tekrarla. Uyarlanmış Güneşe Selam A etiketi; sıçrama, Chaturanga veya yukarı köpek yok.", minutes=18, sources=("ycb", "nccih", "adriene_suna")),
        progression("h50", "Supported hinge balance | Destekli kalça katlanması dengesi",
            "Coordinate a hip hinge and a light rear-leg reach before reducing support. | Desteği azaltmadan kalça katlanmasıyla hafif arka bacak uzatmayı birleştir.", [
            "Face a secured chair with both hands resting on it; step one foot slightly behind with toes still down. | Sabit sandalyeye dönüp iki eli koy; bir ayağı parmaklar yerde az geriye al.",
            "Hinge from the front hip while sliding the rear toes back; keep the front knee soft and the pelvis facing the floor. | Arka parmakları geriye kaydırırken ön kalçadan katlan; ön diz yumuşak, leğen kemiği yere dönük kalsın.",
            "If stable, float the rear foot a little with both hands supported; lengthen forward and back without demanding a horizontal Warrior III shape. | Dengeliysen iki el destekliyken arka ayağı az kaldır; yatay Savaşçı III şekli istemeden öne ve arkaya uzan.",
            "Replace the rear toes first, bring torso upright and step feet together before changing sides. | Önce arka parmakları koy, gövdeyi doğrult; taraf değiştirmeden ayakları birleştir."],
            "Try toe-down and optional small-lift versions on both sides; choose support before increasing reach. | İki tarafta parmak yerde ve seçmeli küçük kaldırmayı dene; uzanmayı artırmadan desteği seç.",
            "Could you replace the toes deliberately without hopping or twisting the standing knee? | Sekmeden veya taşıyan dizi döndürmeden parmakları bilinçli koyabildin mi?",
            "Keep both feet grounded or observe when falling is a concern; a wall or chair cannot remove fall risk or establish pregnancy suitability. | Düşme kaygısında iki ayağı yerde tut veya gözle; duvar veya sandalye düşme riskini kaldırmaz, gebelik uygunluğu göstermez.",
            "Side hinge and rear view of pelvis, both hands visible throughout; show toe-down exit before optional foot lift. | Yandan katlanma ve arkadan leğen görünümü, iki el sürekli görünür; seçmeli kaldırmadan önce parmak yerde çıkışı göster.", sources=("nccih", "podclass_warrior3")),
        progression("h51", "Locust: coordinated optional lift | Çekirge: eşgüdümlü seçmeli yükseliş",
            "Progress from h40 single-leg work to an optional small whole-body lift. | h40 tek bacak çalışmasından seçmeli küçük tüm beden yükselişine ilerle.", [
            "Enter prone only if suitable, arms by sides, forehead resting and legs extended without squeezing them together. | Yalnız uygunsa yüzüstüne gir; kollar yanda, alın yerde, bacaklar sıkıştırılmadan uzun olsun.",
            "Reach the toes back and breastbone forward; first lift only the chest a little, then lower before deciding whether to include legs. | Parmakları geriye, göğüs kemiğini öne uzat; önce yalnız göğsü az kaldır, bacakları eklemeyi seçmeden indir.",
            "For the optional combined version lift chest and both legs slightly, with arms reaching back and gaze down; breathe without aiming for height. | Seçmeli birleşik biçimde kollar geriye, bakış aşağıyken göğüsle iki bacağı az kaldır; yükseklik hedeflemeden nefes al.",
            "Lower legs and chest under control, release the effort completely and leave through the h16 side-roll route. | Bacaklarla göğsü kontrollü indir, çabayı tamamen bırak; h16 yana dönüş yoluyla çık."],
            "Compare a chest-only lift with observation or one combined lift; rest fully after each. | Göğüs yükselişini gözlemle veya bir birleşik yükselişle karşılaştır; her birinden sonra tam dinlen.",
            "Can you lower smoothly without a back pinch, breath holding or throwing the head back? | Bel sıkışması, nefes tutma veya başı geriye atma olmadan yumuşak inebiliyor musun?",
            "Pregnancy or abdominal-contact restrictions call for omitting this prone block and seeking personal guidance; h40 is also prone, not an automatic safe substitute. | Gebelik veya karın teması kısıtında bu yüzüstü bölümü atla ve kişisel görüş al; h40 da yüzüstüdür, otomatik güvenli alternatif değildir.",
            "Side and three-quarter continuous lift and lowering; label chest-only, single-leg and combined options, keeping neck and pelvis visible. | Yandan ve çapraz kesintisiz yükseliş-iniş; yalnız göğüs, tek bacak ve birleşik seçenekleri etiketle, boyunla leğen görünür kalsın.", sources=("ycb", "nccih", "acog", "adriene_locust")),
        progression("h52", "Reverse table with bent knees | Dizler bükülü ters masa",
            "Extend h39 into a controlled bent-knee reverse-table option. | h39'u kontrollü diz bükülü ters masa seçeneğine genişlet.", [
            "Sit with knees bent, feet flat roughly hip width and palms behind the hips in a comfortable direction. | Dizler bükülü otur; ayaklar yaklaşık kalça genişliğinde tam yerde, avuçlar kalça arkasında rahat yönde olsun.",
            "Press through hands and feet to raise the pelvis as far as the shoulders permit; move toward a table shape without forcing a level line. | Ellerle ayaklara basıp omuzların izin verdiği kadar leğeni kaldır; düz hat zorlamadan masa şekline yaklaş.",
            "Keep knees pointing along the feet, collarbones broad and neck in line with the torso; maintain an easy breath instead of dropping the head back. | Dizler ayak yönünde, köprücükler açık, boyun gövde hizasında kalsın; başı geriye düşürmeden rahat nefesi koru.",
            "Bend at the hips to lower the seat slowly; only after sitting down release hands and rest the wrists. | Kalçadan bükülerek yavaş otur; yalnız oturduktan sonra elleri bırakıp bilekleri dinlendir."],
            "Do two separate lifts, choosing the short h39 version whenever shoulder range limits height. | İki ayrı yükseliş yap; omuz aralığı yüksekliği sınırlıyorsa kısa h39 biçimini seç.",
            "Did you keep the neck comfortable and lower before hand or shoulder strain appeared? | Boynu rahat tutup el veya omuz zorlanmadan indin mi?",
            "Observe or choose seated chest opening if hand loading is unsuitable. This bent-knee version does not establish the straight-leg Purvottanasana skill. | El yükü uygun değilse gözle veya oturarak göğüs açmayı seç. Diz bükülü bu biçim düz bacak Purvottanasana becerisi göstermez.",
            "Side entry and full lowering, wrist placement close-up and small-height comparison; show no head drop or unsupported straight-leg progression. | Yandan giriş ve tam iniş, bilek yerleşimi yakın planı ve küçük yükseklik karşılaştırması; başı düşürme veya öğretilmemiş düz bacak ilerlemesi yok.", sources=("ycb", "nccih", "yi_reverse")),
        progression("h53", "Small standing back extension | Küçük ayakta geriye uzama",
            "Explore an Ardha Chakrasana preparation distinct from side bending. | Yana eğilmeden farklı Ardha Chakrasana hazırlığını keşfet.", [
            "Stand near a wall with feet hip width; place palms at the back of the pelvis or keep one hand on support. | Ayaklar kalça genişliğinde duvar yanında dur; avuçları leğen arkasına veya bir eli desteğe koy.",
            "Lengthen upward first and lift the breastbone a little; allow only a small upper-body extension without pushing the hips forward. | Önce yukarı uzan, göğüs kemiğini az kaldır; kalçayı öne itmeden üst bedende küçük uzamaya izin ver.",
            "Keep knees soft and gaze forward or slightly up; breathe normally and avoid dropping the head or seeking a deep lower-back bend. | Dizleri rahat, bakışı öne veya az yukarı tut; doğal nefes al, başı düşürme veya belde derin kavis arama.",
            "Return the chest above the pelvis, lower hands and pause in mountain before walking. | Göğsü leğenin üstüne getir, elleri indir; yürümeden dağda bekle."],
            "Rehearse two small extensions with a complete mountain reset between them. | Arada tam dağ kurulumu ile iki küçük uzamayı prova et.",
            "Can you distinguish lifting the chest from pinching the lower back or tipping off balance? | Göğsü kaldırmayı bel sıkıştırmaktan veya dengeden çıkmaktan ayırt edebiliyor musun?",
            "Stay in mountain or observe with back discomfort, dizziness or uncertain balance. A smaller backbend is not automatically suitable for a health condition. | Sırt belirtisi, baş dönmesi veya belirsiz dengede dağda kal veya gözle. Küçük geriye eğilme bir sağlık durumu için otomatik uygun değildir.",
            "Side close-up of chest rising before a small arc; show return to vertical, wall hand and neutral-neck alternative. Label preparation, not a required deep backbend. | Küçük kavisten önce göğsün yükselişini yandan yakın göster; dik dönüşü, duvar elini ve nötr boyun seçeneğini ekle. Derin zorunlu eğilme değil hazırlık etiketi.", sources=("ycb", "ayush", "nccih")),
        progression("h54", "Half-plough awareness and leg control | Yarım saban bilgisi ve bacak kontrolü",
            "Distinguish Ardha Halasana leg elevation from a full overhead plough. | Ardha Halasana bacak yükselişini baş üstüne geçen tam sabandan ayırt et.", [
            "Review h27 first. If back lying is suitable, enter through the side with knees bent and both feet down; otherwise use the lesson diagram from a chair. | Önce h27'yi gözden geçir. Sırtüstü uygunsa yandan, dizler bükülü iki ayak yere gir; değilse sandalyeden ders çizimini kullan.",
            "Lift one bent knee toward the hip as in h27; optionally extend that lower leg toward the ceiling only as far as the back stays comfortable. | h27'deki gibi bir bükülü dizi kalçaya doğru kaldır; sırt rahat kaldığı kadar alt bacağı seçmeli tavana uzat.",
            "Keep the other foot grounded and breathe normally. The paired straight-leg Ardha Halasana is identified for instructor guidance, not assigned as an independent next step. | Öteki ayağı yerde tut ve doğal nefes al. İki düz bacaklı Ardha Halasana eğitmen rehberliği için tanıtılır; bağımsız sonraki adım olarak verilmez.",
            "Bend the raised knee before placing its foot down, then roll sideways to leave; never swing legs behind the head in this course. | Kalkık dizi büküp ayağı koy, sonra yana dönerek çık; bu kursta bacakları başın arkasına savurma."],
            "Practise the h27-based one-leg option or explain the diagram; record practice and knowledge separately. | h27 temelli tek bacak seçeneğini çalış veya çizimi açıkla; çalışma ve bilgiyi ayrı kaydet.",
            "Can you explain why this one-leg preparation is not the full paired-leg pose or a shoulder stand? | Bu tek bacak hazırlığının neden tam çift bacak pozu veya omuz duruşu olmadığını açıklayabilir misin?",
            "Supine and abdominal-loading restrictions, including pregnancy-related limits, require a different personal plan; chair observation is available. | Gebelikle ilgili sınırlar dahil sırtüstü ve karın yükü kısıtları farklı kişisel plan gerektirir; sandalyede gözlem seçilebilir.",
            "Side one-leg preparation and exit; separate static labeled silhouette for paired-leg knowledge only. Never animate legs over the head or imply pregnancy suitability. | Yandan tek bacak hazırlığı ve çıkış; yalnız bilgi için ayrı etiketli çift bacak silueti. Baş üstüne bacak animasyonu veya gebelik uygunluğu ima etme.", sources=("ycb", "nccih", "acog")),
    ]),
    module("independent_intermediate", "Intermediate practice and scope | Orta seviye çalışma ve kapsam",
           "Understand optional boundaries and build an honest, self-reviewed practice. | Seçmeli sınırları anla, dürüst öz değerlendirmeyle çalışma kur.", [
        progression("h55", "Lotus and kneeling forms: knowledge | Lotus ve diz üstü biçimler: bilgi",
            "Recognize Padmasana, Mandukasana and Uttana Mandukasana without making them required achievements. | Padmasana, Mandukasana ve Uttana Mandukasana'yı zorunlu kazanım yapmadan tanı.", [
            "Sit in h04 easy seat or a chair and view labeled diagrams; keep your own legs uncrossed if that is more comfortable. | h04 rahat oturuşta veya sandalyede etiketli çizimlere bak; daha rahatsa kendi bacaklarını çaprazlama.",
            "Identify lotus as feet placed on opposite thighs; do not pull a foot into position or press a knee down. NCCIH advises beginners to avoid lotus. | Lotusu ayakların karşı uyluklara yerleşmesi olarak tanı; ayağı konuma çekme veya dizi bastırma. NCCIH başlangıçta lotustan kaçınmayı önerir.",
            "Identify kneeling frog and upright frog variants by their leg and arm arrangements; names differ between traditions. Abdominal compression and deep knee flexion are reasons for individual teaching, not universal targets. | Diz üstü kurbağa ve dik kurbağa biçimlerini bacak ve kol düzeniyle tanı; adlar geleneklere göre değişir. Karın sıkışması ve derin diz bükülmesi evrensel hedef değil bireysel öğretim nedenidir.",
            "Close the diagrams and return to a neutral seat; choose to discuss a specific form with a qualified teacher rather than attempting it from this survey. | Çizimleri kapatıp nötr oturuşa dön; bu tanıtımdan denemek yerine belirli biçimi nitelikli eğitmenle görüşmeyi seç."],
            "Name the three forms and write one personal question for a teacher; no physical performance is required. | Üç biçimi adlandır, eğitmene bir kişisel soru yaz; fiziksel uygulama gerekmez.",
            "Can you distinguish knowing a pose name from practising or being assessed in it? | Pozun adını bilmeyi çalışmaktan veya değerlendirilmekten ayırt edebiliyor musun?",
            "Pregnancy, knee or hip concerns can change suitability; this knowledge lesson gives no clearance for lotus, compression or kneeling. | Gebelik, diz veya kalça sorunları uygunluğu değiştirebilir; bilgi dersi lotus, sıkıştırma veya diz üstü için uygunluk vermez.",
            "Three clearly labeled, instructor-reviewed still diagrams; no step-by-step forced knee placement, no flexibility challenge, knowledge-only banner throughout. | Eğitmen incelemeli, açık etiketli üç durağan çizim; zorla diz yerleştirme adımları veya esneklik meydan okuması yok, sürekli yalnız bilgi etiketi.", minutes=10, sources=("ycb", "nccih", "acog")),
        progression("h56", "Fish pose and neck-load boundaries | Balık pozu ve boyun yükü sınırları",
            "Locate Saral Matsyasana in the syllabus while separating knowledge from unsupervised neck loading. | Saral Matsyasana'yı müfredatta tanı; bilgiyi rehbersiz boyun yükünden ayır.", [
            "Begin seated with the head upright and review a labeled side diagram of simple fish; this is a knowledge lesson, not a demand to reproduce it. | Baş dik oturup basit balığın etiketli yan çizimini incele; bu bilgi dersidir, şekli yapma isteği değildir.",
            "Locate the raised chest, arm support and head position; notice that similar-looking versions place different loads on the neck. | Yükselen göğsü, kol desteğini ve baş konumunu bul; benzer görünen biçimlerin boyna farklı yük verdiğini fark et.",
            "For a physical option remain seated, hold the chair sides lightly and widen the chest without tipping the head back; this is not Saral Matsyasana performance. | Fiziksel seçenek için otur, sandalye yanlarını hafif tut ve başı geriye atmadan göğsü aç; bu Saral Matsyasana uygulaması değildir.",
            "Release hands and return to a neutral seat; seek individual instruction before trying a floor fish variation or head contact. | Elleri bırakıp nötr oturuşa dön; yerde balık varyasyonu veya baş teması denemeden bireysel öğretim al."],
            "Explain the diagram, then optionally compare neutral sitting and a small seated chest opening. | Çizimi açıkla; sonra seçmeli nötr oturuş ile küçük oturarak göğüs açmayı karşılaştır.",
            "Can you name the neck-loading issue and explain why the seated option is a separate movement? | Boyun yükü konusunu adlandırıp oturarak seçeneğin neden ayrı hareket olduğunu açıklayabilir misin?",
            "Neck, back, balance or pregnancy-related supine limits require personal advice; no prop or alternate shape here guarantees suitability. | Boyun, sırt, denge veya gebelikle ilgili sırtüstü sınırlarında kişisel görüş gerekir; buradaki hiçbir destek veya farklı şekil uygunluk garantisi vermez.",
            "Separate labeled knowledge diagram from seated demonstration; no head-bearing transition animation or visual claim of equivalence. | Etiketli bilgi çizimini oturarak gösterimden ayır; başa yük veren geçiş animasyonu veya eşdeğerlik iddiası yok.", minutes=10, sources=("ycb", "nccih", "acog")),
        progression("h57", "Standing sequence with direction changes | Yön değişimli ayakta sıra",
            "Integrate Warriors, triangle and hinge balance using deliberate foot resets. | Bilinçli ayak kurulumuyla savaşçıları, üçgeni ve katlanma dengesini birleştir.", [
            "Place chair and wall within reach and start in mountain; choose a short stance for h44 Warrior I. | Sandalye ve duvarı erişime koy, dağda başla; h44 Savaşçı I için kısa duruş seç.",
            "Return to mountain before setting h45 Warrior II. Straighten, lower arms and reset the feet before entering h09 supported triangle. | h45 Savaşçı II'yi kurmadan dağa dön. h09 destekli üçgene girmeden doğrul, kolları indir ve ayakları yeniden kur.",
            "Return to mountain again, then choose h50 supported hinge balance or toe-down hinge; keep the same support plan on both sides and breathe normally. | Yeniden dağa dön; h50 destekli katlanma dengesini veya parmak yerde katlanmayı seç. İki tarafta aynı destek planı ve doğal nefes olsun.",
            "Repeat the separate sequence on the other side, then sit and release the effort; no pivot is made on a deeply bent loaded knee. | Ayrı sırayı öteki tarafta yinele, sonra oturup çabayı bırak; derin bükülü yüklü diz üzerinde dönme."],
            "Complete one slow sequence per side, pausing in mountain between skills. | Beceriler arasında dağda durarak iki tarafta birer yavaş sıra tamamla.",
            "Could you tell which foot needed resetting before each change and choose support before losing balance? | Her değişimden önce hangi ayağı yeniden kuracağını bilip denge kaybından önce desteği seçebildin mi?",
            "Use shallow two-foot versions or replace the balance block with mountain; record the selected skills instead of claiming all variations. | Sığ iki ayaklı biçimleri kullan veya dengeyi dağla değiştir; tüm varyasyonları yaptığını söylemek yerine seçilen becerileri kaydet.",
            "Continuous wide route plus overhead foot diagram; count each mountain reset and show both sides without cutting out support changes. | Kesintisiz geniş yol ve üstten ayak çizimi; her dağ dönüşünü say, destek değişimlerini kesmeden iki tarafı göster.", minutes=20, sources=("nccih", "adriene_warrior1", "adriene_warrior2")),
        progression("h58", "Flow and strength blocks | Akış ve güç bölümleri",
            "Link familiar blocks while preserving rest and safe ways to change floor orientation. | Dinlenmeyi ve yer yönünü kontrollü değiştirmeyi koruyarak tanıdık bölümleri bağla.", [
            "Choose h49 adapted Sun A or its standing route and review all support placements before starting. | h49 uyarlanmış Güneşe Selam A'yı veya ayakta yolunu seç; başlamadan destekleri gözden geçir.",
            "Finish the round in a seat and rest. Separately choose h51 locust, h52 reverse table, their earlier preparations, or observation; do not roll directly between loaded poses. | Turu oturarak bitirip dinlen. Ayrı olarak h51 çekirge, h52 ters masa, önceki hazırlıkları veya gözlemi seç; yüklü pozlar arasında doğrudan yuvarlanma.",
            "Set up each chosen floor orientation from a neutral side or seated position, complete one short attempt and release fully before the next block. | Seçilen her yer yönünü nötr yan veya oturuştan kur; bir kısa deneme yapıp sonraki bölümden önce tamamen bırak.",
            "End in h29 chosen rest, then rise slowly through a supported seat; write which strength blocks were omitted. | h29 seçilmiş dinlenmede bitir, destekli oturuştan yavaş kalk; atlanan güç bölümlerini yaz."],
            "Practise one flow block and up to two optional strength blocks with generous pauses. | Bol duraklamayla bir akış bölümü ve en fazla iki seçmeli güç bölümü çalış.",
            "Could you maintain deliberate setup after the flow, or was it better to rest and omit a block? | Akıştan sonra bilinçli kurulumu koruyabildin mi, yoksa dinlenip bir bölümü atlamak daha mı uygundu?",
            "Omit prone, supine, hand-loading or balance blocks according to your personal limits; there is no universal pregnancy sequence in this lesson. | Kişisel sınırlarına göre yüzüstü, sırtüstü, el yükü veya denge bölümlerini atla; bu derste herkese uyan gebelik sırası yok.",
            "Wide real-time block transitions with visible rests; show choosing observe, separate prone and seated setups, and calm controlled exits. | Görünür dinlenmelerle geniş gerçek zamanlı bölüm geçişleri; gözlem seçimi, ayrı yüzüstü ve oturma kurulumları, sakin kontrollü çıkışlar.", minutes=22, sources=("ycb", "nccih", "acog", "adriene_suna", "adriene_locust", "yi_reverse")),
        progression("h59", "Design an intermediate practice | Orta seviye çalışma tasarla",
            "Choose a repeatable practice with explicit alternatives and honest scope. | Açık alternatifleri ve dürüst kapsamı olan yinelenebilir çalışma seç.", [
            "Review h42 and list skills now practised independently, skills needing support, and forms only studied as knowledge. | h42'yi gözden geçir; bağımsız çalıştığın, destek gereken ve yalnız bilgi olarak incelediğin biçimleri listele.",
            "Plan preparation, the h57 standing sequence, an optional h49 or h58 block, seated breath and rest; allow about 25–35 minutes with shorter choices. | Hazırlık, h57 ayakta sıra, seçmeli h49 veya h58 bölümü, oturarak nefes ve dinlenme planla; kısa seçeneklerle yaklaşık 25–35 dakika ayır.",
            "Write the exit and substitute beside every demanding skill; schedule pauses rather than using breath holding or speed to finish on time. | Zorlayıcı her becerinin yanına çıkışı ve alternatifi yaz; zamanında bitirmek için nefes tutma veya hız yerine molalar koy.",
            "Rehearse only the unfamiliar transitions once, then revise the written plan before h60; seek instruction for unresolved problems. | Tanıdık olmayan geçişleri yalnız bir kez prova et; h60 öncesi yazılı planı düzelt, çözülmeyen sorunlarda öğretim al."],
            "Create one standard and one shorter personal plan with the actual selected lesson IDs. | Gerçekte seçilen ders kimlikleriyle bir olağan ve bir kısa kişisel plan hazırla.",
            "Does every demanded action appear in an earlier taught lesson, and can you explain what your plan does not demonstrate? | İstenen her eylem önceki öğretilen derste var mı; planının neyi göstermediğini açıklayabilir misin?",
            "If new health limits make the old plan uncertain, use observation and individual guidance instead of assuming an earlier adaptation still applies. | Yeni sağlık sınırları eski planı belirsiz yapıyorsa önceki uyarlamanın geçerli olduğunu varsaymak yerine gözlem ve bireysel görüş kullan.",
            "Readable course cards showing taught IDs, duration choices and exits; separate practice, adapted practice and knowledge-only labels. | Öğretilen kimlikler, süre seçenekleri ve çıkışları gösteren okunaklı kartlar; çalışma, uyarlanmış çalışma ve yalnız bilgi etiketlerini ayır.", minutes=15, sources=("ycb", "nccih")),
        progression("h60", "Independent intermediate self-review | Bağımsız orta seviye öz değerlendirme",
            "Carry out your selected plan and describe control, transitions and limits without a camera grade. | Kamera puanı olmadan seçtiğin planı uygula; kontrolü, geçişleri ve sınırları anlat.", [
            "Read the h59 plan, prepare supports and confirm today's chosen blocks; mark observation or omission before starting when needed. | h59 planını oku, destekleri hazırla ve bugünkü bölümleri doğrula; gerekirse başlamadan gözlem veya atlamayı işaretle.",
            "Follow preparation and h57 standing work, returning to mountain between directions; continue with your selected h49 or h58 block at your own pace. | Hazırlığı ve h57 ayakta çalışmayı yönler arasında dağa dönerek izle; seçilen h49 veya h58 bölümünü kendi hızında sürdür.",
            "Use ordinary breathing and planned rests; replace or stop a block when control, comfort or personal limits change instead of chasing completion. | Doğal nefes ve planlı molalar kullan; tamamlamayı kovalamak yerine kontrol, rahatlık veya kişisel sınır değişirse bölümü değiştir veya durdur.",
            "Finish with chosen rest, then record the actual route, one controlled transition, one useful support and one skill still needing instruction. | Seçilen dinlenmeyle bitir; gerçek yolu, bir kontrollü geçişi, yararlı bir desteği ve hâlâ öğretim gereken bir beceriyi kaydet."],
            "Use the h59 plan for approximately 25–35 minutes or its shorter version; repeats are available and no pose is compulsory. | h59 planını yaklaşık 25–35 dakika veya kısa biçimiyle kullan; tekrar yapılabilir ve hiçbir poz zorunlu değildir.",
            "Can you explain your setup, foot resets, controlled exits and chosen omissions? Completion records participation, not certified intermediate ability or medical suitability. | Kurulumunu, ayak değişimlerini, kontrollü çıkışlarını ve atlamalarını açıklayabilir misin? Tamamlama katılım kaydıdır; sertifikalı orta seviye beceri veya tıbbi uygunluk değildir.",
            "An adapted or observation route remains available; it records what you actually did and does not establish competence in omitted balance, floor or strength skills. | Uyarlanmış veya gözlem yolu açıktır; gerçekte yaptığını kaydeder, atlanan denge, yer veya güç becerilerinde yeterlik göstermez.",
            "Three honest routes with full entries, exits and rests; finish with a learner reflection and chosen-skill list, never a mastery badge or camera score. | Tam giriş, çıkış ve dinlenmeli üç dürüst yol; ustalık rozeti veya kamera puanı yerine öğrenci değerlendirmesi ve seçilen beceri listesiyle bitir.", minutes=35, sources=("ycb", "nccih", "acog")),
    ]),
])

# These warnings supplement, rather than certify, the individualized alternatives.
for _id in ("h16", "h17", "h18", "h40", "h47", "h51"):
    _item = next(item for mod in MODULES for item in mod["lessons"] if item["id"] == _id)
    _item["adaptation"]["en"] += " Prone abdominal contact is not a general pregnancy option; observe when personal suitability is uncertain."
    _item["adaptation"]["tr"] += " Yüzüstü karın teması genel gebelik seçeneği değildir; kişisel uygunluk belirsizse gözle."
for _id in ("h25", "h26", "h27", "h28", "h29", "h30", "h54"):
    _item = next(item for mod in MODULES for item in mod["lessons"] if item["id"] == _id)
    _item["sourceIds"] = list(dict.fromkeys([*_item["sourceIds"], "nhs_pregnancy"]))
    _item["adaptation"]["en"] += " Pregnancy may require avoiding prolonged flat-back lying; seek individual advice rather than treating this option as clearance."
    _item["adaptation"]["tr"] += " Gebelikte uzun süre düz sırtüstü yatmaktan kaçınmak gerekebilir; bu seçeneği uygunluk onayı saymak yerine bireysel görüş al."


SOURCES = {
    "ycb": "https://yogacertificationboard.nic.in/wp-content/uploads/2019/11/Syllabus-YPI-Version0.2.pdf",
    "ayush": "https://www.yogamdniy.nic.in/files/pdf/CYP-2023-English.pdf",
    "nccih": "https://www.nccih.nih.gov/health/yoga-effectiveness-and-safety",
    "acog": "https://www.acog.org/womens-health/faqs/exercise-during-pregnancy",
    "adriene_tadasana": "https://www.youtube.com/watch?v=NYhH8Gr35cI",
    "adriene_lunge": "https://yogawithadriene.com/runners-lunge-foundations-of-yoga/",
    "adriene_warrior1": "https://yogawithadriene.com/warrior-i-pose/",
    "adriene_warrior2": "https://yogawithadriene.com/warrior-ii-pose/",
    "adriene_dog": "https://yogawithadriene.com/downward-facing-dog/",
    "adriene_plank": "https://yogawithadriene.com/plank-pose/",
    "adriene_suna": "https://yogawithadriene.com/sun-salutation-a-surya-namaskara-a/",
    "adriene_locust": "https://yogawithadriene.com/locust-pose-salabasana/",
    "aol_sphinx": "https://www.artofliving.org/us-en/yoga/poses/sphinx-pose",
    "yi_reverse": "https://yogainternational.com/article/view/upward-plank-pose/",
    "podclass_warrior3": "https://www.yogapodclass.com/poses/warrior-iii",
    "nhs_pregnancy": "https://www.nhs.uk/pregnancy/keeping-well/exercise/",
}


def render():
    previous = None
    for mod in MODULES:
        for item in mod["lessons"]:
            item["prerequisites"] = [previous] if previous else []
            previous = item["id"]
    result = {
        "schemaVersion": 1,
        "id": "lissom.hatha.foundations",
        "version": "1.0.0",
        "title": text_pair("Hatha: foundations to intermediate practice | Hatha: temelden orta seviye çalışmaya"),
        "intro": text_pair(
            "A 60-lesson Hatha course from foundations to selected intermediate practice. Routes include adaptations and knowledge-only topics; this is not the whole yoga tradition or instructor certification. You record practice yourself; the camera does not grade these postures."
            " | Temelden seçilmiş orta seviye çalışmaya 60 derslik Hatha kursu. Uyarlamalar ve yalnız bilgi konuları içerir; tüm yoga geleneği veya eğitmen sertifikası değildir. Çalışmanı kendin kaydedersin; kamera bu pozları puanlamaz."
        ),
        "sources": SOURCES,
        "modules": MODULES,
    }
    return json.dumps(result, ensure_ascii=False, indent=2) + "\n"


if __name__ == "__main__":
    rendered = render()
    if "--check" in sys.argv:
        if not OUTPUT.exists() or OUTPUT.read_text(encoding="utf-8") != rendered:
            raise SystemExit("hatha course JSON differs from authored source")
    else:
        OUTPUT.parent.mkdir(parents=True, exist_ok=True)
        OUTPUT.write_text(rendered, encoding="utf-8")
