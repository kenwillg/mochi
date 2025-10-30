import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/weather_info.dart';
import '../providers/weather_provider.dart';

class WeatherIconButton extends ConsumerWidget {
  const WeatherIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return weatherAsync.when(
      data: (weather) {
        final tooltipLocation = [
          weather.locationName,
          weather.region,
        ].where((segment) => segment.trim().isNotEmpty).join(', ');

        return IconButton(
          icon: _WeatherIcon(iconUrl: weather.conditionIconUrl),
          tooltip: tooltipLocation.isEmpty
              ? 'Show weather details'
              : 'Show weather for $tooltipLocation',
          onPressed: () => _showWeatherDialog(context, weather),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stackTrace) => IconButton(
        icon: const Icon(Icons.cloud_off_outlined),
        tooltip: 'Retry weather fetch',
        onPressed: () {
          ref.invalidate(weatherProvider);
        },
      ),
    );
  }

  void _showWeatherDialog(BuildContext context, WeatherInfo weather) {
    final formattedUpdatedAt = DateFormat('MMM d, yyyy HH:mm')
        .format(weather.lastUpdated.toLocal());
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final locationParts = <String>[
          weather.locationName,
          weather.region,
          weather.country,
        ]..removeWhere((part) => part.trim().isEmpty);

        return AlertDialog(
          title: Text(locationParts.join(', ')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _WeatherIcon(iconUrl: weather.conditionIconUrl, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.conditionText,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${weather.temperatureC.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Feels like ${weather.feelsLikeC.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _WeatherDetailRow(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${weather.humidity}%',
              ),
              _WeatherDetailRow(
                icon: Icons.air,
                label: 'Wind',
                value: '${weather.windSpeedKph.toStringAsFixed(1)} km/h',
              ),
              _WeatherDetailRow(
                icon: Icons.beach_access_outlined,
                label: 'Chance of rain',
                value: '${weather.chanceOfRain}%',
              ),
              _WeatherDetailRow(
                icon: Icons.wb_sunny_outlined,
                label: 'UV index',
                value: weather.uvIndex.toStringAsFixed(1),
              ),
              _WeatherDetailRow(
                icon: Icons.health_and_safety_outlined,
                label: 'Air quality (US EPA)',
                value: weather.airQualityIndex.toString(),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: $formattedUpdatedAt',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({
    required this.iconUrl,
    this.size = 24,
  });

  final String iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconUrl.isEmpty) {
      return Icon(Icons.cloud_outlined, size: size);
    }
    return Image.network(
      iconUrl,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.cloud_outlined, size: size),
    );
  }
}

class _WeatherDetailRow extends StatelessWidget {
  const _WeatherDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
