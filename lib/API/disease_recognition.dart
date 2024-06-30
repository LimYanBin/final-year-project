// ignore_for_file: use_build_context_synchronously

import 'package:aig/API/database.dart';
import 'package:aig/disease/report.dart';
import 'package:flutter/material.dart';
import 'package:aig/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tflite/tflite.dart';

class DiseaseRecognition extends StatefulWidget {
  final String uId;
  final String farmId;
  final int modelId;
  final String plant;
  const DiseaseRecognition(
      {super.key,
      required this.uId,
      required this.farmId,
      required this.modelId,
      required this.plant});

  @override
  State<DiseaseRecognition> createState() => _DiseaseRecognitionState();
}

class _DiseaseRecognitionState extends State<DiseaseRecognition> {
  Database db = Database();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isUploaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // Load Model
  Future<void> loadModel() async {
    if (widget.modelId == 1) {
      await Tflite.loadModel(
        model: 'assets/model/Potato.tflite',
        labels: 'assets/model/potato_labels.txt',
      );
    } else if (widget.modelId == 2) {
      await Tflite.loadModel(
        model: 'assets/model/Strawberry.tflite',
        labels: 'assets/model/strawberry_labels.txt',
      );
    } else if (widget.modelId == 3) {
      await Tflite.loadModel(
        model: 'assets/model/Tomato.tflite',
        labels: 'assets/model/tomato_labels.txt',
      );
    }
  }

  // Camera
  Future<void> _takePicture() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isUploaded = true;
      });
    }
  }

  // Albums
  Future<void> _uploadFromAlbums() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isUploaded = true;
      });
    }
  }

  Future<void> classifyImage(XFile image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    String result = recognitions?.isNotEmpty == true
        ? recognitions![0]["label"]
        : "Unknown";

    if (result != 'Unknown' && result != 'Healthy') {
      final data = <String, dynamic>{
        'Status': 0,
      };
      await db.update('farm', widget.farmId, data, widget.uId);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TreatmentPage(
                userId: widget.uId,
                diseaseName: result,
                plantName: widget.plant,
                farmId: widget.farmId,
                )),
      );
    } else {
      if (result == 'Healthy') {
        final data = <String, dynamic>{
          'Status': 1,
        };
        await db.update('farm', widget.farmId, data, widget.uId);
      }
      Navigator.pop(context, 'The plant is $result');
    }
  }

  // Submit
  void _submit(XFile imageFile) {
    classifyImage(imageFile);
    setState(() {
      _imageFile = null;
      _isUploaded = false;
    });
  }

  // Cancel
  void _cancel() {
    setState(() {
      _imageFile = null;
      _isUploaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double paddingWidth = screenWidth * 0.05;
    double paddingHeight = screenHeight * 0.05;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
          child: AppBar(
            title: Text(
              'Upload Leaf Image',
              style: AppText.title,
            ),
            backgroundColor: AppC.dBlue,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingWidth,
              vertical: paddingHeight,
            ),
            child: Center(
              child: _imageFile == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'No Image Captured',
                          style: AppText.text,
                        ),
                      SizedBox(height: 20,),
                      Text('Current Model: ${widget.plant}', style: AppText.warning.copyWith(fontSize: 18),)
                    ],
                  )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Image.file(
                          File(_imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: size.height * 0.6,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (!_isUploaded && _imageFile == null) ...[
                  ElevatedButton(
                    style: AppButton.ele,
                    onPressed: _takePicture,
                    child: Text(
                      'Capture Image Using Camera',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: AppButton.ele,
                    onPressed: _uploadFromAlbums,
                    child: Text(
                      'Upload from albums',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
                if (_isUploaded && _imageFile != null) ...[
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: AppButton.ele,
                    onPressed: () => _submit(_imageFile!),
                    child: Text(
                      'Start Recognition Process',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: AppButton.ele,
                    onPressed: _cancel,
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
