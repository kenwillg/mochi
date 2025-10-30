# Mochi

Mochi is the teaching companion app for our Flutter curriculum. The codebase is structured to highlight key concepts—widgets, styling, state management, asynchronous work, and more—so learners can trace each lesson directly into the source.

## Cross-Platform vs. Native Development

| Topic | Cross-Platform (Flutter) | Native (Kotlin/Swift) |
| --- | --- | --- |
| **Codebase** | Single Dart codebase compiled for Android, iOS, web, and desktop. | Separate projects per platform, typically Kotlin/Java for Android and Swift/Objective-C for iOS. |
| **UI Consistency** | Flutter renders widgets with its own engine, ensuring a uniform look across platforms. | Relies on platform-native UI kits (Jetpack Compose, UIKit/SwiftUI), so parity must be maintained manually. |
| **Performance** | Near-native due to ahead-of-time compilation and Skia rendering; performance tuning focuses on widget build cost. | Native APIs offer full access to platform tooling and optimizations with minimal abstraction overhead. |
| **Team Skills** | Dart/Flutter knowledge scales across platforms; designers and developers share widget libraries. | Requires platform-specific expertise; features may ship on different timelines per platform. |
| **Ecosystem** | Strong community packages, plus platform channels for native integrations when needed. | Direct access to the latest platform features, but code reuse across platforms is minimal. |

## Environment Setup

(Bagian ini tidak berubah, setup tetap sama)

... (Salin bagian "Environment Setup" dari file README.md lamamu di sini) ...

## Project Structure (Updated)

Proyek ini telah di-refactor dari template awal untuk skalabilitas yang lebih baik.
## Project Structure

```
├── lib/
│   ├── app.dart                  # Konfigurasi MaterialApp, tema, & rute
│   ├── main.dart                 # Entry point utama, inisialisasi app & database
│   │
│   ├── models/                   # Model data (POCO - Plain Old Dart Objects)
│   │   ├── journal_entry.dart    # Defines DrawnStroke, StickerPlacement, JournalEntry
│   │   └── mood.dart
│   │
│   ├── providers/                # State Management (Riverpod)
│   │   └── journal_providers.dart
│   │
│   ├── screens/                  # Setiap halaman full-screen
│   │   ├── demo_menu_screen.dart
│   │   ├── home_screen.dart
│   │   ├── journal_entry_screen.dart
│   │   └── ... (demo screens lainnya)
│   │
│   ├── services/                 # Logika bisnis (Database, API)
│   │   └── database_service.dart
│   │
│   ├── utils/                    # Kode utilitas
│   │   └── constants.dart        # Warna tema & konstanta
│   │
│   └── widgets/                  # Widget yang bisa dipakai ulang
│       ├── daily_details_card.dart
│       ├── demo_section.dart
│       └── demo_widgets.dart
│
├── test/
│   └── widget_test.dart
│
├── android/
├── ios/
├── web/
└── pubspec.yaml                  # Dependencies
```

Use `lib/` as the canonical place for new lesson modules. Additional folders such as `lib/services/` or `lib/widgets/` can be introduced in later lessons when topics require them.

## Task Fulfillment (Pemenuhan Tugas)

Berikut adalah pemetaan dari daftar tugas ke implementasi di dalam codebase ini.

### Tugas 1: Interface yang bagus (UI)

* **UI Utama:** `lib/screens/home_screen.dart` (Scaffold, AppBar, `TableCalendar`, `BottomNavigationBar`).
* **UI Dialog:** `lib/widgets/daily_details_card.dart` (Kartu custom untuk `AlertDialog`).
* **UI Kustom (Canvas):** `lib/screens/journal_entry_screen.dart` (UI untuk menggambar dan menempel stiker).
* **Styling & Theme:** `lib/app.dart` (Definisi `ThemeData`, `GoogleFonts`) dan `lib/utils/constants.dart` (Palet warna).

### Tugas 2: Riverpod State Management (3+ Widget)

State management utama ditangani oleh Riverpod dan terpusat di `lib/providers/journal_providers.dart`.

1.  **`journalProvider`:** Sebuah `StateNotifierProvider` yang mengelola `Map<DateTime, JournalEntry>`. Ini adalah "otak" aplikasi.
2.  **`lib/screens/home_screen.dart`:** Sebuah `ConsumerWidget` yang me-*watch* `journalProvider` untuk menampilkan *marker* di kalender.
3.  **`lib/widgets/daily_details_card.dart`:** Sebuah `ConsumerWidget` yang me-*read* dan me-*write* ke `journalProvider` (saat memilih mood) dan `isSavingProvider` (untuk loading).
4.  **`lib/screens/journal_entry_screen.dart`:** (Menggunakan `Consumer`) untuk me-*read* dan me-*write* data kanvas (strokes/stickers) ke `journalProvider`.

### Tugas 3: Alert, Dialog, Local State, Loading

* **Alert and Dialog:**
    * `lib/screens/home_screen.dart`: Menampilkan `AlertDialog` custom saat tombol `+` ditekan.
    * `lib/screens/journal_entry_screen.dart`: Menampilkan `AlertDialog` untuk memilih stiker.
