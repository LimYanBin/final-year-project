import 'package:aig/theme.dart';
import 'package:flutter/material.dart';

class AIHistory extends StatefulWidget {
  final Map<String, dynamic> history;
  const AIHistory({super.key, required this.history});

  @override
  State<AIHistory> createState() => _AIHistoryState();
}

class _AIHistoryState extends State<AIHistory> {
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
                'AI History',
                style: AppText.title,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
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
                          history['Date'],
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
                          history['Time'],
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
                            ...(data['Irrigation'] != null &&
                                    data['Irrigation']!.isNotEmpty
                                ? data['Irrigation']!.map(
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
                            ...(data['Fertilizer'] != null &&
                                    data['Irrigation']!.isNotEmpty
                                ? data['Fertilizer']!.map(
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
                            ...(data['Pesticide'] != null &&
                                    data['Irrigation']!.isNotEmpty
                                ? data['Pesticide']!.map(
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