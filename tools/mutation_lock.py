#!/usr/bin/env python3
"""MUTASYON HARNESS ÇEKİRDEĞİ — Ostinato MUT-A aktarımı (A2, 2026-08-11).

Ölçüm (`docs/A1-A5-AILE-DENETIMI-2026-08-11.md`, A2): Lissom'daki sabotaj
doğrulamalarının çoğu KALICI/tekrar-koşulabilir değildi — ya test dosyasına
gömülü tek seferlik kod (`pin_equality_test.dart`, iyi ama motorlu bir
harness değil) ya da yalnız YORUMDA anlatılan bir-kereliğine koşumlar
(`honesty_presence_test.dart:6`). Hiçbiri Ostinato'nun MUT-A üçlüsünü
taşımıyordu: KİLİT (canlı koşum varken ikincisi başlamaz) · KÖKEN
(geri-yükleme HASH ile kanıtlanır, git ile DEĞİL — O-084 dersi) ·
DOĞRULAMA (geri-yükleme "denendi" değil "TUTTU" mu, ölçülür).

## Bu dosyanın taşıdığı — ve TAŞIMADIĞI (isimle)

Ostinato'nun gerçek `gate_mutation_test.py`'si (`ventures/ostinato/app/
tools/`, 400 satır) OKUNDU ve iki katmana ayrıldı:

**Taşınan (bu dosya):** kilit + hash-köken + çökmeye-dayanıklı geri-alma +
doğrulama — dosya-listesi/gate-listesi PARAMETRE, Lissom'un hiçbir kavramına
(metric/test/battery) bağlı DEĞİL. `MutationRun` bunu genel bir bağlam
yöneticisi olarak sarar; `tools/gate_mutation_test.py` gibi bir çağıran
Lissom'a özgü mutasyonları (`m_*` fonksiyonları, hangi kapının hangi iki
kaynağı karşılaştırdığı) BU dosyanın üstüne yazar.

**TAŞINMAYAN (bilerek):** Ostinato'nun kendi `RULESET`/`REFERENCE`/`LIBRARY`
yolları ve on üç `m_*` mutasyon fonksiyonu — hepsi disiplin/ders/
observationCues şemasına kenetli, Lissom'un hiçbir config dosyasında
karşılığı yok. Ve daha önemlisi: **Lissom'un hangi kapılarının "ÇELİŞKİ
kapısı" (iki kaynağı karşılaştıran, MUT-A'nın asıl hedefi) olduğu hiç
ENVANTERLENMEDİ** — bu, kendi başına bir denetim işi (A4'ün kapsam ölçümüyle
aynı büyüklükte) ve icat edilmeden BURADA bırakıldı. Bu dosya, o envanter
çıktığında üstüne yazılacak ÇEKİRDEĞİ hazırlar; envanterin kendisi değildir.

## Kullanım

    from tools.mutation_lock import MutationRun

    TOUCHED = ["config/tests/lissom-assessment.v1.json"]
    with MutationRun(TOUCHED) as run:
        if run.baseline_red:
            sys.exit(1)  # taban zaten kırmızıysa mutasyon ölçümü anlamsız
        # ... mutasyon uygula, run_gates() çağır, run.restore_for_next() ...
"""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import sys
from pathlib import Path
from typing import Callable, Sequence

ROOT = Path(__file__).resolve().parent.parent
BACKUP_DIR = ROOT / ".mutation-lock-backup"
SENTINEL = BACKUP_DIR / "IN-FLIGHT"


def _alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except (ProcessLookupError, ValueError):
        return False
    except PermissionError:
        return True
    return True


def digests(files: Sequence[str | Path]) -> dict[str, str]:
    """Dosya özetleri — KÖKEN KANITI. HASH, git DEĞİL (O-084 dersi:

    git'i köken oracle'ı yapmak, "doğrulayabilmek için önce commit'le"yi
    dayatır — kapının amacı commit'ten ÖNCE doğrulamaktır, sırayı tersine
    çevirmemeli. Hash dosyanın commit'li olup olmadığından bağımsız
    kanıtlanabilir.
    """
    return {str(f): hashlib.sha256(Path(f).read_bytes()).hexdigest() for f in files}


class LockHeld(RuntimeError):
    """Başka bir MutationRun hâlâ canlı — bu koşum BAŞLAMADI."""


class RestoreFailed(RuntimeError):
    """Geri-yükleme DENENDİ ama hash'ler UYUŞMADI — repo BOZUK, elle bakılmalı."""


