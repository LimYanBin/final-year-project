// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:async';

import 'package:aig/API/database.dart';
import 'package:aig/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DiseaseDetailPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String userId;
  final String diseaseName;

  const DiseaseDetailPage({
    super.key,
    required this.profile,
    required this.userId,
    required this.diseaseName,
  });

  @override
  State<DiseaseDetailPage> createState() => _DiseaseDetailPageState();
}

class _DiseaseDetailPageState extends State<DiseaseDetailPage> {
  Database db = Database();

  // Variables
  late String name = widget.profile['id'];
  late String diseaseName = widget.diseaseName;
  late String userId = widget.userId;

  // Loading
  bool isLoading = false;
  String? _message;
  Timer? _messageClearTimer;

  // Current profile data
  late Map<String, dynamic> profile = widget.profile;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _reasonController.dispose();
    _treatmentController.dispose();
    _scrollController.dispose();
    _messageClearTimer?.cancel();
    super.dispose();
  }

  Future<void> loadUserData() async {
    final snapshot = await db.retrieve_disease(userId, name);
    final data = snapshot.data() as Map<String, dynamic>;
    final diseaseData = data[widget.diseaseName] as Map<String, dynamic>;

    if (mounted) {
      setState(() {
        _descriptionController.text = diseaseData['Description'];
        _reasonController.text = diseaseData['Reason'];
        _treatmentController.text = diseaseData['Treatment'];
      });
    }
  }

  Future<void> updateDiseaseData() async {
    setState(() {
      isLoading = true;
    });

    final data = {
      diseaseName: {
        "Description": _descriptionController.text,
        "Reason": _reasonController.text,
        "Treatment": _treatmentController.text
      }
    };

    try {
      await db.updateDisease(data, userId, name);

      setState(() {
        _message = 'Disease details updated';
      });

      _messageClearTimer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error updating data';
      });
    } finally {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> reset() async {
    setState(() {
      isLoading = true;
    });
    final doc = await db.reset_disease(name);

    final data = {diseaseName: doc[diseaseName]};


    try {
      await db.updateDisease(data, userId, name);
      await loadUserData();

      setState(() {
        _message = 'Disease details resetted';
      });

      _messageClearTimer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _message = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error resetting data';
      });
    } finally {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeOut,
      );

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop(); 
    }
  }

  void deleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Confirmation'),
          content: Text('Are you sure you want to reset this disease details?'),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                  child: Text('Cancel'),
                ),
                Spacer(flex: 1),
                TextButton(
                  onPressed: () {
                    reset();
                    _messageClearTimer = Timer(Duration(seconds: 5), () {
                      if (mounted) {
                        setState(() {
                          _message = null;
                        });
                      }
                    });
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

  @override
  Widget build(BuildContext context) {
    // Padding
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
            title: Text('Edit Disease Detail'),
            actions: [
              IconButton(
                  icon: Icon(Icons.restore),
                  onPressed: () {
                    deleteConfirmation(context);
                  }),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingWidth, vertical: paddingHeight),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_message != null) ...[
                      SizedBox(height: 10),
                      Container(
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
                      SizedBox(height: 10),
                    ],
                    Text('Name', style: AppText.title2),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      width: 300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: AppBoxDecoration.box3,
                      child: Text(
                        name,
                        style: AppText.text,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Disease Name', style: AppText.title2),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      width: 300,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: AppBoxDecoration.box3,
                      child: Text(
                        diseaseName,
                        style: AppText.text,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Description', style: AppText.title2),
                    SizedBox(height: 10),
                    Container(
                      constraints: AppBoxDecoration.boxConstraints,
                      child: TextFormField(
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppC.white,
                          border: OutlineInputBorder(),
                          hintText: 'Enter Description',
                          contentPadding: EdgeInsets.fromLTRB(14, 18, 10, 0),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Reason', style: AppText.title2),
                    SizedBox(height: 10),
                    Container(
                      constraints: AppBoxDecoration.boxConstraints,
                      child: TextFormField(
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        controller: _reasonController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppC.white,
                          border: OutlineInputBorder(),
                          hintText: 'Enter Reason',
                          contentPadding: EdgeInsets.fromLTRB(14, 18, 10, 0),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Reason cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Treatment', style: AppText.title2),
                    SizedBox(height: 10),
                    Container(
                      constraints: AppBoxDecoration.boxConstraints,
                      child: TextFormField(
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        controller: _treatmentController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppC.white,
                          border: OutlineInputBorder(),
                          hintText: 'Enter Treatment',
                          contentPadding: EdgeInsets.fromLTRB(14, 18, 10, 0),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Treatment cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateDiseaseData();
                            _messageClearTimer =
                                Timer(Duration(seconds: 5), () {
                              if (mounted) {
                                setState(() {
                                  _message = null;
                                });
                              }
                            });
                          }
                        },
                        style: AppButton.buttonStyleCreate,
                        child: Text(
                          'Save',
                          style: AppText.button,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
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
        ],
      ),
    );
  }
}
