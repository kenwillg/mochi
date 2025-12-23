import 'package:flutter_test/flutter_test.dart';
import 'package:mochi/providers/weather_provider.dart';

void main() {
  group('WeatherFetchException', () {
    test('should create exception with message', () {
      final exception = WeatherFetchException('Test error');
      expect(exception.message, equals('Test error'));
    });

    test('toString should return formatted message', () {
      final exception = WeatherFetchException('Test error');
      expect(exception.toString(), equals('WeatherFetchException: Test error'));
    });
  });

  // Note: _buildWeatherUri is a private function and cannot be tested directly
  // Note: Actual weatherProvider testing would require mocking HTTP calls
  // This is a basic structure test. For full integration testing,
  // you would use packages like mockito or http_mock_adapter
}