* **Local State (`setState`):**
    * `lib/screens/journal_entry_screen.dart`: Menggunakan `StatefulWidget` untuk mengelola state *lokal* dari `_drawingPoints`, `_stickers`, dan `_selectedStickerIndex` saat menggambar dan memindahkan stiker.
* **Option (Pilihan):**
    * `lib/widgets/daily_details_card.dart`: Menggunakan `ChoiceChip` untuk memilih `Mood`.
* **Image/Icon:**
    * `lib/models/sticker_data.dart`: Menggunakan `IconData` (happy, neutral, sad) sebagai "gambar" stiker.
    * `lib/widgets/demo_widgets.dart`: Menampilkan `Image.network` di demo `ProfileBadge`.
* **Loading:**
    * `lib/widgets/daily_details_card.dart`: Menampilkan `CircularProgressIndicator` saat menyimpan, dikontrol oleh `isSavingProvider`.

### Tugas 4: Flutter Concepts Checklist

* **Konsep cross-platform vs native:** Didokumentasikan di `README.md` (lihat tabel di atas).
* **Instalasi & Struktur Project:** Didokumentasikan di `README.md` (lihat di atas).
* **Variabel, Tipe Data, Control Flow, Function, Class, OOP:** Diterapkan di semua file Dart. Contoh bagus: `lib/models/journal_entry.dart` (Class, `copyWith`), `lib/providers/journal_providers.dart` (Class, Function, `Map`).
* **Null Safety:** Diterapkan di seluruh proyek (misal `Mood?`, `List<Offset?>`). Demo spesifik ada di `lib/screens/null_safety_demo_screen.dart`.
* **Stateless vs Stateful Widget:** `lib/app.dart` (Stateless), `lib/screens/journal_entry_screen.dart` (Stateful). Demo spesifik ada di `lib/screens/stateless_stateful_demo_screen.dart`.
* **Layout (Text, Container, Row, Column):** Diterapkan di semua file UI.
* **Padding, Margin, Alignment:** Diterapkan di `lib/widgets/daily_details_card.dart`.
* **ListView, GridView, Stack:**
    * `ListView`: `lib/screens/home_screen.dart`
    * `Stack`: `lib/screens/journal_entry_screen.dart` (untuk menumpuk Painter dan Stiker).
    * `GridView`: `lib/widgets/demo_widgets.dart` (`MoodChoiceGrid`).
* **Styling dengan Theme:** Diterapkan di `lib/app.dart`.
* **Input (TextField, Button, GestureDetector):**
    * `GestureDetector`: `lib/screens/journal_entry_screen.dart` (untuk menggambar dan memindahkan stiker).
    * `ElevatedButton`: `lib/widgets/daily_details_card.dart`.
    * `TextField` & `Form`: `lib/widgets/demo_widgets.dart` (`ValidatedContactForm`).
* **`setState` & Lifting State Up:** Demo spesifik ada di `lib/screens/set_state_demo_screen.dart` dan `lib/screens/lifting_state_demo_screen.dart`.
* **Navigasi (Push/Pop, Named, Passing Data):**
    * `lib/app.dart`: Mendefinisikan *named routes*.
    * `lib/widgets/daily_details_card.dart`: Melakukan `Navigator.of(context).pop()` (untuk menutup dialog) lalu `Navigator.of(context, rootNavigator: true).pushNamed(...)` (untuk membuka halaman baru).
    * *Passing Data*: Mengirim `DateTime` dari `daily_details_card.dart` ke `journal_entry_screen.dart` melalui *arguments*.
* **HTTP Request (GET) & Parsing JSON:**
    * `lib/providers/weather_provider.dart`: Berisi logika untuk `http.get` ke API cuaca.
    * `lib/models/weather_info.dart`: Berisi logika `factory Weather.fromJson(...)` untuk parsing JSON.
    * `lib/models/journal_entry.dart`: Menggunakan `jsonEncode` dan `jsonDecode` untuk serialisasi data kanvas ke/dari database SQLite.

### Tugas 5: Persistence

* **Riverpod Flow:** (Tugas 5.1) Selesai. Provider sudah terstruktur dan dapat diakses oleh semua *screen* yang membutuhkan (`home_screen`, `daily_details_card`, `journal_entry_screen`).
* **SQLite:** (Tugas 5.2) Selesai.
    * `lib/services/database_service.dart`: Mengelola inisialisasi DB, `CREATE TABLE`, `loadEntries`, dan `saveEntry`.
    * `lib/models/journal_entry.dart`: Mengimplementasikan `toDbMap()` dan `fromDbMap()` untuk serialisasi JSON.
    * `lib/providers/journal_providers.dart`: `JournalDataNotifier` sekarang di-inject dengan `DatabaseService`. Data di-load saat provider pertama kali dibuat dan disimpan ke DB setiap kali `updateMood` atau `updateCanvas` dipanggil.
* **SharedPreferences:** (Tugas 5.2) Belum diimplementasikan. (Lihat "Next Steps").

## Next Steps / Future Work

* **Implement SharedPreferences:** Gunakan `SharedPreferences` untuk menyimpan data simpel, seperti nama pengguna atau preferensi tema (dark/light mode).
* **Weather API:** Integrasikan `WeatherService` ke dalam UI, mungkin di `AppBar` atau `DailyDetailsCard` untuk menunjukkan cuaca pada hari itu.
