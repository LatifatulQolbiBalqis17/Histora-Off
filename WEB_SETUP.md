# Perbaikan sqflite untuk Web

Perubahan:
- Menambahkan `sqflite_common_ffi_web: ^0.4.5+4`.
- Android/iOS tetap menggunakan `sqflite` biasa.
- Web/Chrome menggunakan `databaseFactoryFfiWeb` dan IndexedDB.
- Database Web memakai nama `histora_web.db`.

Setelah membuka project di VS Code, jalankan di Terminal:

```bash
flutter pub get
dart run sqflite_common_ffi_web:setup
```

Perintah setup membuat `web/sqlite3.wasm` dan `web/sqflite_sw.js`.
Lalu jalankan:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Catatan: database Web tersimpan di IndexedDB browser dan terikat pada origin/port yang digunakan.
