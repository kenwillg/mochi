import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/weather_info.dart';

const _weatherApiKey = 'fc82e106ec52401aa40171603250610';
const _weatherQuery = 'Jakarta';

Uri _buildWeatherUri() {
  return Uri.https('api.weatherapi.com', 'v1/forecast.json', {
    'key': _weatherApiKey,
    'q': _weatherQuery,
    'days': '1',
    'aqi': 'yes',
    'alerts': 'yes',
  });
}

class WeatherFetchException implements Exception {
  WeatherFetchException(this.message);

  final String message;

  @override
  String toString() => 'WeatherFetchException: $message';
}

final weatherProvider = FutureProvider<WeatherInfo>((ref) async {
  final response = await http.get(_buildWeatherUri());

  if (response.statusCode != 200) {
    throw WeatherFetchException(
      'Weather API returned ${response.statusCode}',
    );
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  return WeatherInfo.fromJson(decoded);
});
