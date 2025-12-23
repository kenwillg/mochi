// This file imports all test files to run them together
// Run with: flutter test test/all_tests.dart

import 'models/journal_entry_test.dart' as journal_entry_test;
import 'models/weather_info_test.dart' as weather_info_test;
import 'models/mood_test.dart' as mood_test;
import 'services/preferences_service_test.dart' as preferences_service_test;
import 'services/journal_storage_service_test.dart' as journal_storage_service_test;
import 'providers/journal_providers_test.dart' as journal_providers_test;
import 'providers/weather_provider_test.dart' as weather_provider_test;
import 'utils/constants_test.dart' as constants_test;

void main() {
  journal_entry_test.main();
  weather_info_test.main();
  mood_test.main();
  preferences_service_test.main();
  journal_storage_service_test.main();
  journal_providers_test.main();
  weather_provider_test.main();
  constants_test.main();
}

