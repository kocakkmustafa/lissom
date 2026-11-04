# Lissom kamera koçluğu — veri lisans kaydı

Kural: yalnız ticari kullanıma ve model eğitimi/değerlendirmesine açık, **görüntüsü de** aynı lisansta olan veri. Lisans resmî kayıttan okunur. Bu rapor hukuki görüş değildir.

| Veri | Kayıt | Lisans (nasıl doğrulandı) | Kişi | Kullanım | Ham görüntü |
|---|---|---|---|---|---|
| YAR / YogNet | Mendeley 10.17632/k842kz6v4n.1 | CC BY 4.0 (Mendeley API, 2026-10-27, E04) | ~16 | E14 kural geliştirme + ayrılmış kişi sınaması | silindi; yalnız MediaPipe iskeleti (`data/DELETED-RAW.json`) |
| DSZ-Yoga | Zenodo 10.5281/zenodo.18297451 v1.0.0 (Damiran, NAIST) | CC BY 4.0 (Zenodo API `metadata.license.id = cc-by-4.0`, 2026-11-05) | 12 | E15 bağımsız kural sınaması | yok (yalnız hareket yakalama); RGB akademik istekle → **kullanılmaz** |
| Pose Landmarker Full | MediaPipe model kartı | Apache-2.0 | — | cihazdaki poz modeli (eğitilmedi, yalnız çalıştırılır) | — |

## Atıf (CC BY 4.0)
- "YAR/YogNet" — Mendeley Data, doi:10.17632/k842kz6v4n.1, CC BY 4.0.
- Damiran, Z. "DSZ-Yoga: A Synchronized Multimodal Dataset for Yoga Pose Recognition" — Zenodo, doi:10.5281/zenodo.18297451, CC BY 4.0.

Uygulama bu verilerden türetilmiş öğrenilmiş ağırlık **taşımaz**; kural sabitleri ders metninden yazılmıştır ve YAR ile ayarlanmıştır. Atıf uygulamanın açık kaynak/lisans sayfasında ve bu kayıtta tutulur.

## Kullanılmayanlar (gerekçe)
- Yoga-82, MPII yoga, Kaggle/Roboflow setleri: görüntüler web'den, ticari değil ya da doğrulanamıyor.
- 3DYoga90 (CC BY-NC), AIST/AIST++, QEVD, Fit3D, Human3.6M, AMASS, BEDLAM, Mixamo: ticari değil ya da eğitim yasak. AIST ve QEVD lisans istekleri kurucu kararıyla yapılmadı.
- YOLO-pose (AGPL-3.0), Sapiens (CC BY-NC), SMPL tabanlılar: lisans.
- Zenodo 22714798 (çift görüş squat): Zenodo CC BY 4.0 ama README "ticari dağıtımdan önce iletişime geçin" diyor → çelişkili, kullanılmadı.

## Aday bağımsız kaynaklar (sonraki sürüm, indirilmedi)
Ayrıntı: oturum notu `lissom-bagimsiz-veri-arama-2026-11-04.md`. Kamera zinciri için: MobiPhysio (Harvard Dataverse, CC0, 58 kişi, telefon, yan görüş), Multi-View Fitness (Mendeley kgbb3yn47p, CC BY 4.0, 26 kişi), VIDIMU (Zenodo 8210563, CC BY 4.0, 54 kişi, sandalyede oturuş, ~45°). Kural katmanı için: UI-PRMD (ODC-PDDL, 10 kişi, lunge ve kollar yukarı). Hiçbiri yoga videosu değil; yan görüşlü, açık lisanslı yoga videosu bulunamadı.
