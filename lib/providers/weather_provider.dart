import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final List<Location> _locations = [
    Location(name: 'Ha Noi', lat: 21.0227346, lon: 105.795764),
    // Location(name: 'Ben Tre Province', lat: 10.237391, lon: 106.334351),
    Location(name: 'Ho Chi Minh City', lat: 10.762622, lon: 106.660172),
    // Location(name: 'Tokyo', lat: 35.507446, lon: 139.110434),
    Location(name: 'United States', lat: 40.6974881, lon: -73.979681)
  ];

  final Map<String, Weather?> _weatherData = {};
  bool _isLoading = false;
  String? _error;

  List<Location> get locations => _locations;

  Map<String, Weather?> get weatherData => _weatherData;

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> loadAllWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (var location in _locations) {
        final weather =
            await _weatherService.getWeather(location.lat, location.lon);
        _weatherData[location.name] = weather;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to load weather data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWeather() async {
    _weatherData.clear();
    await loadAllWeather();
  }
}
