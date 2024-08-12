import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import "package:map/homescreen.dart";
// import 'package:map/transactions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
import "package:map/balance.dart";

class SearchMaps extends StatefulWidget {
  final String user;
  final List items;
  final LatLng start;
  const SearchMaps(
      {super.key,
      required this.start,
      required this.user,
      required this.items});

  @override
  _SearchMapsState createState() => _SearchMapsState();
}

class _SearchMapsState extends State<SearchMaps> {
  Future<List<LatLng>>? _latLngData;
  @override
  void initState() {
    super.initState();
    _latLngData = latlngCoor();
  }

  Future<List<LatLng>> latlngCoor() async {
    String a = '';
    for (int i = 0; i < widget.items.length; i++) {
      if (i != widget.items.length - 1) {
        a += "`${widget.items[i]}`>0 and ";
      } else {
        a += "`${widget.items[i]}`";
      }
    }
    final response = await http.post(
        Uri.parse('http://10.0.2.2/sql_test/test1.php'),
        // await http.post(Uri.parse('http://192.168.1.7/sql_test/test1_1.php'),
        body: {'items': a});

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

  Future<void> navigate(List<dynamic> data1, LatLng latLng) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BalanceDetails(
                  start: widget.start,
                  user: widget.user,
                  end: latLng,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items In Nearest FPS'),
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
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.start,
                zoom: 12.0,
              ),
              markers: Set<Marker>.from(snapshot.data!.map((latLng) {
                return Marker(
                  markerId: MarkerId(latLng.toString()),
                  onTap: () {
                    getDealer(latLng);
                  },
                  position: latLng,
                );
              })),
            );
          }
        },
      ),
    );
  }

  void getDealer(LatLng latLng) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/sql_test/shopDeatails.php'),
      // Uri.parse('http://192.168.1.7/sql_test/shopDeatails1.php'),
      body: {'lat': '${latLng.latitude}', 'lng': '${latLng.longitude}'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> fetchedData = json.decode(response.body);
      navigate(fetchedData, latLng);
    } else {
      print('Failed to fetch data based on the string');
    }
  }
}
