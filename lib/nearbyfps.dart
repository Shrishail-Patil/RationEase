import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/homescreen.dart';
import "package:url_launcher/url_launcher.dart";
import 'package:map/transactions.dart';

class ItemList extends StatefulWidget {
  String user;
  List markers;
  final LatLng start;

  ItemList(
      {super.key,
      required this.start,
      required this.markers,
      required this.user});
  @override
  _ItemList createState() => _ItemList();
}

class _ItemList extends State<ItemList> {
  GoogleMapController? mapController;
  List<Marker> _markers = [];
  @override
  void initState() {
    print(widget.markers);
    _addMarkers();
    super.initState();
  }

  void _addMarkers() {
    for (LatLng coordinate in widget.markers) {
      int i = 0;
      _markers.add(
        Marker(
          markerId: MarkerId('marker$i'),
          position: coordinate,
          onTap: () async {
            String url =
                "https://www.google.com/maps/dir/?api=1&origin=${widget.start.latitude},${widget.start.longitude}&destination=${coordinate.latitude},${coordinate.longitude}";

            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              // Handle if the user doesn't have Google Maps installed or an error occurs.
              print("Error opening Google Maps.");
            }
          },
        ),
      );
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    _addMarkers();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: GoogleMap(
        zoomGesturesEnabled: true,
        initialCameraPosition: CameraPosition(
          target: widget.start, // Initial map location
          zoom: 12.0,
        ),
        markers: Set<Marker>.from(_markers),
        onMapCreated: (GoogleMapController controller) {
          //method called when map is created
          setState(() {
            mapController = controller;
          });
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
