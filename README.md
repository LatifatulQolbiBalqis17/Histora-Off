# HISTORA Mobile — Flutter Offline

Aplikasi Android pembelajaran sejarah dan eksplorasi negara dunia. Proyek ini dibuat dengan Dart + Flutter, memakai identitas visual navy, cyan, dan emas dengan latar bumi, serta tidak membutuhkan koneksi internet.

## Fitur

- Splash bergaya bumi dengan tombol Mulai
- Home berlatar bumi, pencarian cepat, pintasan 7 benua, negara sorotan, statistik, riwayat
- World: globe tiga dimensi interaktif; putar dan ketuk titik negara untuk membuka detail
- Explore: satu-satunya halaman yang menampilkan daftar 195 negara, dengan pencarian nama/ibu kota, filter benua, dan urut A–Z/Z–A
- Detail negara: Overview, History, Famous Places, Culture, Traditional Food, Facts
- Favorit tersimpan di SQLite
- 5 kategori kuis, soal/opsi acak, timer 10 menit, 3 nyawa
- Hasil, predikat, pembahasan, tautan belajar, ulangi kuis, riwayat lokal
- Tema terang dan gelap
- Empty state, konfirmasi keluar kuis, dan fallback gambar

## Menjalankan di Visual Studio Code

1. Instal Flutter stable dan Android SDK.
2. Ekstrak ZIP ini, lalu buka folder `histora_flutter_offline` di VS Code.
3. Jalankan:

```bash
flutter pub get
flutter run
```

Untuk membuat APK:

```bash
flutter build apk --release
```

APK akan berada di `build/app/outputs/flutter-apk/app-release.apk`.

## Menambahkan data negara manual

Edit `assets/data/countries.json`. Pertahankan nama field sesuai contoh. Setiap negara membutuhkan:

- identitas: `id`, `name`, `localName`, `continent`, `capital`
- statistik: `population`, `area`, `language`, `currency`, `timezone`
- konten: `overview`, `history`, `places`, `culture`, `foods`, `facts`
- aset lokal: `flagImage` dan `heroImage`

Data 195 negara sudah tersedia. Gunakan ID dua huruf yang sudah ada tanpa mengubahnya. Nama benua harus salah satu dari: `Asia`, `Eropa`, `Afrika`, `Amerika Utara`, `Amerika Selatan`, `Oseania`, `Antartika`.

## Menambahkan soal manual

Edit `assets/data/questions.json`. Field wajib:

```json
{
  "id": "capital_de",
  "category": "Ibu Kota",
  "countryId": "de",
  "text": "Apa ibu kota Jerman?",
  "options": ["Berlin", "Wina", "Bern", "Praha"],
  "answer": "Berlin",
  "explanation": "Berlin adalah ibu kota Jerman.",
  "image": ""
}
```

Kategori yang dikenali: `Bendera`, `Ibu Kota`, `Deskripsi`, dan `Tempat Terkenal`. Mode `Gabungan` mengambil seluruh kategori. Nilai `answer` wajib sama persis dengan salah satu isi `options`.

## Menambahkan gambar manual

Simpan gambar terkompresi dalam format WebP:

- `assets/images/flags/` — bendera
- `assets/images/countries/` — gambar utama negara
- `assets/images/places/` — landmark
- `assets/images/foods/` — makanan

Path bendera dan gambar utama untuk 195 negara sudah disiapkan dengan pola `assets/images/flags/{id}.webp` dan `assets/images/countries/{id}.webp`. Masukkan file WebP dengan nama ID yang sama. Untuk tempat dan makanan, isi `image` pada objek terkait dengan path `assets/images/places/...` atau `assets/images/foods/...`. Jangan gunakan URL. Rekomendasi: lebar maksimum 1080 px, WebP kualitas 80. Emoji atau placeholder otomatis tampil jika gambar belum tersedia.

Setelah data atau gambar berubah, tutup aplikasi lalu jalankan ulang agar bundle aset dimuat ulang.

## Penyimpanan dan arsitektur

- Konten sumber: JSON yang dibundel dalam APK
- Favorit dan riwayat: SQLite (`sqflite`)
- Onboarding dan tema: SharedPreferences
- State management: Provider
- Struktur kode: model, repository, state/controller, screen, reusable widget
- Tidak ada login, server, API, CDN, atau tautan gambar internet

## Catatan data contoh

Paket berisi data dasar 195 negara. Delapan negara memiliki contoh konten lebih lengkap dan tersedia 29 soal agar seluruh alur langsung dapat diuji. Gambar dapat ditambahkan bertahap tanpa mengubah kode tampilan.

## Catatan perbaikan globe & tampilan

- World: globe kini disamakan dengan globe di web Histora — tekstur Blue Marble + relief, awan, batas negara (Natural Earth 110m), ketuk wilayah negara untuk menyorot dan membuka profil. Aset: `assets/images/globe/` dan `assets/data/globe_countries.json`. Negara yang terlalu kecil untuk poligon (mis. Singapura, Malta) tetap bisa dibuka lewat titik emas kecil.
- Warna font: kerudung latar tema terang diubah agar teks navy terbaca; warna emas/merah/hijau untuk teks dan ikon di atas kartu memakai varian yang kontras (`HistoraColors.accentOn/dangerOn/successOn`).
