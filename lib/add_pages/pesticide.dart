// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aig/API/database.dart';
import 'package:aig/theme.dart';
import 'package:aig/API/image_upload.dart';

class AddPesticide extends StatefulWidget {
  final String userId;
  const AddPesticide({super.key, required this.userId});

  @override
  State<AddPesticide> createState() => _PesticidePageState();
}

class _PesticidePageState extends State<AddPesticide> {
  Database db = Database();
  final TextEditingController controller = TextEditingController();

  //Variables to store the data
  int? status = -1;
  String? name;
  String? description;

  //Variables to keep track of empty text fields
  bool _nameError = false;
  bool _descriptionError = false;
  bool _statusError = false;

  //Image
  String? uploadedImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/finalyearproject-cd51e.appspot.com/o/default%2Fdefault.jpg?alt=media&token=9c0d26eb-a908-4164-9126-acce4c74e063';

  //Loading
  bool isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // Method to validate input fields
  bool validateInputs() {
    setState(() {
      _nameError = (name == null || name!.isEmpty);
      _descriptionError = (description == null || description!.isEmpty);
      _statusError = (status == null || status!.isNegative);
    });
    return !_nameError && !_descriptionError && !_statusError;
  }

  Future<void> create() async {
    setState(() {
      isLoading = true;
    });

    await db.create_pesticide(
        name!, description!, uploadedImageUrl!, status!, widget.userId);

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, 'Profile successfully created');
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
            title: Text(
              'Add Pesticide',
              style: AppText.title,
            ),
            backgroundColor: AppC.dBlue,
          ),
        ),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Center(
                  child: uploadedImageUrl == null
                      ? Text('No image uploaded')
                      : Container(
                          width: 165.2,
                          height: 200,
                          decoration: BoxDecoration(
                              //border: Border.all(),
                              borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                uploadedImageUrl!,
                                fit: BoxFit.cover,
                              ))),
                ),
                SizedBox(height: 20),
                Center(
                  child: OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageUploadPage()),
                        );

                        if (result != null) {
                          setState(() {
                            uploadedImageUrl = result;
                          });
                        }
                      },
                      style: AppButton.buttonStyleBlack,
                      child: Text('Edit Profile Image', style: AppText.button)),
                ),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name',
                      style: AppText.title2,
                    )),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppC.white,
                      border: OutlineInputBorder(),
                      hintText: 'Enter Name',
                      errorText: _nameError ? 'Name cannot be empty' : null,
                      counterText: '',
                    ),
                    maxLength: 30,
                    inputFormatters: [LengthLimitingTextInputFormatter(30)],
                    onChanged: (value) {
                      name = value;
                    },
                  ),
                ),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Description',
                      style: AppText.title2,
                    )),
                SizedBox(
                  height: 200,
                  child: TextFormField(
                    expands: true,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppC.white,
                      border: OutlineInputBorder(),
                      hintText: 'Enter Description',
                      contentPadding: EdgeInsets.fromLTRB(14, 18, 10, 0),
                      alignLabelWithHint: true,
                      errorText: _descriptionError
                          ? 'Description cannot be empty'
                          : null,
                    ),
                    onChanged: (value) {
                      description = value;
                    },
                  ),
                ),
                SizedBox(height: 30),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Status',
                      style: AppText.title2,
                    )),
                Container(
                  decoration: BoxDecoration(
                    color: AppC.white,
                    border: Border.all(color: AppC.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Column(
                    children: [
                      CustomRadioListTile<int>(
                        title: Text('Out of Stock', style: AppText.status1),
                        value: 0,
                        groupValue: status,
                        showError: _statusError,
                        onChanged: (value) {
                          setState(() {
                            status = value;
                            _statusError = false;
                          });
                        },
                      ),
                      CustomRadioListTile<int>(
                        title: Text('Available', style: AppText.status2),
                        value: 1,
                        groupValue: status,
                        showError: _statusError,
                        onChanged: (value) {
                          setState(() {
                            status = value;
                            _statusError = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (_statusError)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Text('Please select a status',
                          style: AppText.warning),
                    ),
                  ),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    onPressed: () {
                      if (validateInputs()) create();
                    },
                    style: AppButton.buttonStyleCreate,
                    child: Text(
                      'Create',
                      style: AppText.button,
                    ),
                  ),
                ),
                SizedBox(height: 50),
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
