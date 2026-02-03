import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodeUrl = 'https://geocoding-api.open-meteo.com/v1/search';
  static const String _lastLocationKey = 'last_location';
  static const String _lastWeatherKey = 'last_weather';

  /// Get current weather for user's location
  static Future<WeatherData> getCurrentWeather() async {
    try {
      final position = await _getCurrentPosition();
      return await _fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      // Try to use cached weather
      final cached = await _getCachedWeather();
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Get weather for a specific city
  static Future<WeatherData> getWeatherForCity(String cityName) async {
    final coordinates = await _geocodeCity(cityName);
    return await _fetchWeather(coordinates['lat']!, coordinates['lon']!);
  }

  /// Get current device position
  static Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, // Fast, battery efficient
    );

    // Cache the location
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode({
      'lat': position.latitude,
      'lon': position.longitude,
    }));

    return position;
  }

  /// Geocode city name to coordinates
  static Future<Map<String, double>> _geocodeCity(String cityName) async {
    final uri = Uri.parse('$_geocodeUrl?name=${Uri.encodeComponent(cityName)}&count=1');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return {
          'lat': data['results'][0]['latitude'],
          'lon': data['results'][0]['longitude'],
        };
      }
    }
    throw Exception('City not found: $cityName');
  }

  /// Fetch weather from Open-Meteo API
  static Future<WeatherData> _fetchWeather(double lat, double lon) async {
    final uri = Uri.parse(
      '$_baseUrl?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
      'weather_code,wind_speed_10m,wind_direction_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_probability_max,sunrise,sunset'
      '&timezone=auto&forecast_days=3',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final weather = WeatherData.fromOpenMeteo(data, lat, lon);
      
      // Cache the weather
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastWeatherKey, jsonEncode(weather.toJson()));
      
      return weather;
    } else {
      throw Exception('Failed to fetch weather: ${response.statusCode}');
    }
  }

  /// Get cached weather data
  static Future<WeatherData?> _getCachedWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_lastWeatherKey);
    if (cached != null) {
      return WeatherData.fromJson(jsonDecode(cached));
    }
    return null;
  }
}