class MutationRun:
    """Kilit + hash-köken + çökmeye-dayanıklı geri-alma + doğrulama.

    Sözleşme: `touched` içindeki dosyalar `with` bloğu boyunca serbestçe
    mutasyona uğratılabilir; blok NASIL biterse bitsin (istisna dahil)
    `__exit__` orijinal içeriği geri yükler VE hash ile TUTTUĞUNU kanıtlar.
    Süreç ÖLDÜRÜLÜRSE (kill -9, `finally` koşmaz) sonraki `MutationRun`
    nöbetçi dosyayı görüp GÜRÜLTÜYLE onarır — sessizce devam etmez.
    """

    def __init__(self, touched: Sequence[str | Path]):
        self.touched = [str(f) for f in touched]
        self._before: dict[str, str] | None = None

    def __enter__(self) -> "MutationRun":
        self._heal_if_needed()
        BACKUP_DIR.mkdir(exist_ok=True)
        for f in self.touched:
            shutil.copy(f, BACKUP_DIR / Path(f).name)
        self._before = digests(self.touched)
        (BACKUP_DIR / "DIGESTS.json").write_text(
            json.dumps(self._before), encoding="utf-8")
        SENTINEL.write_text(f"mutations in flight {os.getpid()}\n", encoding="utf-8")
        return self

    def restore_for_next(self) -> None:
        """Bir mutasyon turundan SONRAKİNE geçerken orijinali geri koyar —
        yedeği TÜKETMEZ (birden çok mutasyon aynı temiz tabandan başlar)."""
        for f in self.touched:
            shutil.copy(BACKUP_DIR / Path(f).name, f)

    def __exit__(self, exc_type, exc, tb) -> None:
        assert self._before is not None, "__enter__ hiç koşmadı"
        self.restore_for_next()
        after = digests(self.touched)
        if after != self._before:
            SENTINEL.unlink(missing_ok=True)
            raise RestoreFailed(
                "geri-yükleme TUTMADI (özetler uyuşmuyor) — repo BOZUK, "
                f"elle bakın: {BACKUP_DIR}")
        SENTINEL.unlink(missing_ok=True)
        shutil.rmtree(BACKUP_DIR, ignore_errors=True)

    @staticmethod
    def _heal_if_needed() -> None:
        if not SENTINEL.exists():
            return
        raw = SENTINEL.read_text(encoding="utf-8").strip().split()
        pid = int(raw[-1]) if raw and raw[-1].isdigit() else -1
        if pid > 0 and pid != os.getpid() and _alive(pid):
            raise LockHeld(
                f"MUTASYON KOŞUMU ZATEN SÜRÜYOR (pid {pid}) — ikinci koşum "
                f"BAŞLAMAZ. Eşzamanlı iki koşum birbirinin yedeğini bozar ve "
                f"mutasyon KALICI kalır (Ostinato O-079 dersi).")
        # Önceki koşum ortada ölmüş — yedekten onar, hash ile doğrula.
        dig = BACKUP_DIR / "DIGESTS.json"
        if not dig.exists():
            raise RestoreFailed(
                "önceki koşum ortada ölmüş ve yedek DIGESTS.json yok — "
                "onarım imkânsız, elle bakın")
        want = json.loads(dig.read_text(encoding="utf-8"))
        for f in want:
            shutil.copy(BACKUP_DIR / Path(f).name, f)
        if digests(want.keys()) != want:
            raise RestoreFailed(
                "önceki koşumdan onarım DENENDİ ama hash UYUŞMADI — repo "
                "BOZUK, elle bakın")
        SENTINEL.unlink(missing_ok=True)


def _selftest() -> int:
    """Öz-test — kilit ve doğrulama gerçekten ötüyor mu (sabotajla)."""
    probe = ROOT / ".mutation-lock-selftest-probe.txt"
    probe.write_text("orijinal\n", encoding="utf-8")
    try:
        # 1) Normal döngü: mutasyon uygulanır, geri-yükleme TUTAR.
        with MutationRun([probe]):
            probe.write_text("mutasyona uğratıldı\n", encoding="utf-8")
        assert probe.read_text() == "orijinal\n", "geri-yükleme tutmadı"

        # 2) KİLİT sabotajı: sentinel'i BAŞKA canlı bir pid ile elle bırak —
        #    ikinci koşum BAŞLAMAMALI (LockHeld fırlatmalı). Kendi pid'imizi
        #    YAZMAK yanlış olurdu: `_heal_if_needed` `pid != os.getpid()`
        #    şartını arıyor, kendi pid'imiz her zaman eşleşir. Ebeveyn süreç
        #    hem CANLI hem BİZDEN FARKLI — gerçek "başka canlı koşum"u
        #    doğru taklit eder.
        BACKUP_DIR.mkdir(exist_ok=True)
        shutil.copy(probe, BACKUP_DIR / probe.name)
        (BACKUP_DIR / "DIGESTS.json").write_text(
            json.dumps(digests([probe])), encoding="utf-8")
        SENTINEL.write_text(f"mutations in flight {os.getppid()}\n", encoding="utf-8")
        try:
            with MutationRun([probe]):
                pass
            print("❌ ÖZ-TEST BAŞARISIZ: canlı kilit varken ikinci koşum "
                  "BAŞLADI — LockHeld fırlatmalıydı")
            return 2
        except LockHeld:
            pass  # beklenen
        SENTINEL.unlink(missing_ok=True)
        shutil.rmtree(BACKUP_DIR, ignore_errors=True)

        # 3) DOĞRULAMA sabotajı: yedek dosyasını BOZ — restore_for_next
        #    SONRASI hash uyuşmamalı ve __exit__ RestoreFailed fırlatmalı.
        try:
            with MutationRun([probe]) as run:
                probe.write_text("mutasyona uğratıldı\n", encoding="utf-8")
                # Yedeği ELİMLE zehirle — gerçek dünyada bu, çökme sırasında
                # yarım kalan bir kopyalamayı taklit eder.
                (BACKUP_DIR / probe.name).write_text("ZEHİRLİ\n", encoding="utf-8")
            print("❌ ÖZ-TEST BAŞARISIZ: zehirli yedek SESSİZCE kabul edildi — "
                  "RestoreFailed fırlatmalıydı")
            return 2
        except RestoreFailed:
            pass  # beklenen
        finally:
            shutil.rmtree(BACKUP_DIR, ignore_errors=True)
            SENTINEL.unlink(missing_ok=True)
    finally:
        probe.unlink(missing_ok=True)

    print("✅ kilit + köken + doğrulama üçü de sabotajla kanıtlandı.")
    return 0


def main() -> int:
    return _selftest()


if __name__ == "__main__":
    raise SystemExit(main())
