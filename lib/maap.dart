import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "package:map/homescreen.dart";
import 'package:map/transactions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  String user;
  LatLng start;
  MapScreen({super.key, required this.start, required this.user});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Future<List<LatLng>>? _latLngData;
  @override
  void initState() {
    super.initState();
    _latLngData = fetchLatLngData();
  }

  Future<List<LatLng>> fetchLatLngData() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2/sql_test/test.php'));
    // await http.get(Uri.parse('http://192.168.157.142/sql_test/test_1.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<LatLng> latLngList = data.map((item) {
        double latitude = double.parse(item['latitude']);
        double longitude = double.parse(item['longitude']);
        return LatLng(latitude, longitude);
      }).toList();
      return latLngList;
    } else {
      throw Exception('Failed to fetch data from the API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby FPS'),
      ),
      body: FutureBuilder<List<LatLng>>(
        future: _latLngData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          } else {
            // Display the map
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.start, // Set the initial position of the map
                zoom: 12.0,
              ),
              markers: Set<Marker>.from(snapshot.data!.map((latLng) {
                return Marker(
                  markerId: MarkerId(latLng.toString()),
                  onTap: () async {
                    String url =
                        "https://www.google.com/maps/dir/?api=1&origin=${widget.start.latitude},${widget.start.longitude}&destination=${latLng.latitude},${latLng.longitude}";

                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      // Handle if the user doesn't have Google Maps installed or an error occurs.
                      print("Error opening Google Maps.");
                    }
                  },
                  position: latLng,
                );
              })),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_pin,
            ),
            label: 'Nearby-FPS',
            tooltip: 'Nearby-FPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.format_list_bulleted_rounded,
            ),
            label: 'Transactions',
            tooltip: 'Transactions',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => ));
              // Navigate to Home page
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        start: widget.start,
                        user: widget.user,
                      )));
              break;
            case 1:
              // Navigate to Search page
              break;
            case 2:
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Transactions(
                        user: widget.user,
                        start: widget.start,
                      )));

              // Navigate to Settings page
              break;
          }
        },
      ),
    );
  }
}
