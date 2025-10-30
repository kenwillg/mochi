import 'package:flutter/foundation.dart';

@immutable
class WeatherInfo {
  const WeatherInfo({
    required this.locationName,
    required this.region,
    required this.country,
    required this.lastUpdated,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windSpeedKph,
    required this.chanceOfRain,
    required this.uvIndex,
    required this.conditionText,
    required this.conditionIconUrl,
    required this.airQualityIndex,
  });

  final String locationName;
  final String region;
  final String country;
  final DateTime lastUpdated;
  final double temperatureC;
  final double feelsLikeC;
  final int humidity;
  final double windSpeedKph;
  final int chanceOfRain;
  final double uvIndex;
  final String conditionText;
  final String conditionIconUrl;
  final int airQualityIndex;

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final current = json['current'] as Map<String, dynamic>?;
    final forecast = json['forecast'] as Map<String, dynamic>?;

    final forecastDayList = forecast?['forecastday'] as List<dynamic>?;
    final firstForecastDay =
        forecastDayList != null && forecastDayList.isNotEmpty
            ? forecastDayList.first as Map<String, dynamic>
            : null;
    final dayDetails =
        firstForecastDay?['day'] as Map<String, dynamic>? ?? const {};

    return WeatherInfo(
      locationName: (location?['name'] as String?)?.trim() ?? 'Unknown',
      region: (location?['region'] as String?)?.trim() ?? '',
      country: (location?['country'] as String?)?.trim() ?? '',
      lastUpdated: _parseDateTime(current?['last_updated']),
      temperatureC: _toDouble(current?['temp_c']),
      feelsLikeC: _toDouble(current?['feelslike_c']),
      humidity: _toInt(current?['humidity']),
      windSpeedKph: _toDouble(current?['wind_kph']),
      chanceOfRain: _toInt(dayDetails['daily_chance_of_rain']),
      uvIndex: _toDouble(current?['uv']),
      conditionText: (current?['condition']?['text'] as String?)?.trim() ??
          'N/A',
      conditionIconUrl: _normaliseIconUrl(
        current?['condition']?['icon'] as String?,
      ),
      airQualityIndex: _toInt(current?['air_quality']?['us-epa-index']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true)
          .toLocal();
    }
    return DateTime.now();
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _normaliseIconUrl(String? iconPath) {
    if (iconPath == null || iconPath.isEmpty) {
      return '';
    }
    if (iconPath.startsWith('http')) {
      return iconPath;
    }
    if (iconPath.startsWith('//')) {
      return 'https:$iconPath';
    }
    return 'https://$iconPath';
  }
}
