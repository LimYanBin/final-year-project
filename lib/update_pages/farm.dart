// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:aig/API/database.dart';
import 'package:aig/API/image_upload.dart';
import 'package:aig/theme.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UpdateFarmProfilePage extends StatefulWidget {
  final String docId;
  final String colName;
  final String userId;
  const UpdateFarmProfilePage({
    super.key,
    required this.docId,
    required this.colName,
    required this.userId,
  });

  @override
  State<UpdateFarmProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateFarmProfilePage> {
  // Database
  final Database db = Database();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController _searchFerController = TextEditingController();
  final TextEditingController _searchPestController = TextEditingController();

  // Variables to store the data
  int? status;
  int? model;
  String? name;
  String? description;
  String? imageUrl;
  String? address;
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  List<String> selectedFertilizers = [];
  List<String> selectedPesticides = [];
  String searchFer = '';
  String searchPest = '';

  bool isLoading = false;
  bool _addressError = false;

  @override
  void dispose() {
    nameController.dispose();
    desController.dispose();
    addressController.dispose();
    _searchFerController.dispose();
    _searchPestController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    DocumentSnapshot profile =
        await db.retrieve_update(widget.colName, widget.docId, widget.userId);
    if (mounted) {
      setState(() {
        nameController.text = profile['Name'];
        desController.text = profile['Description'];
        status = profile['Status'];
        model = profile['Model'];
        imageUrl = profile['Url'];
        addressController.text = profile['Address'];
        selectedFertilizers = List<String>.from(profile['Fertilizer'].keys);
        selectedPesticides = List<String>.from(profile['Pesticide'].keys);
        _updateMapLocation(profile['Address']);
      });
    }
  }

  Future<void> updateUserData() async {
  setState(() {
    isLoading = true;
  });

  if (_formKey.currentState!.validate()) {
    // Prepare fertilizers with existing amounts
    Map<String, dynamic> fertilizers = {};
    DocumentSnapshot profile =
        await db.retrieve_update(widget.colName, widget.docId, widget.userId);

    Map<String, dynamic> existingFertilizers = profile['Fertilizer'];
    for (String fert in selectedFertilizers) {
      if (existingFertilizers.containsKey(fert)) {
        fertilizers[fert] = existingFertilizers[fert];
      } else {
        fertilizers[fert] = {'amount': 0};
      }
    }

    // Prepare pesticides with existing amounts
    Map<String, dynamic> pesticides = {};
    Map<String, dynamic> existingPesticides = profile['Pesticide'];
    for (String pest in selectedPesticides) {
      if (existingPesticides.containsKey(pest)) {
        pesticides[pest] = existingPesticides[pest];
      } else {
        pesticides[pest] = {'amount': 0};
      }
    }

    final data = <String, dynamic>{
      "Name": nameController.text,
      "Description": desController.text,
      'Url': imageUrl,
      'Status': status,
      'Model': model,
      'Address': addressController.text,
      'Fertilizer': fertilizers,
      'Pesticide': pesticides,
    };
    await db.update(widget.colName, widget.docId, data, widget.userId);
  }

  if (mounted) {
    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, 'Profile successfully updated');
  }
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
          addressController.text = newAddress;
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
            backgroundColor: AppC.dBlue,
            title: Text('Update Profile'),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingValue),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: imageUrl == null
                          ? Text('No image uploaded')
                          : Container(
                              width: 165.2,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: OutlinedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageUploadPage(),
                            ),
                          );

                          if (result != null && mounted) {
                            setState(() {
                              imageUrl = result;
                            });
                          }
                        },
                        style: AppButton.buttonStyleBlack,
                        child: Text('Edit Profile Image', style: AppText.button),
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Name',
                        style: AppText.title2,
                      ),
                    ),
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
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                      maxLength: 30,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description',
                        style: AppText.title2,
                      ),
                    ),
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
                      child: Text(
                        'Address',
                        style: AppText.title2,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: TextFormField(
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        controller: addressController,
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
                          _addressError = value.isEmpty;
                          setState(() {
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
                                  LatLng(3.140853, 101.693207), // Default to Malaysia KL if null
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
                      ),
                    ),
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
                            showError: false,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  status = value;
                                });
                              }
                            },
                          ),
                          CustomRadioListTile<int>(
                            title: Text('Healthy', style: AppText.status2),
                            value: 1,
                            groupValue: status,
                            showError: false,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  status = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Disease Recognition Model',
                        style: AppText.title2,
                      ),
                    ),
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
                            showError: false,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  model = value;
                                });
                              }
                            },
                          ),
                          CustomRadioListTile<int>(
                            title: Text('Strawberry Model', style: AppText.text),
                            value: 2,
                            groupValue: model,
                            showError: false,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  model = value;
                                });
                              }
                            },
                          ),
                          CustomRadioListTile<int>(
                            title: Text('Tomato Model', style: AppText.text),
                            value: 3,
                            groupValue: model,
                            showError: false,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  model = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Fertilizer',
                        style: AppText.title2,
                      ),
                    ),
                    Container(
                      decoration: AppBoxDecoration.box,
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchFerController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search by name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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

                                final fertilizerProfile = snapshot.data!.docs
                                    .where((doc) {
                                  final name = (doc.data()
                                          as Map<String, dynamic>)['Name']
                                      .toString()
                                      .toLowerCase();
                                  return name.contains(searchFer);
                                }).toList();

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: fertilizerProfile.length,
                                  itemBuilder: (context, index) {
                                    final fertilizer =
                                        fertilizerProfile[index];
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
                                                        selectedFertilizers.add(
                                                            fertilizer.id);
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
                      ),
                    ),
                    Container(
                      decoration: AppBoxDecoration.box,
                      padding: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchPestController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search by name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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

                                final pesticideProfile = snapshot.data!.docs
                                    .where((doc) {
                                  final name = (doc.data()
                                          as Map<String, dynamic>)['Name']
                                      .toString()
                                      .toLowerCase();
                                  return name.contains(searchPest);
                                }).toList();

                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: pesticideProfile.length,
                                  itemBuilder: (context, index) {
                                    final pesticide =
                                        pesticideProfile[index];
                                    final isSelected = selectedPesticides
                                        .contains(pesticide.id);
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
                                                        selectedPesticides.add(
                                                            pesticide.id);
                                                      } else {
                                                        selectedPesticides
                                                            .remove(
                                                                pesticide.id);
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
                    // ... other widgets
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
        ],
      ),
    );
  }
}
