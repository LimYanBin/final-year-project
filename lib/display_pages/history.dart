import 'package:aig/theme.dart';
import 'package:flutter/material.dart';

class DiseaseHistory extends StatefulWidget {
  final Map<String, dynamic> history;
  const DiseaseHistory({super.key, required this.history});

  @override
  State<DiseaseHistory> createState() => _DiseaseHistoryState();
}

class _DiseaseHistoryState extends State<DiseaseHistory> {
  //variables
  late Map<String, dynamic> history = widget.history;
  late Map<String, dynamic> data = widget.history['Data'];

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
              'Report History',
              style: AppText.title,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
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
                    history['Date'],
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
                    history['Plant'],
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
                    history['Disease Name'],
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
                    data['Description'],
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
                    data['Reason'],
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
                    data['Treatment'],
                    style: AppText.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}