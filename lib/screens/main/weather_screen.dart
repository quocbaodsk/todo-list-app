// lib/screens/main/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../models/location.dart';
import '../../models/weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherProvider>().loadAllWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.weatherData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   'Error: ${provider.error}',
                //   style: TextStyle(
                //     color: Theme.of(context).colorScheme.error,
                //   ),
                // ),
                Lottie.asset('assets/animations/error.json'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: provider.loadAllWeather,
                  // child: const Icon(Icons.refresh_outlined),
                  child: const Text("Retry")
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.refreshWeather,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.locations.length,
            itemBuilder: (context, index) {
              final location = provider.locations[index];
              final weather = provider.weatherData[location.name];

              return WeatherCard(
                location: location,
                weather: weather,
              );
            },

          ),
        );
      },
    );
  }
}

class WeatherCard extends StatelessWidget {
  final Location location;
  final Weather? weather;

  const WeatherCard({
    super.key,
    required this.location,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (weather == null) {
      return const Card(
        margin: EdgeInsets.only(bottom: 12),
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              colorScheme.surfaceContainerHighest,
              colorScheme.surface,
            ]
                : [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Description
                    Text(
                      weather!.cityName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather!.description.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    // Weather Info
                    Row(
                      children: [
                        // Temp
                        Text(
                          '${weather!.temperature.round()}°C',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.network(
                          weather!.iconUrl,
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Details
                    Row(
                      children: [
                        Icon(Icons.water_drop, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${weather!.humidity}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.air, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${weather!.windSpeed.toStringAsFixed(1)} m/s',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                color: colorScheme.outlineVariant,
              ),
              const SizedBox(width: 12),
              // Visibility
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 24, color: colorScheme.primary),
                    const SizedBox(height: 4),
                    Text(
                      'Visibility',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${(weather!.visibility / 1000).toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}