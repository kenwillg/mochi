# Unit Tests untuk Aplikasi Mochi

Dokumen ini menjelaskan berbagai unit test yang telah dibuat untuk aplikasi Mochi.

## Struktur Test

Test dibagi menjadi beberapa kategori berdasarkan komponen yang diuji:

### 1. Models (`test/models/`)

#### `journal_entry_test.dart`
- Test untuk `DrawnStroke`: pembuatan, copyWith, default values
- Test untuk `StickerPlacement`: pembuatan, copyWith, default size
- Test untuk `TextPlacement`: pembuatan, copyWith, default values
- Test untuk `JournalEntry`: pembuatan dengan berbagai kombinasi field, copyWith

#### `weather_info_test.dart`
- Test untuk `WeatherInfo`: pembuatan dengan semua field
- Test untuk `fromJson`: parsing JSON lengkap, handling missing data, normalisasi URL icon, handling berbagai tipe data

#### `mood_test.dart`
- Test untuk enum `Mood`: validasi nilai, nama enum, pencarian berdasarkan nama

### 2. Services (`test/services/`)

#### `preferences_service_test.dart`
- Test untuk Last Sync Date: save, retrieve, update, null handling
- Test untuk First Launch: default value, set flag, persistence
- Test untuk Theme Mode: save, retrieve, update, berbagai nilai
- Test untuk User Name: save, retrieve, update, empty string handling
- Test untuk Clear All: menghapus semua preferences

#### `journal_storage_service_test.dart`
- Test untuk Save and Load Entry: mood, strokes, stickers, texts, weather, kombinasi lengkap
- Test untuk Update Entry: update existing entry
- Test untuk Date Normalization: normalisasi tanggal tanpa waktu
- Test untuk Load All Entries: load semua entries, handling berbagai tanggal
- Test untuk Delete Entry: delete entry, delete non-existent entry, delete specific entry

### 3. Providers (`test/providers/`)

#### `journal_providers_test.dart`
- Test untuk `JournalDataNotifier`:
  - Initialization dengan empty map
  - `entryFor`: return empty entry, return existing entry
  - `updateMood`: update mood, preserve weather
  - `updateCanvas`: update strokes, stickers, texts, semua elemen
  - Date normalization
- Test untuk `SelectedDateNotifier`: initialization, setDate
- Test untuk `IsSavingNotifier`: initialization, setSaving

#### `weather_provider_test.dart`
- Test untuk `WeatherFetchException`: pembuatan exception, toString
- Catatan: Testing provider weather memerlukan mocking HTTP calls

### 4. Utils (`test/utils/`)

#### `constants_test.dart`
- Test untuk constants: primaryColor, backgroundColor, accentColor
- Validasi bahwa semua warna berbeda

## Cara Menjalankan Test

### Menjalankan Semua Test
```bash
flutter test
```

### Menjalankan Test Spesifik
```bash
flutter test test/models/journal_entry_test.dart
flutter test test/services/preferences_service_test.dart
flutter test test/providers/journal_providers_test.dart
```

### Menjalankan Test dengan Coverage
```bash
flutter test --coverage
```

## Catatan Penting

1. **Mock Storage Service**: Test untuk providers menggunakan `MockJournalStorageService` untuk menghindari dependency pada database aktual.

2. **SharedPreferences**: Test untuk services menggunakan in-memory SharedPreferences untuk testing.

3. **Async Operations**: Beberapa test menangani operasi async dengan proper waiting.

4. **Color Comparison**: Test untuk color menggunakan `.value` untuk membandingkan nilai warna, bukan instance.

5. **Date Normalization**: Test memastikan bahwa tanggal dinormalisasi dengan menghapus komponen waktu.

## Coverage

Test suite ini mencakup:
- ✅ Semua model classes
- ✅ Semua service classes
- ✅ Semua provider classes
- ✅ Utility constants
- ✅ Error handling
- ✅ Edge cases (null values, empty data, dll)

## Menambahkan Test Baru

Saat menambahkan fitur baru:
1. Buat file test baru di folder yang sesuai
2. Ikuti struktur yang sudah ada
3. Test semua public methods
4. Test edge cases dan error handling
5. Pastikan test dapat dijalankan dengan `flutter test`

