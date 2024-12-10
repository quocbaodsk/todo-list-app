// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/api_error.dart';

class WeatherService {
  static const String apiKey = '892b5d39f4439a1d756253800211d442'; // OpenWeatherMap API key
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> getWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        throw ApiException(
          ApiError(
            status: response.statusCode,
            message: 'Failed to load weather data',
          ),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        ApiError(
          status: 500,
          message: 'Network error occurred',
        ),
      );
    }
  }

  Future<List<Weather>> getForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['list'] as List;
        return list.map((item) => Weather.fromJson(item)).toList();
      } else {
        throw ApiException(
          ApiError(
            status: response.statusCode,
            message: 'Failed to load forecast data',
          ),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        ApiError(
          status: 500,
          message: 'Network error occurred',
        ),
      );
    }
  }

  Future<Weather> getWeatherByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/weather?q=$city&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        throw ApiException(
          ApiError(
            status: response.statusCode,
            message: 'Failed to load weather data',
          ),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        ApiError(
          status: 500,
          message: 'Network error occurred',
        ),
      );
    }
  }

  Future<List<Weather>> getForecastByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/forecast?q=$city&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['list'] as List;
        return list.map((item) => Weather.fromJson(item)).toList();
      } else {
        throw ApiException(
          ApiError(
            status: response.statusCode,
            message: 'Failed to load forecast data',
          ),
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        ApiError(
          status: 500,
          message: 'Network error occurred',
        ),
      );
    }
  }
}