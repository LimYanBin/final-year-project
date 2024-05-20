// ignore_for_file: avoid_print

import 'dart:io';
import 'package:aig/theme.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class DiseaseRecognition extends StatefulWidget {
  const DiseaseRecognition({super.key});

  @override
  State<DiseaseRecognition> createState() => _DiseaseRecognitionState();
}

class _DiseaseRecognitionState extends State<DiseaseRecognition> {
  final picker = ImagePicker();
  XFile? _image;
  String? _result;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model/Potato.tflite',
      labels: 'assets/model/potato_labels.txt',
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile;
    });
    classifyImage(pickedFile!);
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
    setState(() {
      _result = recognitions?.isNotEmpty == true
          ? recognitions![0]["label"]
          : "Unknown";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
          child: AppBar(
            title: Text(
              'Select Leaf Image',
              style: AppText.title,
            ),
            backgroundColor: AppC.dBlue,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text('No image selected.')
                : Image.file(File(_image!.path)),
            SizedBox(height: 16.0),
            _result == null ? Text('') : Text('Result: $_result'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}
