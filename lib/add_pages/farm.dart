// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aig/API/database.dart';
import 'package:aig/theme.dart';
import 'package:aig/API/image_upload.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddFarm extends StatefulWidget {
  final String userId;
  const AddFarm({super.key, required this.userId});

  @override
  State<AddFarm> createState() => _AddFarmState();
}

class _AddFarmState extends State<AddFarm> {
  Database db = Database();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchFerController = TextEditingController();
  final TextEditingController _searchPestController = TextEditingController();

  // Address
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  // Variables to store the data
  int? status = -1;
  String? name;
  String? description;
  String? address;
  int? model = -1;

  // Variables to keep track of empty text fields
  bool _nameError = false;
  bool _descriptionError = false;
  bool _addressError = false;
  bool _statusError = false;
  bool _modelError = false;

  // Image
  String? uploadedImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/finalyearproject-cd51e.appspot.com/o/default%2Fdefault.jpg?alt=media&token=9c0d26eb-a908-4164-9126-acce4c74e063';

  // Loading
  bool isLoading = false;

  // Fertilizer
  List<String> selectedFertilizers = [];
  String searchFer = '';

  // Pesticide
  List<String> selectedPesticides = [];
  String searchPest = '';

  @override
  void dispose() {
    _addressController.dispose();
    _searchFerController.dispose();
    _searchPestController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(3.140853, 101.693207); // Default to Malaysia KL
  }

  // Method to validate input fields
  bool validateInputs() {
    setState(() {
      _nameError = (name == null || name!.isEmpty);
      _descriptionError = (description == null || description!.isEmpty);
      _addressError = (address == null || address!.isEmpty);
      _statusError = (status == null || status!.isNegative);
      _modelError = (model == null || model!.isNegative);
    });
    return !_nameError &&
        !_descriptionError &&
        !_addressError &&
        !_statusError &&
        !_modelError;
  }

  Future<void> create() async {
    if (!validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    await db.create_farm(
      name: name!,
      description: description!,
      address: address!,
      url: uploadedImageUrl!,
      status: status!,
      model: model!,
      fertilizer: selectedFertilizers,
      pesticide: selectedPesticides,
      uId: widget.userId,
    );

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, 'Profile successfully created');
  }

