// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aig/API/database.dart';
import 'package:aig/API/image_upload.dart';
import 'package:aig/theme.dart';

class UpdateFarmProfilePage extends StatefulWidget {
  final String docId;
  final String colName;
  const UpdateFarmProfilePage(
      {super.key, required this.docId, required this.colName});

  @override
  State<UpdateFarmProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateFarmProfilePage> {
  //database
  final Database db = Database();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController desController = TextEditingController();

  //Variables to store the data
  int? status;
  String? _status;
  String? name;
  String? description;
  String? imageUrl;

  //Loading
  bool isLoading = false;

  @override
    void dispose() {
      nameController.dispose();
      desController.dispose();
      super.dispose();
    }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    DocumentSnapshot profile =
        await db.retrieve_update(widget.colName, widget.docId);
    setState(() {
      nameController.text = profile['Name'];
      desController.text = profile['Description'];
      status = profile['Status'];
      imageUrl = profile['Url'];
    });
  }

  Future<void> updateUserData() async {
    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{
        "Name": nameController.text,
        "Description": desController.text,
        'Url': imageUrl,
        'Status': getStatusValue(),
      };
      await db.update(widget.colName, widget.docId, data);
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, 'Profile successfully updated');
  }

    int getStatusValue() {
    if (_status == 'Available') {
      return status = 1;
    } else if (_status == 'Out of Stock') {
      return  status = 0;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    //Padding
    double screenWidth = MediaQuery.of(context).size.width;
    double paddingValue = screenWidth * 0.1;

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
            title: Text('Update Profile'),
          ),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: imageUrl == null
                        ? Text('No image uploaded')
                        : Container(
                            width: 165.2,
                            height: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                )),
                          ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => ImageUploadPage()),
                        );
              
                        if (result != null) {
                            setState(() {
                              imageUrl = result;
                            });
                          }
                      },
                      style: AppButton.buttonStyleBlack,
                      child: Text('Edit Profile Image', style: AppText.button)),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Name', style: AppText.title2,)),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppC.white,
                        border: OutlineInputBorder(),
                        hintText: 'Enter Name',
                        counterText: '',
                      ),
                      validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description cannot be empty';
                          }
                          return null;
                        },
                      maxLength: 30,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Description', style: AppText.title2,)),
                    SizedBox(
                      height: 200,
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        controller: desController,
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
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Select Status', style: AppText.title2,)),
                    Container(
                    decoration: BoxDecoration(
                      color: AppC.white,
                      border: Border.all(color: AppC.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text('Disease', style: AppText.status1),
                          value: 'Disease',
                          groupValue: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Healthy', style: AppText.status2),
                          value: 'Healthy',
                          groupValue: _status,
                          onChanged: (value) {
                            setState(() {
                              _status = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton(
                      onPressed: () {
                        updateUserData();
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
      ]),
    );
  }
}
