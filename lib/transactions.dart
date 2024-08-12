import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:map/homescreen.dart";
import 'dart:convert';
import 'dart:async';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:map/maap.dart';

class Transactions extends StatefulWidget {
  final LatLng start;
  final String user;

  const Transactions({super.key, required this.user, required this.start});
  @override
  _Transactions createState() => _Transactions();
}

class _Transactions extends State<Transactions> {
  Timer? timer;
  Future<List> post() async {
    final response =
        await http.post(Uri.parse("http://10.0.2.2/sql_test/transactions.php"),
            // await http.post(
            // Uri.parse("http://192.168.1.7/sql_test/transactions1.php"),
            body: {'name': widget.user});
    var a = json.decode(response.body);
    return a;
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 300), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Transactions(
                  user: widget.user,
                  start: widget.start,
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
      ),
      body: FutureBuilder<List>(
        future: post(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          if (snapshot.hasData) {
            DateTime now = DateTime.now();
            int currentMonth = now.month;
            List months = [
              'January',
              'February',
              'March',
              'April',
              'May',
              'June',
              'July',
              'August',
              'September',
              'October',
              'November',
              'December'
            ];
            List a = [];
            List data = [];
            for (int i = currentMonth; i > 0; i--) {
              data.add(snapshot.data?[i - 1]);
              a.add(months[i - 1]);
            }
            for (int i = 12; i > currentMonth; i--) {
              data.add(snapshot.data?[i - 1]);
              a.add(months[i - 1]);
            }
            List b = (snapshot.data?[0].keys.toList());
            return ItemList(
              months: a,
              columns: b,
              data: data,
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
                        user: widget.user,
                        start: widget.start,
                      )));
              break;
            case 1:
              // Navigate to Search page
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapScreen(
                        user: widget.user,
                        start: widget.start,
                      )));
              break;
            case 2:

              // Navigate to Settings page
              break;
          }
        },
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  List data;
  List columns;
  List months;
  ItemList(
      {super.key,
      required this.data,
      required this.months,
      required this.columns});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ignore: unnecessary_null_comparison
      itemCount: months == null ? 0 : months.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, i) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            title: Text(
              months[i],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ItemList1(
                      index: i,
                      month: months[i],
                      columns: columns,
                      data: data,
                    ))),
          ),
        );
      },
    );
  }
}

class ItemList1 extends StatelessWidget {
  String month;
  List columns;
  List data;
  int index;
  ItemList1(
      {super.key,
      required this.index,
      required this.data,
      required this.month,
      required this.columns});

  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(month),
      ),
      body: ListView.builder(
        // ignore: unnecessary_null_comparison
        itemCount: columns == null ? 0 : columns.length - 1,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, i) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(
                columns[i + 1],
              ),
              subtitle: Text(
                data[index][columns[i + 1]] + " " + quantity[i],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
