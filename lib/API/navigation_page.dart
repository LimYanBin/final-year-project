// ignore_for_file: avoid_print, deprecated_member_use

import 'package:aig/theme.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationPage extends StatefulWidget {
  final String destination;

  NavigationPage({super.key, required this.destination});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  LatLng? _destinationLatLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getDestinationCoordinates(widget.destination);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _getDestinationCoordinates(String destination) async {
    try {
      List<Location> locations = await locationFromAddress(destination);
      if (locations.isNotEmpty) {
        setState(() {
          _destinationLatLng =
              LatLng(locations.first.latitude, locations.first.longitude);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _launchGoogleMaps() async {
    if (_currentPosition != null && _destinationLatLng != null) {
      String url =
          'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}&travelmode=driving';
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text('Navigate to farm'),
          ),
        ),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 14.0,
                    ),
                    markers: {
                      if (_currentPosition != null)
                        Marker(
                          markerId: MarkerId('currentLocation'),
                          position: LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                          infoWindow: InfoWindow(title: 'Current Location'),
                        ),
                      if (_destinationLatLng != null)
                        Marker(
                          markerId: MarkerId('destination'),
                          position: _destinationLatLng!,
                          infoWindow: InfoWindow(title: 'Destination'),
                        ),
                    },
                    polylines: {
                      if (_destinationLatLng != null)
                        Polyline(
                          polylineId: PolylineId('route'),
                          points: [
                            LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            _destinationLatLng!
                          ],
                          color: Colors.blue,
                        ),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton(
                    style: AppButton.buttonStyleFarm,
                    onPressed: _launchGoogleMaps,
                    child: Text(
                      'Start Navigation',
                      style: AppText.title2,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
