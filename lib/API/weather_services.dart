import 'dart:convert';
import 'package:aig/api.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = weatherApi;

  Future<List<Weather>> fetchWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'), // Adding units=metric
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Weather> weatherList =
          (data['list'] as List).map((item) => Weather.fromJson(item)).toList();
      return weatherList;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<CurrentWeather> fetchCurrent(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CurrentWeather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class GeocodingService {
  final String apiKey = 'AIzaSyCHNVDdM8U_OWgmfdwnNFjrIvddFi-ynWM';

  Future<Map<String, double>> getCoordinates(String address) async {
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey&units=metric'),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var location = data['results'][0]['geometry']['location'];
      return {
        'lat': location['lat'].toDouble(),
        'lng': location['lng'].toDouble()
      };
    } else {
      throw Exception('Failed to load coordinates');
    }
  }
}

// List of weatherr
class Weather {
  final DateTime dateTime;
  final double temperature;
  final double tempMax;
  final double tempMin;
  final String main;
  final String description;
  final String icon;
  final int pressure;
  final int humidity;
  final int clouds;
  final double windSpeed;
  final int windDegree;
  final double? rainVolume;

  Weather({
    required this.dateTime,
    required this.temperature,
    required this.tempMax,
    required this.tempMin,
    required this.main,
    required this.description,
    required this.icon,
    required this.pressure,
    required this.humidity,
    required this.clouds,
    required this.windSpeed,
    required this.windDegree,
    required this.rainVolume,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0.0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0.0).toDouble(),
      pressure: (json['main']['pressure'] ?? 0),
      humidity: (json['main']['humidity'] ?? 0),
      main: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      clouds: (json['clouds']['all'] ?? 0),
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
      windDegree: (json['wind']['deg'] ?? 0),
      rainVolume: (json['rain'] != null ? json['rain']['1h'] ?? 0.0 : 0.0)?.toDouble(),
    );
  }
}

//Current weather
class CurrentWeather {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String main;
  final String description;
  final String icon;
  final int pressure;
  final int humidity;
  final int clouds;
  final double windSpeed;
  final int windDegree;
  final double? rainVolume;

  CurrentWeather({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.main,
    required this.description,
    required this.icon,
    required this.pressure,
    required this.humidity,
    required this.clouds,
    required this.windSpeed,
    required this.windDegree,
    required this.rainVolume,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0.0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0.0).toDouble(),
      main: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      clouds: json['clouds']['all'],
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
      windDegree: json['wind']['deg'],
      rainVolume:
          (json['rain'] != null ? json['rain']['1h'] ?? 0.0 : 0.0)?.toDouble(),
    );
  }
}
