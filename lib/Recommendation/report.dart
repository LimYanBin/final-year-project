import 'package:aig/API/database.dart';
import 'package:aig/API/weather_services.dart';
import 'package:aig/recommendation/engine.dart';
import 'package:aig/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecommendationPage extends StatefulWidget {
  final String uId;
  final String farmId;
  const RecommendationPage(
      {super.key, required this.uId, required this.farmId});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final Database db = Database();
  final AIEngine engine = AIEngine();
  final GeocodingService _geocodingService = GeocodingService();

  //Variables
  String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String time = DateFormat('HH:mm').format(DateTime.now());
  String? selectedAddress;
  List<Map<String, String>> farms = [];
  Map<String, List<String>> recommendations = {};
  late String userId = widget.uId;
  late String farmId = widget.farmId;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFarm();
  }

  Future<void> loadFarm() async {
    setState(() {
      isLoading = true;
    });

    Map<String, String> retrievedFarms =
        await db.getAFarms(widget.uId, widget.farmId);

    setState(() {
      farms = [retrievedFarms];
      if (farms.isNotEmpty) {
        selectedAddress = farms[0]['address'];
      }
    });

    if (selectedAddress != null) {
      await fetchWeather();
    }

    db.storeAIHistory(userId, farmId, date, time, recommendations, 'AI History');

    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchWeather() async {
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

      var newRecommendations = await engine.recommendOperations(lat, lng);

      setState(() {
        recommendations = newRecommendations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.10;
    double paddingHeight = screenHeight * 0.05;

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
                'AI Recommendation',
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
                    horizontal: paddingWidth,
                    vertical: paddingHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: AppText.title2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        constraints: AppBoxDecoration.boxConstraints3,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: AppBoxDecoration.box3,
                        child: Text(
                          date,
                          style: AppText.text,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Time',
                        style: AppText.title2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        constraints: AppBoxDecoration.boxConstraints3,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: AppBoxDecoration.box3,
                        child: Text(
                          time,
                          style: AppText.text,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Operation Recommendation',
                        style: AppText.title2,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        constraints: AppBoxDecoration.boxConstraints3,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: AppBoxDecoration.box3,
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suitable time for irrigation:',
                              style: AppText.title3,
                            ),
                            ...(recommendations['Irrigation'] != null &&
                                    recommendations['Irrigation']!.isNotEmpty
                                ? recommendations['Irrigation']!.map(
                                    (time) => Text(time, style: AppText.text))
                                : [
                                    Text('No Recommended Time',
                                        style: AppText.text)
                                  ]),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Suitable time to apply fertilizer:',
                              style: AppText.title3,
                            ),
                            ...(recommendations['Fertilizer'] != null &&
                                    recommendations['Irrigation']!.isNotEmpty
                                ? recommendations['Fertilizer']!.map(
                                    (time) => Text(time, style: AppText.text))
                                : [
                                    Text('No Recommended Time',
                                        style: AppText.text)
                                  ]),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Suitable time to give pesticide:',
                              style: AppText.title3,
                            ),
                            ...(recommendations['Pesticide'] != null &&
                                    recommendations['Irrigation']!.isNotEmpty
                                ? recommendations['Pesticide']!.map(
                                    (time) => Text(time, style: AppText.text))
                                : [
                                    Text('No Recommended Time',
                                        style: AppText.text)
                                  ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
