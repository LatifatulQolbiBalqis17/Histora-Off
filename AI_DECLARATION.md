# AI_DECLARATION.md

**Mata Kuliah:** Mobile Programming — UTS
**Nama:** [Latifatul Qolbi Balqis, Khirani Nur Azizah, Nabila Fatma Sari]
**NIM:** [2413025069, 2413025039, 2453025003]
**Aplikasi:** Histora World (Flutter)

> Dokumen ini menyatakan secara transparan bagaimana alat bantu AI dipakai. Saya bertanggung jawab penuh atas kebenaran, pemahaman, dan keamanan seluruh kode di repositori ini.

## 1. Daftar Alat AI

| Alat | Dipakai untuk |
|---|---|
| Claude (Anthropic) | Perbaikan globe 3D, perbaikan warna/ikon tema, indeks foto (bendera, tempat, makanan), penulisan konten teks negara, penyusunan skrip presentasi, debugging error |
| [Alat lain, mis. GitHub Copilot / ChatGPT — hapus jika tidak dipakai] | [keperluan] |

## 2. Pembagian Peran

> Sesuaikan tabel ini dengan kenyataan. Baris yang kosong/tidak benar sebaiknya diubah sebelum dikumpulkan.

| Modul / Berkas | Peran AI | Peran saya |
|---|---|---|
| Konsep, alur navigasi, pemilihan fitur | — (murni manual) | Merancang seluruh konsep dan fitur |
| `lib/state/app_state.dart` (Provider + sqflite) | [manual / dibantu — isi] | [isi] |
| `lib/data/` (model, database, repository) | [isi] | [isi] |
| `lib/screens/world_screen.dart` — proyeksi globe, `unproject`, ray casting | Menyarankan rumus proyeksi/unprojection dan algoritma point-in-polygon | Mempelajari rumus, menguji dengan mengetuk banyak negara, menyesuaikan tampilan |
| `lib/data/flag_index.dart`, `place_index.dart`, `food_index.dart` | Menyarankan pola pencocokan nama berkas tanpa rename dan tabel pemetaan | Menyediakan foto, mencocokkan nama, memperbaiki ketidakcocokan |
| `lib/core/theme/app_theme.dart` dan perbaikan warna/ikon layar | Menyarankan warna kontras dan ikon yang tepat | Memilih yang sesuai tema, menerapkan |
| `assets/data/countries.json` (konten teks) | Menulis draf teks detail per negara (bertahap) | Memeriksa dan menyetujui isi |
| Layar lain (home, explore, favorit, kuis, pengaturan) | [isi] | [isi] |

## 3. Studi Kasus Prompting

### Kasus 1 — Globe 3D

**Prompt:**
> Perbaiki globe 3D di aplikasi Flutter ini agar persis sama seperti globe.gl di web saya (kedua proyek terlampir). Jangan ubah hal lain, hanya perbaiki warna font yang tidak terlihat dan ikon widget yang kurang tepat.

**Hasil awal AI:** Globe digambar dengan `CustomPainter` dan tekstur bumi, tetapi beberapa teks tidak terbaca di atas latar, dan sebagian kode tidak dapat dikompilasi (mis. `const Icon(...)` dengan nilai non-konstan; fungsi `accentOn/dangerOn/successOn` belum ada di tema saya).

**Penyesuaian manual:** Saya membaca pesan error di panel Problems VS Code, menghapus `const` yang salah, dan menambahkan fungsi warna yang hilang di `app_theme.dart`. Setelah itu saya menjalankan ulang dan menguji ketukan pada berbagai negara dan negara kecil.

### Kasus 2 — Foto bendera/tempat/makanan tanpa mengganti nama berkas

**Prompt:**
> Saya tidak mau mengganti nama ratusan foto (mis. `001 Afghanistan.png`, `NEGARA - TEMPAT.jpeg`). Bisakah kodenya yang disesuaikan agar foto tetap muncul?

**Hasil awal AI:** Pencocokan otomatis berdasarkan nama negara gagal untuk banyak negara karena nama berkas berbahasa Indonesia dan ada salah ketik. Gambar tidak muncul. Pada kasus lain aset tidak termuat karena subfolder belum didaftarkan di `pubspec.yaml`.

**Penyesuaian manual:** Saya membandingkan nama berkas dengan kode, lalu memakai peta eksplisit kode negara → nama berkas untuk bendera, serta normalisasi nama (huruf kecil, buang simbol) dengan `AssetManifest` untuk tempat/makanan. Saya mendaftarkan tiap subfolder aset di `pubspec.yaml` dan melakukan restart penuh (bukan hot reload). Duplikasi "Cristo Redentor" saya perbaiki dengan menyamakan nama tampilan dengan data JSON.

## 4. Pernyataan

Saya telah membaca, memahami, dan mampu menjelaskan logika kode yang dikumpulkan, termasuk bagian yang dibantu AI. Tidak ada kode yang disalin dari repositori orang lain tanpa atribusi.
