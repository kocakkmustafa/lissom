#!/usr/bin/env python3
"""Wellness dil süzgeci — kullanıcıya görünen İngilizce metinlerin CI denetimi.

Neden: Lissom bir wellness ürünü. Tek bir aşırı ifade ("diagnoses", "treats
your pain", "clinically proven") ürünü tıbbi cihaz sınırına iter — FDA General
Wellness politikası ve Apple 1.4.1 buna bakar. Bu risk kod incelemesiyle değil,
otomatik taramayla yönetilir; insan gözü er geç bir satırı kaçırır.

Kaynak liste: docs/research/09-wellness-dil-suzgeci.md §4
Bağımlılık YOK — saf stdlib, herhangi bir python3 ile koşar.

Çalıştırma:
    python3 tools/wellness_lint.py            # config/ altındaki tüm metinleri tara
    python3 tools/wellness_lint.py --path X   # belirli bir dosya/klasör
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# --------------------------------------------------------------------------
# Yasaklı kalıplar
# --------------------------------------------------------------------------
# HARD: hastalık adı, regülatif iddia, tedavi. Yalnız aşağıdaki dar
# bağlam kontrolü açık fiziksel doz reddini ayırır; tıbbi reçete reddi geçmez.
HARD = [
    r"\bcure[sd]?\b",
    r"\bprescrib\w*", r"\bprescription\b",
    r"\bFDA[- ](cleared|approved)\b",
    r"\bmedical[- ]grade\b",
    r"\bclinically (proven|validated)\b",
    r"\bimpingement\b", r"\brotator cuff tear\b", r"\bosteoarthritis\b",
    r"\bscoliosis\b", r"\bherniat\w*", r"\bdegenerat\w*",
    r"\bpathology\b", r"\bsyndrome\b", r"\bdisorder\b",
    r"\breplace[s]? (your )?(doctor|physical therapy|physiotherapy)\b",
    r"\bguaranteed\b", r"\bpermanently fix\b",
    r"\bblood (pressure|oxygen|glucose)\b", r"\bx-?ray\b",
    r"\bclinical threshold\b", r"\bdiagnostic threshold\b",
]

# PROMISE: M-F-186 vaat dili. HARD sınıfı — olumsuzlama KAÇIŞI YOK.
#
# ⚠️ **Bu kategori bir KÖRLÜKTEN doğdu (L-229), ve körlüğün yeri öğretici.**
# Widget ağacını tarayan `test/support/copy_gate.dart` bu üç ihlali GÖREMEDİ:
#
#   1. `summary_strings.dart` metinleri `BatterySummaryView`e gidiyor, o da
#      kabuktan ERİŞİLEMEZ (L-225). **Ulaşılamayan ama yine de GÖNDERİLEN
#      kodu, ağaç-tarayan bir kapı tanımı gereği göremez.**
#   2. Config `userText` alanı `USER_FACING_KEYS`te hiç YOKTU — o alan bugüne
#      dek hiçbir denetimden geçmemişti, ve doğrudan yüzeye gidiyor.
#
# Kaynak-düzeyi tarama ikisini de kapatır: erişilebilirlikten bağımsız, ve
# config alanı listeye girdiği anda geçmişe dönük de tarar.
#
# Aile dersi 8'in uygulanışı: **tuzak dosyaya değil DESENE yazılır.** Kuralı
# `library_screen.dart`ta doğru yazmış olmam, iki dosya öteki ihlali
# engellemedi — kural yorumda yaşarsa yalnız o dosyada yaşar.
PROMISE = [
    r"\byet\b",
    r"coming soon",
    r"comingSoon",
    r"\bsoon\b",
]

#: KOŞULLU VAAT: `will` üç ayrı sınıf taşır ve süzgeç ikisini ayırt etmeliydi
#: — ama **hiç bakmıyordu** (L-245, kapı envanteri):
#:
#:   ① *"the number **will** appear here"* tek başına → TARİHSİZ VAAT
#:   ② *"**When** that study is run, the number **will** appear here"* →
#:      ADI OLAN BİR KOŞULA bağlı, M-F-186 uyumlu (`promotionPath` deseni)
#:   ③ *"we are not going to guess **when** they **will**"* → vaadin REDDİ
#:
#: Depodaki üç `will` kullanımının üçü de ②/③ sınıfında — yani ihlal YOK, ama
#: **hiçbir şey onları o sınıfta tutmuyordu.** Kapı kelimeyi değil BİÇİMİ
#: ölçmeli.
CONDITIONAL_PROMISE = [r"\bwill\b"]

#: Koşul yalnız ilgili cümle/noktalı-virgül/satır maddesini yönetir.
#: Önceki güvenlik koşulu bağımsız bir gelecek vaadini yetkilendirmez.
CONDITION = re.compile(
    r"\b(when|once|if|until|after|as long as)\b", re.IGNORECASE)

# SOFT: olumsuzlama içinde meşru olabilir ("does not diagnose", "not a medical
# device"). Olumsuzlanmamışsa ihlaldir.
SOFT = [
    r"\bdiagnos\w*",
    r"\btreat(s|ed|ment|ments)?\b",
    r"\bdisease\b",
    r"\bsymptom[s]?\b",
    r"\bmedical device\b",
]

#: SOFT kalıbın hemen öncesinde bunlardan biri varsa olumsuzlama sayılır.
#:
#: BİLİNEN SINIRLILIK (negatif testte ölçüldü): pencere 4 kelime. Olumsuzlama
#: ile yasaklı kelime arasına 5+ kelime girerse ihlal sanılır — ör. "We cannot
#: diagnose what is causing your symptoms" cümlesinde "symptoms" işaretlenir.
#: Pencereyi genişletmek gerçek ihlalleri kaçırma riskini büyütür, o yüzden
#: muhafazakâr bırakıldı: yanlış alarmı insan eler, kaçan ihlali kimse elemez.
NEGATION = re.compile(
    r"(not|never|cannot|can't|does not|doesn't|do not|don't|no|without|"
    r"isn't|is not|aren't|are not|nor|neither)\W+(\w+\W+){0,4}$",
    re.IGNORECASE,
)

#: Denetimden MUAF dosyalar — disclaimer metinleri, yasaklı kelimeyi
#: olumsuzlama içinde kullanmak zorundadır.
EXEMPT_FILES = {"disclaimers.en.json"}

# Only these exact shipped Hatha fields have been reviewed as contextual
# false positives. The digest binds every byte of the user-facing sentence;
# changing a warning or adding a new claim makes the normal rules fire again.
# The h28 blood-pressure warning is a contraindication, not an efficacy claim:
# https://health.clevelandclinic.org/benefits-of-legs-up-the-wall
# The four "treat" matches describe how to regard learning stations/records,
# never treatment of a person or condition.
REVIEWED_HATHA_COPY = {
    ("hatha.v1.json :: modules[4].lessons[3].adaptation.en",
     "2654f05c260112ec01fd3d14da15a27bd13214aea9350b6bd2fa7b69e32725ec"):
        frozenset({"blood pressure"}),
    ("hatha.v1.json :: modules[6].lessons[5].practice.en",
     "4d374f5a4d54d909b37c1047edaecad9a26648675953d9047594f43b4e60c5d0"):
        frozenset({"treated"}),
    ("hatha.v1.json :: modules[8].lessons[0].practice.en",
     "2a7aad02f555461b61169a20752e74e04a22a6b8c962295224930d59085ddfb2"):
        frozenset({"treat"}),
    ("hatha.v1.json :: modules[8].lessons[0].selfCheck.en",
     "5fec91d92f6d99dacb5ce6c7dd100f82437cd25abfd0a3876d5e4b4a8f0748d6"):
        frozenset({"treat"}),
    ("hatha.v1.json :: modules[9].lessons[1].practice.en",
     "a73b628ad950a32030954b282089129de0f29ce7ecc4230d8a4155a251d4474c"):
        frozenset({"treated"}),
}


# Newly displayed answer keys and source-scope lists. These are stop/retest
# instructions or explicit limits on what a cited source supports, not claims
# that Lissom diagnoses or treats a condition. Review binds the complete field,
# its exact source location and only the matched words listed here.
REVIEWED_CONTEXT_COPY = {
    ("chair-office.v1.json :: modules[0].lessons[2].answerKey.en",
     "18dc690d14dafca96ce60d1333b5133bd7108839c277abc83200b78469e11e29"):
        frozenset({"symptom"}),
    ("chair-office.v1.json :: modules[1].lessons[1].answerKey.en",
     "4bea07b34ae4ecd798379c158cf08bc6c2ea37a67afbb0115614db3922b7ed91"):
        frozenset({"symptoms"}),
    ("chair-office.v1.json :: modules[3].lessons[0].answerKey.en",
     "c536f189ab76da6d94dc96438fc6fab44084ff8fb9810494804d5f0320f3386b"):
        frozenset({"medical grade"}),
    ("vinyasa-standing.v1.json :: modules[0].lessons[4].answerKey.en",
     "d902cb9016f7c13cf62804804110a8666c468a2d30b815e13a5b1b13777988c2"):
        frozenset({"symptom"}),
    ("vinyasa-standing.v1.json :: modules[1].lessons[2].answerKey.en",
     "3f52a68832d9973f3e76930bad4d56c11d31b76bea64695e65378241ac885ddb"):
        frozenset({"diagnosing", "symptom"}),
    ("yin-supported.v1.json :: modules[1].lessons[0].answerKey.en",
     "0620cee2dc877ed29e2d2c1a55c0dc05a6e305240e7de3944e82d937b13245bd"):
        frozenset({"symptom"}),
    ("hatha.v1.json :: sourceScopes.ace_bent_knee_reverse_table.doesNotSupport.en",
     "7419215ac13cdd592a2e4bbad710cd8fb73beec299624a2efdeee8c3a787dc0d"):
        frozenset({"diagnosis"}),
    ("hatha.v1.json :: sourceScopes.nhs_pregnancy.doesNotSupport.en",
     "f3fe0cd947426cb6294384994eae577a65ca81cd682f22761bf03c3ce27b05ea"):
        frozenset({"diagnosis"}),
    ("hatha.v1.json :: sourceScopes.yj_locust_combined.doesNotSupport.en",
     "c0ad3e9aa18949b3dcddb9b0e14c589f831e76d6bf0e952a2363b2fae91be4ad"):
        frozenset({"diagnosis"}),
    ("hatha.v1.json :: sourceScopes.cc_wall_legs.supports.en",
     "12aadcc700eb755ac519b5a37b7dc8bfddfdb7a5b67c18e37e896501d111ab71"):
        frozenset({"blood pressure"}),
    ("hatha.v1.json :: sourceScopes.cc_wall_legs.doesNotSupport.en",
     "103bb5aac2171ba8e6cb2fba37c67ba793a6157a959d8cddcb28bbfd33d84555"):
        frozenset({"symptom", "treatment"}),
}
_REVIEWED_COPY = {**REVIEWED_HATHA_COPY, **REVIEWED_CONTEXT_COPY}
_REVIEWED_COURSE_PATHS = frozenset(
    "config/courses/" + where.split(" :: ", 1)[0]
    for where, _ in _REVIEWED_COPY
)
_CATALOG_LOCALES = frozenset({
    "tr", "en", "es-419", "pt-BR", "de", "fr", "ja", "ar",
    "it", "ko", "id", "pl", "hi", "zh-Hans",
})
_CATALOG_REVIEW_LOCATION = re.compile(
    r"config/l10n/(?P<locale>tr|en|es-419|pt-BR|de|fr|ja|ar|it|ko|id|pl|hi|zh-Hans)\.json :: "
    r"messages\[\d+\]\.(?P<leaf>source|text|zero|one|two|few|many|other)\Z"
)


def _load_translation_reviews(path: Path) -> frozenset[tuple[str, str, str, str, str]]:
    """A missing or malformed review artifact fails closed, never as no reviews."""
    data = json.loads(path.read_text(encoding="utf-8"))
    if (not isinstance(data, dict)
            or set(data) != {"schemaVersion", "id", "scope", "reviews"}
            or type(data.get("schemaVersion")) is not int or data["schemaVersion"] != 1
            or data.get("id") != "lissom.wellness.translation-reviews.v1"
            or not isinstance(data.get("scope"), str) or not data["scope"]
            or not isinstance(data.get("reviews"), list) or not data["reviews"]):
        raise ValueError(f"Invalid wellness translation review artifact: {path}")
    reviews: set[tuple[str, str, str, str, str]] = set()
    fields = ("locale", "sourceEnglishSha256", "translationSha256", "leaf", "matchedWord")
    for row in data["reviews"]:
        if (not isinstance(row, dict) or set(row) != set(fields)
                or any(not isinstance(row.get(field), str) for field in fields)
                or row["locale"] not in _CATALOG_LOCALES or row["leaf"] != "text"
                or not row["matchedWord"] or row["matchedWord"] != row["matchedWord"].strip()
                or any(re.fullmatch(r"[0-9a-f]{64}", row[field]) is None
                       for field in ("sourceEnglishSha256", "translationSha256"))):
            raise ValueError(f"Invalid wellness translation review record: {path}")
        key = tuple(row[field] for field in fields)
        if key in reviews:
            raise ValueError(f"Duplicate wellness translation review record: {path}")
        reviews.add(key)
    return frozenset(reviews)


_REVIEWED_TRANSLATION_WORDS = _load_translation_reviews(
    Path(__file__).with_name("wellness_translation_reviews.v1.json")
)


def _reviewed_word(where: str, text: str, word: str, *, catalog_alias: bool = False,
                   catalog_source: str | None = None) -> bool:
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    if word.lower() in _REVIEWED_COPY.get((where, digest), ()):
        return True
    # scan_file supplies this permission only for an approved catalog identity
    # at its exact app path. Index changes do not change the English sentence;
    # a changed sentence/hash or a different matched word is never authorized.
    location = _CATALOG_REVIEW_LOCATION.fullmatch(where) if catalog_alias else None
    if location is None:
        return False
    if any(sha == digest and word.lower() in words
           for (_, sha), words in _REVIEWED_COPY.items()):
        return True
    # Foreign-language cognates can match an English pattern. Only the exact
    # reviewed locale/source/value/leaf/word tuple may pass: no translated
    # negation grammar, language exemption or medical acceptance is implied.
    return isinstance(catalog_source, str) and (
        location["locale"], hashlib.sha256(catalog_source.encode("utf-8")).hexdigest(),
        digest, location["leaf"], word,
    ) in _REVIEWED_TRANSLATION_WORDS


def _json_location(path: Path) -> str:
    """Keep legacy reviewed labels only for the exact shipped course paths."""
    try:
        relative = path.resolve().relative_to(ROOT.resolve()).as_posix()
    except ValueError:
        return str(path.resolve())
    return path.name if relative in _REVIEWED_COURSE_PATHS else relative


def _approved_catalog(path: Path, data: object) -> bool:
    if not isinstance(data, dict):
        return False
    locale = data.get("locale")
    if not isinstance(locale, str) or locale not in _CATALOG_LOCALES:
        return False
    return (
        _json_location(path) == f"config/l10n/{locale}.json"
        and set(data) == {"schemaVersion", "id", "locale", "messages"}
        and type(data.get("schemaVersion")) is int
        and data["schemaVersion"] == 1
        and data.get("id") == f"lissom.l10n.{locale}"
        and isinstance(data.get("messages"), dict)
    )

#: JSON içinde kullanıcıya GÖRÜNEN alanlar. Diğer alanlar (açıklama, kaynak,
#: not) iç dokümandır ve taranmaz — yoksa her literatür atıfı false-positive olur.
#:
#: ⚠️ Yeni bir config şeması eklerken BU LİSTEYİ GÜNCELLE. Liste eksikse dosya
#: taranır ama içinden hiç metin çıkarılmaz ve süzgeç "temiz" der — sessiz bir
#: boşluk. `MIN_STRINGS_PER_FILE` koruması tam bunun için var.
USER_FACING_KEYS = {
    # genel
    "instruction", "message", "text", "label", "title", "name",
    "criteria", "hint", "cta", "body",
    # içerik paketleri (egzersiz havuzu, yoga paketleri)
    "nameEn", "regression", "progression", "safetyNote", "cameraNote",
    "raw",           # dose.raw — kullanıcıya gösterilen doz metni
    "breathCue", "description_en",
    # bilgi mimarisi (kütüphane sayfaları, dürüstlük kutuları, "neden yok" sayfası)
    "intro", "topic", "reason", "scope", "measured", "notMeasured",
    # ⚠️ ÜÇÜ DE 2026-08-07'de EKLENDİ ve üçü de o güne kadar HİÇ TARANMAMIŞTI
    # (L-229). `userText` doğrudan sonuç ekranına gidiyor ve içinde iki tane
    # `yet` vardı; `setupNote`/`framingRule` kullanıcıya kamerayı nasıl
    # kuracağını anlatıyor. Listede olmayan alan "temiz" değil, BAKILMAMIŞTIR
    # — dosyanın kendisi tarandığı için sayaç da uyarmıyordu.
    "userText", "setupNote", "framingRule",
    # `claim` — honestyBox.measured artık nesne (L-230). Eklenmezse iddia
    # metinleri sessizce denetim DIŞINDA kalırdı: şemayı değiştirip bu listeyi
    # güncellememek, dosyanın kendi uyarısının canlı örneği.
    "claim",
    # Guided-course copy is bilingual and includes step arrays.
    "outcome", "objective", "steps", "practice", "selfCheck",
    "adaptation", "stopSignal", "answerKey", "supports", "doesNotSupport",
}

#: Kullanıcıya görünen metin TAŞIMASI BEKLENEN dizinler. Buradaki bir dosyadan
#: hiç metin çıkmazsa bu "temiz" değil "hiç bakılmamış" demektir ve süzgeç
#: kırılır. Egzersiz havuzu dosyasında tam olarak bu yaşandı: 72 hareketlik
#: dosya tarandı, 0 metin çıkarıldı, süzgeç yeşil yandı.
#:
#: `config/metrics/` kasıtlı olarak DIŞARIDA: metrik tanımları teknik config'tir,
#: içindeki `description` alanları geliştiriciye yazılmıştır, kullanıcıya değil.
CONTENT_DIRS = ("config/content", "config/courses", "config/tests", "config/copy", "config/ia", "l10n")
MIN_STRINGS_PER_FILE = 1

#: Kullanıcı metni TAŞIYAN Dart kaynağı.
#:
#: ⚠️ **BU SÜZGEÇ İKİ YIL BOYUNCA DART'A HİÇ BAKMADI (L-221).** Yalnız
#: `.json`/`.arb` taranıyordu; oysa yüzeyin İngilizce kopyasının BÜYÜK KISMI
#: Dart'ta yaşıyor (ekran metinleri, engel gerekçeleri, sonuç sınıfı
#: cümleleri). "Yeni Dart kopyası elle de kontrol edildi" diye kayda geçen
#: şey tam olarak bunun itirafıydı — elle kontrol bir kapı değildir.
#:
#: `lib/` dört sekmenin kopyasını, `packages/lissom_engine/lib/` ise engel
#: gerekçelerini ve sonuç metinlerini taşıyor. `test/` KASITLI dışarıda:
#: testler yasaklı kelimeyi ARAMAK zorunda (copy_gate.dart'ın kendisi yasaklı
#: kalıpların listesidir) ve onu taramak süzgeci kendi kapısına takardı.
DART_DIRS = ("lib", "packages/lissom_engine/lib")

# İŞLETİM SİSTEMİ KATMANI (L-273). İzin metinleri kullanıcıya **iOS'un kendi
# diyaloğunda** gösterilir — uygulamanın dışına çıkan ilk cümledir. Diğer
# kullanıcı metinleri gibi vaat/wellness yasaklarına tabidir, ama linter bu
# katmana HİÇ bakmıyordu (`os_layer_test` kapısı bunu yakaladı).
OS_FILES = ("ios/Runner/Info.plist",)

#: Dart yorumları — taramadan ÖNCE silinir. Türkçe geliştirici yorumları
#: kullanıcı metni değildir ve İngilizce kalıp aramak orada anlamsız
#: false-positive üretir (ör. bu dosyadaki "diagnose" örnekleri).
_DART_COMMENT = re.compile(r"//[^\n]*|/\*.*?\*/", re.DOTALL)

#: Dart string sabitleri.
#:
#: ⚠️ **BİTİŞİK LİTERALLER BİRLEŞTİRİLİR (L-245).** Dart'ta `'a' 'b'` tek bir
#: dizedir ve bu dosya onları AYRI tarıyordu. Bedeli ölçüldü: koşullu-vaat
#: kapısı eklenince `'…When that study is ' 'run, the number will appear
#: here.'` cümlesinde **"When" bir parçada, "will" ötekindeydi** — kapı
#: cümleyi değil PARÇAYI gördü ve meşru bir biçimi ihlal sandı.
#:
#: `roseDeepHover`ı `rose` sanan alt-dize hatasıyla aynı sınıf: **doğru şeyi
#: yanlış BİRİMDE ölçmek.** Ölçüm birimi cümledir, parça değil.
_DART_STRING = re.compile(r"'((?:[^'\\\n]|\\.)*)'|\"((?:[^\"\\\n]|\\.)*)\"")

#: Yalnız boşluk/yorum-sonrası satır başıyla ayrılmış ardışık literaller.
_ADJACENT = re.compile(r"\s+\Z")


def _walk_json(node: object, path: str = "") -> list[tuple[str, str]]:
    """JSON ağacından yalnız kullanıcıya görünen string alanları topla."""
    out: list[tuple[str, str]] = []
    if isinstance(node, dict):
        # App catalogs use arbitrary source-English keys rather than named
        # copy fields. Scan their English fallback and every displayed value,
        # including plural forms. The pattern policy remains English-only;
        # passing it does not certify the meaning of a translated sentence.
        if (not path and str(node.get("id", "")).startswith("lissom.l10n.")
                and isinstance(node.get("messages"), dict)):
            for index, (source, translation) in enumerate(node["messages"].items()):
                if isinstance(source, str):
                    out.append((f"messages[{index}].source", source))
                if isinstance(translation, str) and translation != source:
                    out.append((f"messages[{index}].text", translation))
                elif isinstance(translation, dict):
                    for category, text in translation.items():
                        if isinstance(text, str):
                            out.append((f"messages[{index}].{category}", text))
            return out
        # English-only policy: scan the displayed English translation, while
        # the course parser separately requires both languages. Internal
        # media briefs remain outside user-facing copy.
        field = path.rsplit(".", 1)[-1].split("[", 1)[0]
        if field in USER_FACING_KEYS and isinstance(node.get("en"), str) and "tr" in node:
            return [(f"{path}.en", node["en"])]
        for k, v in node.items():
            child = f"{path}.{k}" if path else k
            if isinstance(v, str):
                if k in USER_FACING_KEYS:
                    out.append((child, v))
            else:
                out.extend(_walk_json(v, child))
    elif isinstance(node, list):
        for i, v in enumerate(node):
            child = f"{path}[{i}]"
            if isinstance(v, str):
                # Serbest string dizileri (levels gibi) kullanıcıya görünebilir.
                if path.rsplit(".", 1)[-1] in USER_FACING_KEYS | {"levels"}:
                    out.append((child, v))
            else:
                out.extend(_walk_json(v, child))
    return out


def _is_negated(text: str, start: int) -> bool:
    # A disclaimer in a previous sentence/clause cannot negate a new claim.
    prefix = re.split(r"[.!?;\n]", text[:start])[-1]
    return bool(NEGATION.search(prefix))


# Safety exceptions prove the entire local clause and name only the
# occurrence they authorize. A noun phrase such as "symptom-free retest"
# alone proves nothing: active/passive outcomes cannot reuse its exception.
# No open-ended efficacy-verb dictionary, file exemption or digest is added.
# Other matched words, including a second symptom mention, remain scanned.
_CONTEXT_GRAMMARS = [
    # Observed, symptom-free learning conditions followed by an instruction.
    r"If (?:the )?(?P<word>symptom)-free mistake is pulling with the hand, release it, reduce the range and retry once with hands resting",
    r"If you notice a (?P<word>symptom)-free shoulder shrug, lower to neutral, keep required support, choose a lower reach and retry once",
    r"If (?P<word>symptom)-free, (?:rehearse once|start neutral with a shorter step and retry once)",
    r"If (?P<word>symptom)-free and you notice (?:pulling feet close just to [“\"]look better,[”\"] leave, set feet slightly farther away and retest only a smaller entry/exit once|a habit of reaching for toes, leave, choose a closer hand location and make one brief rehearsal in a more upright/smaller form|forcing visual symmetry, leave, choose less range and retest one brief entry/centre return)",
    r"If even a (?P<word>symptom)-free rehearsal is not comfortable, omit today's floor route",
    r"If a (?P<word>symptom)-free written plan omitted neutral, add it before movement and verbally recheck the two entry/exit orders",
    r"If physical rehearsal exposes a (?P<word>symptom)-free coordination error, use v08’s single simplified retest",
    r"If that link is familiar and (?P<word>symptom)-free, include just one selected optional component",
    r"If a rear-foot return needs a hop, should you lengthen the stance or shorten it before a (?P<word>symptom)-free retest",
    # Bounded error/retest instructions, not symptom-free outcome subjects.
    r"A (?P<word>symptom)-free (?:trunk-rocking error: place both feet down, rest, choose a much smaller lift and retry once|rushed return: stop upright, shorten the hinge and rehearse one slower supported return|error that disappears is a reported coordination change, not a clinical finding)",
    r"For a (?P<word>symptom)-free (?:toe-lift error where both feet leave the floor: rest, recheck chair fit, keep one heel and opposite sole grounded, reduce the lift and retry once|overreach, return by the familiar small support-preserving action, reset upright and select less hip displacement for one smaller attempt|forgotten-order example only, reset upright and simplify to the stationary hinge already learned)",
    r"For (?P<word>symptom)-free distraction return to ordinary breathing",
    r"Only for a (?P<word>symptom)-free setup/attention error: leave the pose",
    r"Only a (?P<word>symptom)-free setup/coordination error may receive one smaller retest",
    r"Use one small correction/retest cycle for a (?P<word>symptom)-free coordination error",
    # Explicit stop/referral predicates; only the named warning token passes.
    r"(?:stop|stopping) for (?P<word>symptoms)",
    r"Pinching or any stop (?P<word>symptom) ends the action without retest",
    r"Slipping contact or (?P<word>symptoms) end the attempt",
    r"(?P<word>Symptoms) mean stop, not a smaller retry",
    r"(?P<word>Symptoms) are not a correction drill",
    r"Repeated (?P<word>symptoms) are not invitations to repeat with smaller range",
    r"Any knee/hip/back (?P<word>symptoms) mean no retest",
    r"For (?P<word>symptoms), uncertain support or forced breath, finish movement and use the familiar supported rest",
    r"Omit the lesson for (?P<word>symptoms) or difficulty controlling the exit",
    r"(?:persistent or recurrent|recurrent/persistent|persistent/recurrent) (?P<word>symptoms) (?:need|require) individual advice(?: before (?:resuming|restarting))?",
    r"Seek appropriate health assistance if (?P<word>symptoms) persist, worsen or concern you",
    # Recall/distinction tasks bind each of their two warning mentions.
    r"Correction is different from a (?P<word>symptom)",
    r"Distinguish a (?P<word>symptom)-free setup correction from a (?P<word2>symptom) that ends attempts",
    r"In neutral distinguish [“\"]time ended,[”\"] [“\"]attention wandered,[”\"] [“\"]setup error[”\"] and [“\"](?P<word>symptom)",
    r"Write distinct branches for [“\"]prop slips[”\"] and [“\"](?P<word>symptoms) occur",
    r"In a new case they distinguish stopping for (?P<word>symptoms) from an ordinary setup error",
    r"Name required support at each stage, optional actions omitted, a breath-mismatch response and a (?P<word>symptom)-stop response",
    r"Before opening the saved plan, write the setup, chosen link, breath-mismatch response, one (?P<word>symptom)-free correction and one (?P<word2>symptom)-stop exit from memory",
    r"In a later separate session, before opening the plan, recall the setup, return points and two different responses: a (?P<word>symptom)-free contact error and a stop (?P<word2>symptom)",
    r"In a later separate session, before opening the page explain your adaptation of Yin waiting, two selected shapes, each support/entry/neutral/exit, a reason to leave before time and the different responses to (?P<word>symptoms) versus (?P<word2>symptom)-free setup errors",
    # Explicit denials and learner planning, with no trailing asserted claim.
    r"(?:This is |Duration is your choice, )not a (?P<word>prescribed) physical dose",
    r"No tissue change, organ/meridian effect, (?P<word>treatment), pain relief or health outcome is promised",
    r"No learner trial or instructor demonstration validates this curriculum (?P<word>yet)",
    r"Name where a pause (?P<word>will) occur: upright or supported sitting",
]
_CONTEXT_PATTERNS = [re.compile(pat, re.IGNORECASE) for pat in _CONTEXT_GRAMMARS]
_CLAUSE_BREAK = re.compile(r"[.!?;\n]")
_CLAUSE_TRIM = ' \t\r“”"'


def _clause_at(text: str, start: int) -> tuple[str, int]:
    left = 0
    right = len(text)
    for boundary in _CLAUSE_BREAK.finditer(text):
        if boundary.end() <= start:
            left = boundary.end()
        elif boundary.start() >= start:
            right = boundary.start()
            break
    raw = text[left:right]
    leading = len(raw) - len(raw.lstrip(_CLAUSE_TRIM))
    return raw.strip(_CLAUSE_TRIM), left + leading


def _contextual_use(text: str, match: re.Match[str]) -> bool:
    clause, offset = _clause_at(text, match.start())
    for pattern in _CONTEXT_PATTERNS:
        proof = pattern.fullmatch(clause)
        if proof is None:
            continue
        for group in proof.groupdict():
            begin, end = proof.span(group)
            if begin + offset == match.start() and end + offset == match.end():
                return True
    return False


def scan_text(where: str, text: str, *, catalog_alias: bool = False,
              catalog_source: str | None = None) -> list[str]:
    problems: list[str] = []
    for pat in HARD:
        for m in re.finditer(pat, text, re.IGNORECASE):
            if (_reviewed_word(where, text, m.group(0), catalog_alias=catalog_alias,
                               catalog_source=catalog_source)
                    or _contextual_use(text, m)):
                continue
            problems.append(f"{where}: HARD  «{m.group(0)}»  — {text[:90]}…")
    for pat in PROMISE:
        for m in re.finditer(pat, text, re.IGNORECASE):
            if _contextual_use(text, m):
                continue
            problems.append(
                f"{where}: VAAT  «{m.group(0)}»  — M-F-186: bilmediğimiz bir "
                f"tarihi ima eder  — {text[:90]}…"
            )
    for pat in CONDITIONAL_PROMISE:
        for m in re.finditer(pat, text, re.IGNORECASE):
            # ÜÇÜNCÜ SINIF: `will not` / `won't` bir vaat DEĞİL, vaadin
            # REDDİ — "we will not estimate a number we can't take" bu ürünün
            # en dürüst cümlelerinden biri. Kapı onu ihlal sayarsa, doğru
            # davranışı cezalandırır.
            if (_contextual_use(text, m) or
                    re.match(r"will\s+not\b", text[m.start():], re.IGNORECASE)):
                continue
            clause_prefix = re.split(r"[.!?;\n]", text[:m.start()])[-1]
            if not CONDITION.search(clause_prefix):
                problems.append(
                    f"{where}: VAAT  «{m.group(0)}» KOŞULSUZ  — adı olan bir "
                    f"koşula bağlanmamış gelecek zaman  — {text[:90]}…")
    for pat in SOFT:
        for m in re.finditer(pat, text, re.IGNORECASE):
            if (_reviewed_word(where, text, m.group(0), catalog_alias=catalog_alias,
                               catalog_source=catalog_source)
                    or _contextual_use(text, m)):
                continue
            if not _is_negated(text, m.start()):
                problems.append(
                    f"{where}: SOFT  «{m.group(0)}» olumsuzlanmamış  — {text[:90]}…"
                )
    return problems


def scan_file(path: Path) -> tuple[list[str], int]:
    """Dosyayı tara. Dönüş: (sorunlar, çıkarılan metin sayısı).

    Metin sayısı, taramanın gerçekten yapılıp yapılmadığını gösterir —
    çağıran taraf sıfır görürse bunu geçiş saymamalı.
    """
    if path.name in EXEMPT_FILES:
        return [], -1  # -1 = kasıtlı atlandı, sayım anlamsız
    problems: list[str] = []
    scanned = 0
    if path.suffix == ".json":
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            return [f"{path.name}: JSON okunamadı — {exc}"], 0
        location = _json_location(path)
        catalog_alias = _approved_catalog(path, data)
        catalog_sources = {
            f"messages[{index}]": source for index, source in enumerate(data["messages"])
        } if catalog_alias else {}
        for key, value in _walk_json(data):
            scanned += 1
            problems += scan_text(
                f"{location} :: {key}", value, catalog_alias=catalog_alias,
                catalog_source=catalog_sources.get(key.rsplit(".", 1)[0]),
            )
    elif path.suffix == ".plist":
        # OS katmanı (L-273): izin metinleri kullanıcıya iOS'un KENDİ
        # diyaloğunda gösterilir. Yalnız `*UsageDescription` taranır.
        for key, value in strings_from_plist(path.read_text(encoding="utf-8")):
            scanned += 1
            problems += scan_text(f"{path.name} :: {key}", value)
    elif path.suffix == ".dart":
        source = _DART_COMMENT.sub(" ", path.read_text(encoding="utf-8"))
        # Bitişik literalleri BİRLEŞTİR: aralarında yalnız boşluk varsa Dart
        # onları tek dize sayar, süzgeç de saymalı.
        merged: list[tuple[int, str]] = []
        prev_end = -1
        for m in _DART_STRING.finditer(source):
            literal = m.group(1) if m.group(1) is not None else m.group(2)
            if literal is None:
                continue
            line = source.count("\n", 0, m.start()) + 1
            gap = source[prev_end:m.start()] if prev_end >= 0 else None
            if merged and gap is not None and gap.strip() == "":
                merged[-1] = (merged[-1][0], merged[-1][1] + literal)
            else:
                merged.append((line, literal))
            prev_end = m.end()
        for line, literal in merged:
            if not literal.strip():
                continue
            scanned += 1
            problems += scan_text(f"{path.name}:{line}", literal)
    elif path.suffix in {".arb", ".md"}:
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.strip():
                scanned += 1
            problems += scan_text(f"{path.name}:{i}", line)
    return problems, scanned


def strings_from_plist(text: str) -> list[tuple[str, str]]:
    """`*UsageDescription` anahtarlarının metinleri — **kullanıcı yüzü.**

    Diğer plist anahtarları makine değeridir (bundle id, sürüm, yönelim) ve
    taranmaz: kapıyı geniş yazmak, ölçmediğini ölçüyor göstermek olurdu.
    """
    out: list[tuple[str, str]] = []
    for m in re.finditer(
        r"<key>(\w*UsageDescription)</key>\s*<string>([^<]*)</string>", text
    ):
        out.append((m.group(1), m.group(2)))
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--path", default=str(ROOT / "config"))
    args = ap.parse_args()

    target = Path(args.path)
    files = (
        sorted(p for p in target.rglob("*") if p.suffix in {".json", ".arb"})
        if target.is_dir()
        else [target]
    )

    # Yol ELLE verilmediyse Dart kaynağı da taranır. Elle verildiyse
    # KARIŞTIRILMAZ: `--path X` "yalnız X'e bak" demektir.
    dart_files: list[Path] = []
    if args.path == str(ROOT / "config"):
        for d in DART_DIRS:
            dart_files += sorted((ROOT / d).rglob("*.dart"))
        # Üretilen/geçici Dart'ı dışarıda tut — kullanıcı metni taşımaz ve
        # taranması "temiz" sayımını şişirir.
        dart_files = [
            p for p in dart_files if ".dart_tool" not in p.parts and "build" not in p.parts
        ]
        files += dart_files
        # OS katmanı: yalnız İZİN metinleri (diğer plist anahtarları makine
        # değeri; hepsini taramak gürültü olurdu).
        for rel in OS_FILES:
            q = ROOT / rel
            if q.exists():
                files.append(q)

    all_problems: list[str] = []
    silent: list[str] = []          # tarandı ama içinden metin çıkmadı
    total_strings = 0
    for f in files:
        probs, n = scan_file(f)
        all_problems += probs
        if n >= 0:
            total_strings += n
            rel = str(f.relative_to(ROOT)) if ROOT in f.parents else str(f)
            expects_text = any(d in rel.replace("\\", "/") for d in CONTENT_DIRS)
            if expects_text and n < MIN_STRINGS_PER_FILE:
                silent.append(rel)

    print(f"Wellness dil süzgeci — {len(files)} dosya · {total_strings} metin tarandı")
    if dart_files:
        print(f"  ({len(dart_files)} Dart dosyası dahil — yorumlar hariç, "
              "yalnız string sabitleri)")
    print(f"Muaf: {', '.join(sorted(EXEMPT_FILES))}\n")

    # Dart dosyaları tarandı ama HİÇ string çıkmadıysa, çıkarıcı bozuktur ve
    # süzgeç Dart tarafına hiç bakmamış olur — yeşil yanan boş tarama (L-011
    # dersinin denetim tarafındaki hâli).
    if dart_files and not any(scan_file(p)[1] > 0 for p in dart_files[:20]):
        print("⚠️  Dart dosyalarından hiç string çıkarılamadı — çıkarıcı BOZUK.")
        print("    Bu bir GEÇİŞ DEĞİL.")
        return 4

    # Dosya okundu ama içinden hiç metin çıkarılmadıysa bu bir GEÇİŞ DEĞİL.
    # Şema alan adları USER_FACING_KEYS'te yoksa tam olarak bu olur ve süzgeç
    # hiçbir şeye bakmadan yeşil yanar.
    if silent:
        print(f"⚠️  {len(silent)} dosyadan hiç metin çıkarılamadı — tarama YAPILMADI:")
        for s in silent:
            print(f"    {s}")
        print("    Şemanın kullanıcıya görünen alan adları USER_FACING_KEYS'te")
        print("    olmayabilir. Bu bir geçiş değildir.")
        return 3

    # Hiç dosya taranmadıysa "temiz" DEME. Bulmayan bir denetim ile bozuk bir
    # denetim dışarıdan aynı görünür; CI'da yeşil yanan boş tarama, koruma
    # olduğu sanılan bir boşluktur (L-011 dersinin denetim tarafındaki hâli).
    if not files:
        print(f"⚠️  Taranacak dosya bulunamadı: {target}")
        print(f"    Beklenen uzantılar: .json · .arb")
        print("    Bu bir GEÇİŞ DEĞİL — yol yanlış olabilir.")
        return 2

    if not all_problems:
        print("✅ İhlal yok.")
        return 0

    print(f"❌ {len(all_problems)} olası ihlal:\n")
    for p in all_problems:
        print(f"  {p}")
    print(
        "\nGüvenli yeniden yazımlar: config/copy/disclaimers.en.json → safeAlternatives"
        "\nBağlamsal false-positive ise: USER_FACING_KEYS / EXEMPT_FILES gözden geçir."
    )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
