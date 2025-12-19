# Riverpod Widgets Documentation (Tugas 2)

## Widgets yang Menggunakan Riverpod State Management

Berikut adalah **3+ widget** yang menggunakan Riverpod untuk state management:

### 1. **MochiHomePage** (`lib/screens/home_screen.dart`)
- **Type**: `ConsumerStatefulWidget`
- **Providers yang digunakan**:
  - `journalProvider` - untuk membaca data journal entries
  - `selectedDateProvider` - untuk mengelola tanggal yang dipilih di kalender
- **Cara penggunaan**:
  ```dart
  final selectedDate = ref.watch(selectedDateProvider);
  final journalData = ref.watch(journalProvider);
  ref.read(selectedDateProvider.notifier).setDate(newSelectedDay);
  ```
- **Fungsi**: Menampilkan kalender dan marker untuk hari-hari yang memiliki journal entry

### 2. **DailyDetailsCard** (`lib/widgets/daily_details_card.dart`)
- **Type**: `ConsumerWidget`
- **Providers yang digunakan**:
  - `journalProvider` - untuk membaca dan menulis journal entries
  - `isSavingProvider` - untuk mengelola loading state saat menyimpan
- **Cara penggunaan**:
  ```dart
  final journalData = ref.watch(journalProvider);
  final isSaving = ref.watch(isSavingProvider);
  ref.read(journalProvider.notifier).updateMood(dateKey, mood);
  ref.read(isSavingProvider.notifier).setSaving(true);
  ```
- **Fungsi**: Menampilkan dialog untuk memilih mood dan menyimpan entry

### 3. **JournalEntryScreen** (`lib/screens/journal_entry_screen.dart`)
- **Type**: `ConsumerStatefulWidget`
- **Providers yang digunakan**:
  - `journalProvider` - untuk membaca dan menyimpan canvas data (strokes, stickers, texts)
- **Cara penggunaan**:
  ```dart
  final entry = ref.read(journalProvider.notifier).entryFor(widget.date);
  ref.read(journalProvider.notifier).updateCanvas(widget.date, ...);
  ```
- **Fungsi**: Screen untuk menggambar, menambahkan text, dan sticker pada journal entry

### 4. **WeatherIconButton** (`lib/widgets/weather_icon_button.dart`)
- **Type**: `ConsumerWidget`
- **Providers yang digunakan**:
  - `weatherProvider` - untuk mengambil data cuaca dari API
- **Cara penggunaan**:
  ```dart
  final weatherAsync = ref.watch(weatherProvider);
  ```
- **Fungsi**: Menampilkan icon cuaca di AppBar

### 5. **StatsScreen** (`lib/screens/stats_screen.dart`)
- **Type**: `ConsumerWidget`
- **Providers yang digunakan**:
  - `journalProvider` - untuk membaca semua journal entries untuk statistik
- **Cara penggunaan**:
  ```dart
  final journalData = ref.watch(journalProvider);
  ```
- **Fungsi**: Menampilkan statistik dari journal entries (mood distribution, total entries, dll)

---

## Summary

**Total: 5 Widgets menggunakan Riverpod**

1. MochiHomePage (ConsumerStatefulWidget)
2. DailyDetailsCard (ConsumerWidget)
3. JournalEntryScreen (ConsumerStatefulWidget)
4. WeatherIconButton (ConsumerWidget)
5. StatsScreen (ConsumerWidget)

Semua widget ini menggunakan `ref.watch()` untuk membaca state dan `ref.read()` untuk mengakses notifier untuk update state.

