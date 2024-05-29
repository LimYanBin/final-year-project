import 'dart:async';
import 'package:aig/API/database.dart';
import 'package:aig/API/weather_services.dart';
import 'package:aig/theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  final String uId;
  final String
      farmId; // This selection is to indicate call from homepage or farm page
  final int selection;
  const WeatherPage(
      {super.key,
      required this.uId,
      required this.farmId,
      required this.selection});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final Database db = Database();
  final WeatherService _weatherService = WeatherService();
  final GeocodingService _geocodingService = GeocodingService();

  String? selectedFarmName;
  String? selectedAddress;
  List<Map<String, String>> farms = [];
  Future<List<Weather>>? _weatherFuture;
  Future<CurrentWeather>? _weatherCurrent;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.selection == 1) {
      _loadFarmList();
    } else {
      _loadFarm();
    }
  }

  Future<void> _loadFarmList() async {
    setState(() {
      isLoading = true;
    });

    List<Map<String, String>> retrievedFarms = await db.getFarms(widget.uId);
    setState(() {
      farms = retrievedFarms;
      if (farms.isNotEmpty) {
        selectedFarmName = farms[0]['name'];
        selectedAddress = farms[0]['address'];
        _fetchWeather();
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadFarm() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> retrievedFarms =
        await db.getAFarms(widget.uId, widget.farmId);

    setState(() {
      farms = [retrievedFarms];
      if (farms.isNotEmpty) {
        selectedFarmName = farms[0]['name'];
        selectedAddress = farms[0]['address'];
        _fetchWeather();
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  void _onFarmSelected(String? farmName) {
    if (farmName != null) {
      setState(() {
        selectedFarmName = farmName;
        selectedAddress =
            farms.firstWhere((farm) => farm['name'] == farmName)['address'];
        _fetchWeather();
      });
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    if (selectedAddress != null) {
      var coordinates =
          await _geocodingService.getCoordinates(selectedAddress!);

      // Ensure that the coordinates are doubles and handle null values
      double lat = coordinates['lat'] is int
          ? (coordinates['lat'] as int).toDouble()
          : coordinates['lat'] ?? 0.0;
      double lng = coordinates['lng'] is int
          ? (coordinates['lng'] as int).toDouble()
          : coordinates['lng'] ?? 0.0;

      var weather = await _weatherService.fetchWeather(lat, lng);
      var current = await _weatherService.fetchCurrent(lat, lng);

      setState(() {
        _weatherFuture = Future.value(weather);
        _weatherCurrent = Future.value(current);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  String getDayOfWeek(DateTime dateTime) {
    return DateFormat('EEEE')
        .format(dateTime); // 'EEEE' gives the full name of the day
  }

  String getFullDate(DateTime dateTime) {
    return DateFormat('EEEE MMMM d').format(
        dateTime); // 'MMMM d' gives the full month name and day of the month
  }

  String getTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime); // Format: "hh:mm AM/PM"
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.05;
    double paddingHeight = screenHeight * 0.03;
    double boxWidth = screenWidth * 0.50;
    double boxWidth2 = screenWidth * 0.90;
    double boxHeight2 = screenWidth * 1.45;

    return Scaffold(
      backgroundColor: AppC.bgdWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
          child: AppBar(
            backgroundColor: AppC.dBlue,
            title: Text(
              'Weather Forecasts',
              style: AppText.title,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: paddingWidth, vertical: paddingHeight),
                child: Column(
                  children: [
                    Container(
                      width: boxWidth2,
                      height: boxHeight2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[600]!, Colors.blue[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.selection == 1) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 30,
                                  color: AppC.white,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                DropdownButton<String>(
                                  value: selectedFarmName,
                                  icon: Icon(Icons.arrow_downward_rounded,
                                      color: AppC.white),
                                  dropdownColor: AppC.white,
                                  onChanged: (String? newValue) {
                                    _onFarmSelected(newValue);
                                  },
                                  items: farms.map((Map<String, String> farm) {
                                    return DropdownMenuItem<String>(
                                      value: farm['name'],
                                      child: SizedBox(
                                        width: boxWidth,
                                        child: Text(
                                          farm['name']!,
                                          style: AppText.text,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ] else ...[
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Current Weather Information',
                              style: AppText.title2.copyWith(color: AppC.white),
                            ),
                          ],
                          FutureBuilder<CurrentWeather>(
                            future: _weatherCurrent,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData) {
                                return Center(
                                    child: Text('No weather data available'));
                              } else {
                                CurrentWeather weather = snapshot.data!;
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/weather/${weather.icon}.png',
                                            width: 100,
                                            height: 100,
                                          ),
                                          SizedBox(width: 25),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(weather.main,
                                                    style: AppText.title
                                                        .copyWith(
                                                            color: AppC.white
                                                                .withOpacity(
                                                                    0.8))),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  weather.description,
                                                  style: AppText.title2
                                                      .copyWith(
                                                          color: AppC
                                                              .white
                                                              .withOpacity(
                                                                  0.8)),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${weather.temperature} °C',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 38,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                                Text(
                                                  getFullDate(weather.dateTime),
                                                  style: AppText.text.copyWith(
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 60,
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                'assets/weather/humidity.png',
                                                width: 50,
                                                height: 50,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                '${weather.humidity} %',
                                                style: AppText.title.copyWith(
                                                    fontSize: 20,
                                                    color: AppC.white
                                                        .withOpacity(0.8)),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black.withOpacity(0.6),
                                        thickness: 1,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/weather/max_temp.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${weather.tempMax} °C',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 20,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/weather/min_temp.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${weather.tempMin} °C',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 20,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/weather/windspeed.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${weather.windSpeed} m/s',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 20,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/weather/pressure.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${weather.pressure} hPa',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 20,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/weather/cloud.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${weather.clouds}%',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 20,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/weather/rainVolume.png',
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  '${weather.rainVolume} mm',
                                                  style: AppText.title.copyWith(
                                                      fontSize: 20,
                                                      color: AppC.white
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<List<Weather>>(
                      future: _weatherFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No weather data available',
                                  style: AppText.title2));
                        } else {
                          List<Weather> weatherList = snapshot.data!;

                          var groupedWeather = groupBy(
                              weatherList,
                              (Weather w) => w.dateTime
                                  .toLocal()
                                  .toIso8601String()
                                  .substring(0, 10));

                          var todayDate = DateTime.now()
                              .toLocal()
                              .toIso8601String()
                              .substring(0, 10);

                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: groupedWeather.entries.map((entry) {
                                String date = entry.key;
                                List<Weather> weathers = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    todayDate == date
                                        ? Text('Today', style: AppText.title2)
                                        : Text(
                                            getFullDate(DateTime.parse(date)),
                                            style: AppText.title2),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: weathers
                                            .map((weather) =>
                                                _buildWeatherCard(weather))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWeatherCard(Weather weather) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(getTime(weather.dateTime), style: AppText.text2),
            Image.asset('assets/weather/${weather.icon}.png',
                width: 50, height: 50),
            Text('${weather.temperature}°C', style: TextStyle(fontSize: 16)),
            Text('${weather.main} - ${weather.description}', style: TextStyle(fontSize: 16)),
            Text('Max: ${weather.tempMax}°C', style: TextStyle(fontSize: 16)),
            Text('Min: ${weather.tempMin}°C', style: TextStyle(fontSize: 16)),
            Text('Wind Speed: ${weather.windSpeed} m/s',
                style: TextStyle(fontSize: 16)),
            Text('Humidity: ${weather.humidity}%',
                style: TextStyle(fontSize: 16)),
            Text('Pressure: ${weather.pressure} hPa',
                style: TextStyle(fontSize: 16)),
            Text('Clouds: ${weather.clouds}%', style: TextStyle(fontSize: 16)),
            Text('Rain Volume: ${weather.rainVolume} mm',style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
