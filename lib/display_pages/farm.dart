// ignore_for_file: use_build_context_synchronously

import 'package:aig/API/disease_recognition.dart';
import 'package:aig/update_pages/farm.dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aig/theme.dart';
import 'package:aig/API/database.dart';

class FarmProfileDetailPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String colName;
  final String userId;

  const FarmProfileDetailPage({
    super.key,
    required this.profile,
    required this.colName,
    required this.userId,
  });

  @override
  State<FarmProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<FarmProfileDetailPage> {
  // Success message from update pages
  String? _message;

  // Current profile data
  late Map<String, dynamic> profile;

  @override
  void initState() {
    super.initState();
    profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    // padding
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.05;
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
            title: Text('Profile Details', style: AppText.title),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_message != null) ...[
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                child: Container(
                  color: AppC.gold,
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppC.green2,
                        size: 30.0,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _message!,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: AppC.green2,
                              fontWeight: FontWeight.normal,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: paddingWidth,
                vertical: paddingHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        profile['Url'] ?? '',
                        height: 200,
                        width: 165.2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateFarmProfilePage(
                                colName: widget.colName,
                                docId: profile['id'],
                                userId: widget.userId,
                              ),
                            ),
                          ).then((result) {
                            if (result != null) {
                              setState(() {
                                _message = result;
                              });
                              refreshData();
                              Future.delayed(Duration(seconds: 5), () {
                                if (mounted) {
                                  setState(() {
                                    _message = null;
                                  });
                                }
                              });
                            }
                          });
                        },
                        style: AppButton.buttonStyleUpdate,
                        child: Text(
                          'Update',
                          style: AppText.button,
                        ),
                      ),
                      SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: () {
                          deleteConfirmation(context);
                        },
                        style: AppButton.buttonStyleDelete,
                        child: Text(
                          'Delete',
                          style: AppText.button,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiseaseRecognition(),
                        ),
                      );
                    },
                    style: AppButton.buttonStyleBlack,
                    child: Text(
                      'Recognition',
                      style: AppText.button,
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name', style: AppText.title2),
                        SizedBox(height: 10),
                        Container(
                          height: 50,
                          width: 300,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: AppBoxDecoration.box,
                          child: Text(
                            profile['Name'] ?? 'No Name',
                            style: AppText.text,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Stock Status', style: AppText.title2),
                        SizedBox(height: 10),
                        Container(
                          height: 50,
                          width: 300,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: AppBoxDecoration.box,
                          child: Row(
                            children: [
                              Icon(
                                profile['Status'] == 1
                                    ? Icons.eco
                                    : Icons.warning,
                                color: profile['Status'] == 1
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              SizedBox(width: 5.0),
                              Text(
                                profile['Status'] == 1
                                    ? 'Healthy'
                                    : 'Disease',
                                style: profile['Status'] == 1
                                    ? AppText.status2
                                    : AppText.status1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Description', style: AppText.title2),
                        SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          constraints: AppBoxDecoration.boxConstraints,
                          decoration: AppBoxDecoration.box,
                          child: Text(
                            profile['Description'] ?? 'No Description',
                            style: AppText.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this profile?'),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                  child: Text('Cancel'),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    _deleteProfile(context);
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteProfile(BuildContext context) async {
    final Database db = Database();
    await db.delete(widget.colName, profile['id'], widget.userId);
    Navigator.of(context).pop(); // Dismiss the confirmation dialog
    Navigator.of(context).pop(); // Go back to the previous page
  }

  Future<void> refreshData() async {
    final Database db = Database();
    DocumentSnapshot profileSnapshot =
        await db.retrieve_update(widget.colName, profile['id'], widget.userId);
    if (mounted) {
      setState(() {
        profile = {
          ...profileSnapshot.data() as Map<String, dynamic>,
          'id': profile['id']
        };
      });
    }
  }
}
