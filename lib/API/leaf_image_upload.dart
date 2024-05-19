// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:aig/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class LeafImageUpload extends StatefulWidget {
  const LeafImageUpload({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<LeafImageUpload> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final _storage = FirebaseStorage.instance.ref();
  bool isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      isLoading = true;
    });

    final String fileName = _image!.path.split('/').last;
    final Reference storageRef = _storage.child('leaves/$fileName');
    final UploadTask uploadTask = storageRef.putFile(_image!);

    final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() {});
    final String url = await downloadUrl.ref.getDownloadURL();

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, url);
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
      body: Stack(children: [
        Container(
          color: AppC.bgdWhite,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? Text('No image selected.', style: AppText.text)
                    : Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text('Upload Image'),
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
