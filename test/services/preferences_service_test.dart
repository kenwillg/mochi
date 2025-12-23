import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mochi/services/preferences_service.dart';

void main() {
  late PreferencesService service;

  setUp(() async {
    // Use in-memory SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    service = PreferencesService();
    await service.clearAll();
  });

  group('PreferencesService', () {
    group('Last Sync Date', () {
      test('should save and retrieve last sync date', () async {
        final date = DateTime(2024, 1, 15, 12, 30);
        await service.setLastSyncDate(date);
        final retrieved = await service.getLastSyncDate();

        expect(retrieved, isNotNull);
        expect(retrieved!.year, equals(2024));
        expect(retrieved.month, equals(1));
        expect(retrieved.day, equals(15));
      });

      test('should return null when no sync date is set', () async {
        final retrieved = await service.getLastSyncDate();
        expect(retrieved, isNull);
      });

      test('should update existing sync date', () async {
        final date1 = DateTime(2024, 1, 15);
        final date2 = DateTime(2024, 2, 20);

        await service.setLastSyncDate(date1);
        await service.setLastSyncDate(date2);

        final retrieved = await service.getLastSyncDate();
        expect(retrieved, isNotNull);
        expect(retrieved!.month, equals(2));
        expect(retrieved.day, equals(20));
      });
    });

    group('First Launch', () {
      test('should return true for first launch by default', () async {
        final isFirst = await service.isFirstLaunch();
        expect(isFirst, isTrue);
      });

      test('should set first launch to false', () async {
        await service.setFirstLaunchComplete();
        final isFirst = await service.isFirstLaunch();
        expect(isFirst, isFalse);
      });

      test('should persist first launch status', () async {
        await service.setFirstLaunchComplete();
        
        // Create new service instance to test persistence
        final newService = PreferencesService();
        final isFirst = await newService.isFirstLaunch();
        expect(isFirst, isFalse);
      });
    });

    group('Theme Mode', () {
      test('should save and retrieve theme mode', () async {
        await service.setThemeMode('dark');
        final theme = await service.getThemeMode();

        expect(theme, equals('dark'));
      });

      test('should return null when no theme mode is set', () async {
        final theme = await service.getThemeMode();
        expect(theme, isNull);
      });

      test('should update existing theme mode', () async {
        await service.setThemeMode('light');
        await service.setThemeMode('dark');

        final theme = await service.getThemeMode();
        expect(theme, equals('dark'));
      });

      test('should handle different theme mode values', () async {
        await service.setThemeMode('system');
        final theme = await service.getThemeMode();
        expect(theme, equals('system'));
      });
    });

    group('User Name', () {
      test('should save and retrieve user name', () async {
        await service.setUserName('John Doe');
        final name = await service.getUserName();

        expect(name, equals('John Doe'));
      });

      test('should return null when no user name is set', () async {
        final name = await service.getUserName();
        expect(name, isNull);
      });

      test('should update existing user name', () async {
        await service.setUserName('John');
        await service.setUserName('Jane');

        final name = await service.getUserName();
        expect(name, equals('Jane'));
      });

      test('should handle empty string user name', () async {
        await service.setUserName('');
        final name = await service.getUserName();
        expect(name, equals(''));
      });
    });

    group('Clear All', () {
      test('should clear all preferences', () async {
        await service.setLastSyncDate(DateTime.now());
        await service.setFirstLaunchComplete();
        await service.setThemeMode('dark');
        await service.setUserName('Test User');

        await service.clearAll();

        expect(await service.getLastSyncDate(), isNull);
        expect(await service.isFirstLaunch(), isTrue);
        expect(await service.getThemeMode(), isNull);
        expect(await service.getUserName(), isNull);
      });
    });
  });
}

