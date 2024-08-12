import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:map/feedback.dart';
import 'dart:async';
import 'dart:core';
// import "package:map/homescreen.dart";
// import 'package:map/transactions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Balance extends StatefulWidget {
  final String user;
  final LatLng start;
  const Balance({super.key, required this.start, required this.user});

  @override
  _BalanceState createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  Future<List<LatLng>>? _latLngData;
  @override
  void initState() {
    super.initState();
    _latLngData = latlngData();
  }

  Future<List<LatLng>> latlngData() async {
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
        title: const Text('Balance Commodities'),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BalanceDetails(
                                  start: widget.start,
                                  user: widget.user,
                                  end: latLng,
                                )));
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
}

class BalanceDetails extends StatefulWidget {
  final LatLng end;
  final String user;
  final LatLng start;
  BalanceDetails({
    super.key,
    required this.start,
    required this.user,
    required this.end,
  });

  @override
  State<BalanceDetails> createState() => _BalanceDetailsState();
}

class _BalanceDetailsState extends State<BalanceDetails> {
  List? data;
  Timer? timer;
  @override
  void initState() {
    getDealer(widget.end);
    super.initState();
    timer = Timer(const Duration(seconds: 30), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BalanceDetails(
                  start: widget.start,
                  user: widget.user,
                  end: widget.end,
                )),
      );
    });
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    List items = data![0].keys.toList();
    List data2 = data!;
    List quantity = [
      "kg",
      "kg",
      "kg",
      "bars",
      "packets",
      "lit",
      "kg",
      "packets",
      "kg",
      "kg",
      "kg",
      "lit",
      "packets",
      "kg"
    ];
    print(items);
    print(data2);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Commodities'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: BalanceCard(
              data: data!,
              start: widget.start,
              end: widget.end,
            ),
          ),
          Expanded(
            child: Center(
              child: ListView.builder(
                itemCount: items == null ? 0 : items.length - 5,
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, i) => Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                      title: Text(items[i + 5]),
                      subtitle:
                          Text(data![0][items[i + 5]] + " " + quantity[i])),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (data != null && data![0]['dealerId'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedBack(
                  dealer: data![0]['dealerId'],
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.feedback),
      ),
    );
  }

  void getDealer(LatLng latLng) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/sql_test/shopDeatails.php'),
      // Uri.parse('http://192.168.157.142/sql_test/shopDeatails1.php'),
      body: {'lat': '${latLng.latitude}', 'lng': '${latLng.longitude}'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> fetchedData = json.decode(response.body);
      setState(() {
        data = fetchedData;
      });
    } else {
      print('Failed to fetch data based on the string');
    }
  }
}

class BalanceCard extends StatelessWidget {
  final List data;
  final LatLng start;
  final LatLng end;
  const BalanceCard(
      {super.key, required this.data, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  String url =
                      "https://www.google.com/maps/dir/?api=1&origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}";
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    print("Error opening Google Maps.");
                  }
                },
                child: const CircleAvatar(
                  radius: 30,
                  // Add user profile image here
                  child: Icon(
                    Icons.location_pin,
                  ),
                ),
              ),
              const Text("Click to Locate"),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dealer: ${data[0]['name']}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                "DealerID: ${data[0]['dealerId']}",
                style: const TextStyle(fontSize: 17, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                "Address: ${data[0]['address']}",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              // const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}
