import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/homescreen.dart';
// import 'dart:math';

class Home extends StatefulWidget {
  final String user;
  const Home({super.key, required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Location location = Location();
  LatLng? start;

  @override
  void initState() {
    _checkLocationServiceEnabled();
    super.initState();
  }

  void _checkLocationServiceEnabled() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled.');
      }
    }
    _startLocationUpdates();
  }

  void _startLocationUpdates() async {
    bool locationPermission = await _requestLocationPermission();
    if (locationPermission) {
      LocationData locationData = await location.getLocation();
      setState(() {
        String a = "${locationData.latitude},${locationData.longitude}";
        List b = a.split(",");
        start = LatLng(locationData == null ? 0.0 : double.tryParse(b[0])!,
            locationData == null ? 0.0 : double.tryParse(b[1])!);
      });
      print(start);
    } else {
      print('Location permission denied.');
    }
  }

  Future<bool> _requestLocationPermission() async {
    PermissionStatus permission = await location.requestPermission();
    return permission == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: start != null
            ? HomeScreen(
                start: start!,
                user: widget.user,
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
