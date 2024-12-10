class Weather {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int visibility;
  final String description;
  final String icon;
  final String cityName;
  final DateTime timestamp;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.timestamp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];

    return Weather(
      temperature: (main['temp'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      visibility: json['visibility'] as int,
      description: weather['description'],
      icon: weather['icon'],
      cityName: json['name'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/w/$icon.png';
}