class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  /// Get spoken weather briefing text
  String getSpokenBriefing() {
    final condition = current.weatherDescription;
    final temp = current.temperature.round();
    final feelsLike = current.apparentTemperature.round();
    final humidity = current.humidity.round();
    final windSpeed = current.windSpeed.round();
    
    final todayForecast = daily.isNotEmpty ? daily[0] : null;
    final highTemp = todayForecast?.temperatureMax.round() ?? temp;
    final lowTemp = todayForecast?.temperatureMin.round() ?? temp;
    final precipChance = todayForecast?.precipitationProbability ?? 0;

    String briefing = 'Current weather conditions: $condition. '
        'Temperature is $temp degrees, feels like $feelsLike. '
        'Today\'s high will be $highTemp degrees, low of $lowTemp. ';
    
    if (precipChance > 30) {
      briefing += 'There is a $precipChance percent chance of precipitation. ';
    }
    
    if (windSpeed > 20) {
      briefing += 'Wind speeds at $windSpeed kilometers per hour. ';
    }
    
    briefing += 'Humidity is at $humidity percent.';
    
    return briefing;
  }

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json, double lat, double lon) {
    final currentData = json['current'];
    final dailyData = json['daily'];
    
    return WeatherData(
      latitude: lat,
      longitude: lon,
      timezone: json['timezone'] ?? 'UTC',
      current: CurrentWeather(
        temperature: (currentData['temperature_2m'] as num).toDouble(),
        apparentTemperature: (currentData['apparent_temperature'] as num).toDouble(),
        humidity: (currentData['relative_humidity_2m'] as num).toDouble(),
        weatherCode: currentData['weather_code'] as int,
        windSpeed: (currentData['wind_speed_10m'] as num).toDouble(),
        windDirection: (currentData['wind_direction_10m'] as num).toDouble(),
      ),
      daily: List.generate(
        (dailyData['time'] as List).length,
        (i) => DailyForecast(
          date: DateTime.parse(dailyData['time'][i]),
          temperatureMax: (dailyData['temperature_2m_max'][i] as num).toDouble(),
          temperatureMin: (dailyData['temperature_2m_min'][i] as num).toDouble(),
          weatherCode: dailyData['weather_code'][i] as int,
          precipitationProbability: dailyData['precipitation_probability_max'][i] as int,
          sunrise: DateTime.parse(dailyData['sunrise'][i]),
          sunset: DateTime.parse(dailyData['sunset'][i]),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'current': current.toJson(),
      'daily': daily.map((d) => d.toJson()).toList(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timezone: json['timezone'],
      current: CurrentWeather.fromJson(json['current']),
      daily: (json['daily'] as List)
          .map((d) => DailyForecast.fromJson(d))
          .toList(),
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final double humidity;
  final int weatherCode;
  final double windSpeed;
  final double windDirection;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
  });

  String get weatherDescription => _getWeatherDescription(weatherCode);
  String get weatherIcon => _getWeatherIcon(weatherCode);

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'apparentTemperature': apparentTemperature,
    'humidity': humidity,
    'weatherCode': weatherCode,
    'windSpeed': windSpeed,
    'windDirection': windDirection,
  };

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: json['temperature'],
      apparentTemperature: json['apparentTemperature'],
      humidity: json['humidity'],
      weatherCode: json['weatherCode'],
      windSpeed: json['windSpeed'],
      windDirection: json['windDirection'],
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;
  final int precipitationProbability;
  final DateTime sunrise;
  final DateTime sunset;

  DailyForecast({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.sunrise,
    required this.sunset,
  });

  String get weatherDescription => _getWeatherDescription(weatherCode);
  String get weatherIcon => _getWeatherIcon(weatherCode);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'temperatureMax': temperatureMax,
    'temperatureMin': temperatureMin,
    'weatherCode': weatherCode,
    'precipitationProbability': precipitationProbability,
    'sunrise': sunrise.toIso8601String(),
    'sunset': sunset.toIso8601String(),
  };

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.parse(json['date']),
      temperatureMax: json['temperatureMax'],
      temperatureMin: json['temperatureMin'],
      weatherCode: json['weatherCode'],
      precipitationProbability: json['precipitationProbability'],
      sunrise: DateTime.parse(json['sunrise']),
      sunset: DateTime.parse(json['sunset']),
    );
  }
}

/// WMO Weather interpretation codes to description
String _getWeatherDescription(int code) {
  switch (code) {
    case 0: return 'Clear sky';
    case 1: return 'Mainly clear';
    case 2: return 'Partly cloudy';
    case 3: return 'Overcast';
    case 45: return 'Fog';
    case 48: return 'Depositing rime fog';
    case 51: return 'Light drizzle';
    case 53: return 'Moderate drizzle';
    case 55: return 'Dense drizzle';
    case 56: return 'Light freezing drizzle';
    case 57: return 'Dense freezing drizzle';
    case 61: return 'Slight rain';
    case 63: return 'Moderate rain';
    case 65: return 'Heavy rain';
    case 66: return 'Light freezing rain';
    case 67: return 'Heavy freezing rain';
    case 71: return 'Slight snowfall';
    case 73: return 'Moderate snowfall';
    case 75: return 'Heavy snowfall';
    case 77: return 'Snow grains';
    case 80: return 'Slight rain showers';
    case 81: return 'Moderate rain showers';
    case 82: return 'Violent rain showers';
    case 85: return 'Slight snow showers';
    case 86: return 'Heavy snow showers';
    case 95: return 'Thunderstorm';
    case 96: return 'Thunderstorm with slight hail';
    case 99: return 'Thunderstorm with heavy hail';
    default: return 'Unknown';
  }
}

/// WMO Weather interpretation codes to icon
String _getWeatherIcon(int code) {
  switch (code) {
    case 0: return '☀️';
    case 1: return '🌤️';
    case 2: return '⛅';
    case 3: return '☁️';
    case 45:
    case 48: return '🌫️';
    case 51:
    case 53:
    case 55: return '🌧️';
    case 56:
    case 57: return '🌨️';
    case 61:
    case 63:
    case 65: return '🌧️';
    case 66:
    case 67: return '🌨️';
    case 71:
    case 73:
    case 75:
    case 77: return '❄️';
    case 80:
    case 81:
    case 82: return '🌦️';
    case 85:
    case 86: return '🌨️';
    case 95:
    case 96:
    case 99: return '⛈️';
    default: return '🌡️';
  }
}
