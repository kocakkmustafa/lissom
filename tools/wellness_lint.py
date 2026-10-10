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
# HARD: hiçbir bağlamda kabul edilemez — hastalık adı, regülatif iddia, tedavi
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

#: `will`i meşru kılan koşul çapaları. NEGATION'dan farklı olarak PENCERE YOK:
#: koşul cümlesi tüm cümleyi yönetir ("When that study is run, the number will
#: appear here" — arada altı kelime var). Bedeli isimli: aynı dizede alakasız
#: bir "when" de geçerse kapı susar. Dar pencere bu meşru biçimi kırardı;
#: yanlış alarmı insan eler, ama meşru biçimi kıran kapı insanı kapıdan soğutur.
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


def _reviewed_word(where: str, text: str, word: str) -> bool:
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return word.lower() in REVIEWED_HATHA_COPY.get((where, digest), ())

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
    "adaptation", "stopSignal",
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


# Context controls apply to one matched occurrence, never to a field/file.
# A symptom mention is not a diagnosis when it names a stop, a referral,
# or an explicitly symptom-free learning error. Other claims in the same
# sentence continue through every rule. Keep these grammars local: an
# unrelated safety sentence must not authorize an efficacy claim.
_CONTEXT_USES = [
    # A bounded safety condition or a non-symptomatic learning task.
    r"\bsymptom-free (?:error|toe-lift error|mistake|trunk-rocking error|coordination error|contact error|shoulder shrug|rushed return|overreach|retest|forgotten-order example|correction|distraction|rehearsal|setup(?:/(?:attention|coordination))? (?:error|correction)|written plan)\b",
    r"\bIf symptom-free\b",
    r"\bfamiliar and symptom-free\b",
    r"\b(?:stop symptom|symptom-stop)\b",
    # Stop/omit instructions, rather than interpreting the cause.
    r"\b(?:stop|stopping|omit the lesson) for symptoms\b",
    r"\b(?:pinching or any stop symptom ends the action|slipping contact or symptoms end the attempt)\b",
    r"(?:^|[.!?]\s+)(?:Symptoms mean stop|Symptoms are not a correction drill|Repeated symptoms are not invitations to repeat)\b",
    r"\b(?:any knee/hip/back symptoms mean no retest|a symptom that ends attempts)\b",
    r"(?:^|[.!?]\s+)For symptoms, uncertain support or forced breath, finish movement\b",
    # Referral language does not claim that the app manages the condition.
    r"\b(?:persistent or recurrent|recurrent/persistent|persistent/recurrent) symptoms (?:need|require) individual advice\b",
    r"\bSeek appropriate health assistance if symptoms persist, worsen or concern you\b",
    # Explicit distinction/recall tasks; no diagnostic interpretation.
    r"\bCorrection is different from a symptom\b",
    r"\band [“\"]symptom[”\"]; several may apply\b",
    r"\bWrite distinct branches for [“\"]prop slips[”\"] and [“\"]symptoms occur\.?[”\"]",
    r"\bdifferent responses to symptoms versus symptom-free setup errors\b",
    # Rejection of a physical prescription and of multiple health outcomes.
    r"\bnot a prescribed physical dose(?:[.!?]|$)",
    r"\bNo tissue change, organ/meridian effect, treatment, pain relief or health outcome is promised\b",
    # Missing evidence is a present limit; it supplies no date or capability.
    r"\bNo learner trial or instructor demonstration validates this curriculum yet\b",
    # The learner names their own pause, not a future app feature.
    r"\bName where a pause will occur: upright or supported sitting\b",
]
_CONTEXT_PATTERNS = [re.compile(pat, re.IGNORECASE) for pat in _CONTEXT_USES]

# Do not let an asserted diagnostic/efficacy outcome reuse the vocabulary
# of a safety condition (e.g. "Lissom guarantees a symptom-free retest").
_SYMPTOM_CLAIM = re.compile(
    r"\b(?:guarantee\w*|promise\w*|ensure\w*|deliver\w*|offer\w*|enjoy\w*|become\w*|make[sd]?|"
    r"predict\w*|measure\w*|resolve\w*|reliev\w*|reduc\w*|eliminat\w*|"
    r"prevent\w*|improv\w*|manage\w*|identif\w*|interpret\w*|assess\w*)"
    r"(?:[^.!?;]*?)\bsymptoms?\b", re.IGNORECASE,
)


def _contextual_use(text: str, match: re.Match[str]) -> bool:
    return any(span.start() <= match.start() and match.end() <= span.end()
               for pattern in _CONTEXT_PATTERNS
               for span in pattern.finditer(text))


def scan_text(where: str, text: str) -> list[str]:
    problems: list[str] = []
    for pat in HARD:
        for m in re.finditer(pat, text, re.IGNORECASE):
            if _reviewed_word(where, text, m.group(0)) or _contextual_use(text, m):
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
            if not CONDITION.search(text[:m.start()]):
                problems.append(
                    f"{where}: VAAT  «{m.group(0)}» KOŞULSUZ  — adı olan bir "
                    f"koşula bağlanmamış gelecek zaman  — {text[:90]}…")
    for pat in SOFT:
        for m in re.finditer(pat, text, re.IGNORECASE):
            if _reviewed_word(where, text, m.group(0)) or _contextual_use(text, m):
                continue
            if not _is_negated(text, m.start()):
                problems.append(
                    f"{where}: SOFT  «{m.group(0)}» olumsuzlanmamış  — {text[:90]}…"
                )
    for m in _SYMPTOM_CLAIM.finditer(text):
        if not _is_negated(text, m.start()):
            problems.append(f"{where}: CLAIM  «{m.group(0)}» — {text[:90]}…")
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
        for key, value in _walk_json(data):
            scanned += 1
            problems += scan_text(f"{path.name} :: {key}", value)
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
