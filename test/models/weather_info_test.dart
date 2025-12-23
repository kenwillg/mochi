import 'package:flutter_test/flutter_test.dart';
import 'package:mochi/models/weather_info.dart';

void main() {
  group('WeatherInfo', () {
    test('should create WeatherInfo with all required fields', () {
      final now = DateTime.now();
      final weather = WeatherInfo(
        locationName: 'Jakarta',
        region: 'Jakarta',
        country: 'Indonesia',
        lastUpdated: now,
        temperatureC: 30.5,
        feelsLikeC: 32.0,
        humidity: 70,
        windSpeedKph: 15.5,
        chanceOfRain: 20,
        uvIndex: 5.5,
        conditionText: 'Sunny',
        conditionIconUrl: 'https://example.com/icon.png',
        airQualityIndex: 3,
      );

      expect(weather.locationName, equals('Jakarta'));
      expect(weather.region, equals('Jakarta'));
      expect(weather.country, equals('Indonesia'));
      expect(weather.lastUpdated, equals(now));
      expect(weather.temperatureC, equals(30.5));
      expect(weather.feelsLikeC, equals(32.0));
      expect(weather.humidity, equals(70));
      expect(weather.windSpeedKph, equals(15.5));
      expect(weather.chanceOfRain, equals(20));
      expect(weather.uvIndex, equals(5.5));
      expect(weather.conditionText, equals('Sunny'));
      expect(weather.conditionIconUrl, equals('https://example.com/icon.png'));
      expect(weather.airQualityIndex, equals(3));
    });

    group('fromJson', () {
      test('should parse complete weather JSON', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': {
            'last_updated': '2024-01-15T12:00:00',
            'temp_c': 30.5,
            'feelslike_c': 32.0,
            'humidity': 70,
            'wind_kph': 15.5,
            'uv': 5.5,
            'condition': {
              'text': 'Sunny',
              'icon': 'https://example.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': 3,
            },
          },
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': 20,
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.locationName, equals('Jakarta'));
        expect(weather.region, equals('Jakarta'));
        expect(weather.country, equals('Indonesia'));
        expect(weather.temperatureC, equals(30.5));
        expect(weather.feelsLikeC, equals(32.0));
        expect(weather.humidity, equals(70));
        expect(weather.windSpeedKph, equals(15.5));
        expect(weather.chanceOfRain, equals(20));
        expect(weather.uvIndex, equals(5.5));
        expect(weather.conditionText, equals('Sunny'));
        expect(weather.conditionIconUrl, equals('https://example.com/icon.png'));
        expect(weather.airQualityIndex, equals(3));
      });

      test('should handle missing location data', () {
        final json = {
          'location': null,
          'current': {
            'last_updated': '2024-01-15T12:00:00',
            'temp_c': 30.5,
            'feelslike_c': 32.0,
            'humidity': 70,
            'wind_kph': 15.5,
            'uv': 5.5,
            'condition': {
              'text': 'Sunny',
              'icon': 'https://example.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': 3,
            },
          },
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': 20,
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.locationName, equals('Unknown'));
        expect(weather.region, equals(''));
        expect(weather.country, equals(''));
      });

      test('should handle missing current data', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': null,
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': 20,
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.temperatureC, equals(0));
        expect(weather.feelsLikeC, equals(0));
        expect(weather.humidity, equals(0));
        expect(weather.conditionText, equals('N/A'));
      });

      test('should handle missing forecast data', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': {
            'last_updated': '2024-01-15T12:00:00',
            'temp_c': 30.5,
            'feelslike_c': 32.0,
            'humidity': 70,
            'wind_kph': 15.5,
            'uv': 5.5,
            'condition': {
              'text': 'Sunny',
              'icon': 'https://example.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': 3,
            },
          },
          'forecast': null,
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.chanceOfRain, equals(0));
      });

      test('should normalize icon URL starting with //', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': {
            'last_updated': '2024-01-15T12:00:00',
            'temp_c': 30.5,
            'feelslike_c': 32.0,
            'humidity': 70,
            'wind_kph': 15.5,
            'uv': 5.5,
            'condition': {
              'text': 'Sunny',
              'icon': '//cdn.weatherapi.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': 3,
            },
          },
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': 20,
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.conditionIconUrl, equals('https://cdn.weatherapi.com/icon.png'));
      });

      test('should handle icon URL without protocol', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': {
            'last_updated': '2024-01-15T12:00:00',
            'temp_c': 30.5,
            'feelslike_c': 32.0,
            'humidity': 70,
            'wind_kph': 15.5,
            'uv': 5.5,
            'condition': {
              'text': 'Sunny',
              'icon': 'cdn.weatherapi.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': 3,
            },
          },
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': 20,
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.conditionIconUrl, equals('https://cdn.weatherapi.com/icon.png'));
      });

      test('should handle numeric string values', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': {
            'last_updated': '2024-01-15T12:00:00',
            'temp_c': '30.5',
            'feelslike_c': '32.0',
            'humidity': '70',
            'wind_kph': '15.5',
            'uv': '5.5',
            'condition': {
              'text': 'Sunny',
              'icon': 'https://example.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': '3',
            },
          },
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': '20',
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.temperatureC, equals(30.5));
        expect(weather.feelsLikeC, equals(32.0));
        expect(weather.humidity, equals(70));
        expect(weather.windSpeedKph, equals(15.5));
        expect(weather.uvIndex, equals(5.5));
        expect(weather.chanceOfRain, equals(20));
        expect(weather.airQualityIndex, equals(3));
      });

      test('should handle DateTime as string', () {
        final json = {
          'location': {
            'name': 'Jakarta',
            'region': 'Jakarta',
            'country': 'Indonesia',
          },
          'current': {
            'last_updated': '2024-01-15T12:00:00Z',
            'temp_c': 30.5,
            'feelslike_c': 32.0,
            'humidity': 70,
            'wind_kph': 15.5,
            'uv': 5.5,
            'condition': {
              'text': 'Sunny',
              'icon': 'https://example.com/icon.png',
            },
            'air_quality': {
              'us-epa-index': 3,
            },
          },
          'forecast': {
            'forecastday': [
              {
                'day': {
                  'daily_chance_of_rain': 20,
                },
              },
            ],
          },
        };

        final weather = WeatherInfo.fromJson(json);

        expect(weather.lastUpdated, isA<DateTime>());
      });
    });
  });
}

