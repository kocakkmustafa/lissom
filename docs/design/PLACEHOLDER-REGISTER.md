# Placeholder Register

**ÜRETİLİR — elle düzenlenmez.** Kaynak: `tools/gen_placeholder_register.py`, koddaki `// PLACEHOLDER(kategori): ... — unblocked by: ...` işaretlerinden.

Toplam: **1**

## asset (1)

- `lib/app/live_capture_screen.dart:410` — kamera akışının canlı görüntüsü (Texture tabanlı önizleme)
  - unblocked by: motion_camera'nın önizleme texture'ı sunması (registrar.textures); pinli f13bdc9'da YOK, çekirdek turu kalem #5
  - user-surface: liveCapture.noPreview

