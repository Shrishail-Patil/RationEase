import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDetails extends StatefulWidget {
  final String user;

  const UserDetails({super.key, required this.user});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late Future<List<dynamic>> _userDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = _fetchUserDetails();
  }

  Future<List<dynamic>> _fetchUserDetails() async {
    final response = await http.post(
        Uri.parse('http://10.0.2.2/sql_test/test2.php'),
        // await http.post(Uri.parse('http://192.168.1.7/sql_test/test2_1.php'),
        body: {'ration': widget.user});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userDetails = snapshot.data!;
            String No_of_aadhar = userDetails[0]['aadhar'];
            No_of_aadhar = No_of_aadhar.replaceFirst("[", "");
            No_of_aadhar = No_of_aadhar.replaceFirst(']', '');
            No_of_aadhar = No_of_aadhar.replaceAll(" ", "");
            List<String> noAadhar = No_of_aadhar.split(',');
            print(noAadhar);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(
                    20.0), // Add padding to increase the box size
                child: Container(
                  constraints: BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(30, 60, 30, 60),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Number: ${userDetails[0]['ration card']}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'FPS Id: ${userDetails[0]['fps id']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Number of Cardholders: ${noAadhar.length}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'ONORC: ${userDetails[0]['onorc']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Scheme: ${userDetails[0]['scheme']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'District: ${userDetails[0]['district']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'State: ${userDetails[0]['state']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