  void _updateAddress(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String newAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        setState(() {
          _addressController.text = newAddress;
          _addressError = false;
          address = newAddress;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _moveCamera(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  Future<void> _updateMapLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng newLocation =
            LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          _selectedLocation = newLocation;
          _moveCamera(newLocation);
        });
      }
    } catch (e) {
      setState(() {
        _addressError = true;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Add Farm',
              style: AppText.title,
            ),
            backgroundColor: AppC.dBlue,
          ),
        ),
      ),
      body: Stack(
        children: [
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
                        child:
                            Text('Edit Profile Image', style: AppText.button)),
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
                        counterText: '',
                        errorText: _nameError ? 'Name cannot be empty' : null,
                      ),
                      maxLength: 30,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      onChanged: (value) {
                        setState(() {
                          _nameError = value.isEmpty;
                          name = value;
                        });
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        alignLabelWithHint: true,
                        errorText: _descriptionError
                            ? 'Description cannot be empty'
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _descriptionError = value.isEmpty;
                          description = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Address',
                        style: AppText.title2,
                      )),
                  SizedBox(
                    height: 100,
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      controller: _addressController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppC.white,
                        border: OutlineInputBorder(),
                        hintText: 'Enter Address',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        alignLabelWithHint: true,
                        errorText: _addressError ? 'Invalid Address' : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _addressError = value.isEmpty;
                          address = value;
                          if (value.isNotEmpty) {
                            _updateMapLocation(value);
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    height: 300,
                    decoration: AppBoxDecoration.mapBox,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onVerticalDragUpdate: (_) {},
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation ??
                                LatLng(3.140853,
                                    101.693207), // Default to Malaysia KL if null
                            zoom: 14,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (_selectedLocation != null) {
                              _moveCamera(_selectedLocation!);
                            }
                          },
                          onTap: (position) {
                            setState(() {
                              _selectedLocation = position;
                              _updateAddress(position);
                            });
                          },
                          markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId: MarkerId('selected-location'),
                                  position: _selectedLocation!,
                                ),
                              }
                            : {},
                          gestureRecognizers: {
                            Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer()),
                            Factory<ScaleGestureRecognizer>(
                                () => ScaleGestureRecognizer()),
                            Factory<TapGestureRecognizer>(
                                () => TapGestureRecognizer()),
                            Factory<VerticalDragGestureRecognizer>(
                                () => VerticalDragGestureRecognizer()),
                          },
                        ),
                      ),
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
                          title: Text('Disease', style: AppText.status1),
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
                          title: Text('Healthy', style: AppText.status2),
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
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Disease Recognition Model',
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
                          title: Text('Potato Model', style: AppText.text),
                          value: 1,
                          groupValue: model,
                          showError: _modelError,
                          onChanged: (value) {
                            setState(() {
                              model = value;
                              _modelError = false;
                            });
                          },
                        ),
                        CustomRadioListTile<int>(
                          title: Text('Strawberry Model', style: AppText.text),
                          value: 2,
                          groupValue: model,
                          showError: _modelError,
                          onChanged: (value) {
                            setState(() {
                              model = value;
                              _modelError = false;
                            });
                          },
                        ),
                        CustomRadioListTile<int>(
                          title: Text('Tomato Model', style: AppText.text),
                          value: 3,
                          groupValue: model,
                          showError: _modelError,
                          onChanged: (value) {
                            setState(() {
                              model = value;
                              _modelError = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_modelError)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Text('Please select a model',
                            style: AppText.warning),
                      ),
                    ),
                  SizedBox(height: 30),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Fertilizer',
                        style: AppText.title2,
                      )),
                  Container(
                    decoration: AppBoxDecoration.box,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Search for Fertilizer
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchFerController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search by name',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onChanged: (value) {
                              setState(() {
                                searchFer = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 180,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: db.retrieve_fertilizer(widget.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                    child: Text('No fertilizers available'));
                              }

                              final fertilizerProfile =
                                  snapshot.data!.docs.where((doc) {
                                final name =
                                    (doc.data() as Map<String, dynamic>)['Name']
                                        .toString()
                                        .toLowerCase();
                                return name.contains(searchFer);
                              }).toList();

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: fertilizerProfile.length,
                                itemBuilder: (context, index) {
                                  final fertilizer = fertilizerProfile[index];
                                  final isSelected = selectedFertilizers
                                      .contains(fertilizer.id);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8),
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.5,
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(
                                                  () {
                                                    if (value == true) {
                                                      selectedFertilizers
                                                          .add(fertilizer.id);
                                                    } else {
                                                      selectedFertilizers
                                                          .remove(
                                                              fertilizer.id);
                                                    }
                                                  },
                                                );
                                              },
                                              activeColor: AppC.lBlue,
                                              checkColor: AppC.dGrey,
                                              side: BorderSide(
                                                  color: AppC.dGrey,
                                                  width: 1.5),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20.0),
                                        Expanded(
                                          child: Text(
                                            fertilizer['Name'],
                                            style: AppText.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Pesticide',
                        style: AppText.title2,
                      )),
                  Container(
                    decoration: AppBoxDecoration.box,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        // Search for Pesticide
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchPestController,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search by name',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onChanged: (value) {
                              setState(() {
                                searchPest = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 180,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: db.retrieve_pesticide(widget.userId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                    child: Text('No pesticides available'));
                              }

                              final pesticideProfile =
                                  snapshot.data!.docs.where((doc) {
                                final name =
                                    (doc.data() as Map<String, dynamic>)['Name']
                                        .toString()
                                        .toLowerCase();
                                return name.contains(searchPest);
                              }).toList();

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: pesticideProfile.length,
                                itemBuilder: (context, index) {
                                  final pesticide = pesticideProfile[index];
                                  final isSelected =
                                      selectedPesticides.contains(pesticide.id);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8),
                                    child: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.5,
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: isSelected,
                                              onChanged: (bool? value) {
                                                setState(
                                                  () {
                                                    if (value == true) {
                                                      selectedPesticides
                                                          .add(pesticide.id);
                                                    } else {
                                                      selectedPesticides
                                                          .remove(pesticide.id);
                                                    }
                                                  },
                                                );
                                              },
                                              activeColor: AppC.lBlue,
                                              checkColor: AppC.dGrey,
                                              side: BorderSide(
                                                  color: AppC.dGrey,
                                                  width: 1.5),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20.0),
                                        Expanded(
                                          child: Text(
                                            pesticide['Name'],
                                            style: AppText.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: OutlinedButton(
                      onPressed: create,
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
        ],
      ),
    );
  }
}
