// ignore_for_file: avoid_print

import 'package:aig/API/database.dart';
import 'package:aig/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TreatmentPage extends StatefulWidget {
  final String userId;
  final String diseaseName;
  final String plantName;
  final String farmId;
  const TreatmentPage(
      {super.key,
      required this.userId,
      required this.diseaseName,
      required this.plantName,
      required this.farmId});

  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage> {
  // Database
  Database db = Database();

  // Variables
  late String plantName = widget.plantName;
  late String diseaseName = widget.diseaseName;
  late String userId = widget.userId;
  late String farmId = widget.farmId;
  String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
  late Map<String, dynamic> _data;

  String? description;
  String? reason;
  String? treatment;

  // Loading
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDiseaseData();
  }

  Future<void> loadDiseaseData() async {
    setState(() {
      isLoading = true;
    });

    final snapshot = await db.retrieve_disease(userId, plantName);
    final data = snapshot.data() as Map<String, dynamic>;
    final diseaseData = data[diseaseName] as Map<String, dynamic>;

    if (mounted) {
      setState(() {
        description = diseaseData['Description'];
        reason = diseaseData['Reason'];
        treatment = diseaseData['Treatment'];
        _data = diseaseData;
      });
    }
    
    db.storeHistory(userId, plantName,diseaseName, farmId, date, _data, 'Disease History');

    setState(() {
      isLoading = false;
    });
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
              'Recognition Report',
              style: AppText.title,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  'Plant Name',
                  style: AppText.title2,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  constraints: AppBoxDecoration.boxConstraints3,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: AppBoxDecoration.box3,
                  child: Text(
                    plantName,
                    style: AppText.text,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Disease Name',
                  style: AppText.title2,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  constraints: AppBoxDecoration.boxConstraints3,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: AppBoxDecoration.box3,
                  child: Text(
                    diseaseName,
                    style: AppText.text,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Disease Desciption',
                  style: AppText.title2,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  constraints: AppBoxDecoration.boxConstraints3,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: AppBoxDecoration.box3,
                  child: Text(
                    description ?? 'No description available',
                    style: AppText.text,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Cause of Infection',
                  style: AppText.title2,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  constraints: AppBoxDecoration.boxConstraints3,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: AppBoxDecoration.box3,
                  child: Text(
                    reason ?? 'No reason available',
                    style: AppText.text,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Treatment',
                  style: AppText.title2,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  constraints: AppBoxDecoration.boxConstraints3,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: AppBoxDecoration.box3,
                  child: Text(
                    treatment ?? 'No treatment available',
                    style: AppText.text,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ]),
    );
  }
}
