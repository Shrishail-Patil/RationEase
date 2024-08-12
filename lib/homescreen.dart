import 'package:flutter/material.dart';
import 'package:map/balance.dart';
import 'package:map/maap.dart';
import 'package:map/transactions.dart';
import "package:shared_preferences/shared_preferences.dart";
import "package:map/search.dart";
import 'package:map/feedback.dart';
import 'package:map/main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/userdetails.dart';

class HomeScreen extends StatelessWidget {
  final String user;
  final LatLng start;
  const HomeScreen({super.key, required this.start, required this.user});

  void _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('login', '');
    // Navigate back to the login page
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: UserDetailBox(
              user: user,
            ),
          ),
          Expanded(
            child: Center(
              child: IconGrid(
                start: start,
                user: user,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          // Handle navigation based on the index of the tapped item
          // For example, you can use Navigator.push to navigate to other pages.
          switch (index) {
            case 0:

              // Navigate to Home page
              break;
            case 1:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapScreen(start: start, user: user)));
              // Navigate to Search page
              break;
            case 2:
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Transactions(
                        user: user,
                        start: start,
                      )));
              // Navigate to Settings page
              break;
          }
        },
      ),
    );
  }
}

class UserDetailBox extends StatelessWidget {
  final String user;
  const UserDetailBox({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            // Add user profile image here
            backgroundImage: AssetImage('assets/user.png'),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Ration Card No: $user",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class IconGrid extends StatelessWidget {
  final String user;
  final LatLng start;
  const IconGrid({super.key, required this.start, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Gray background color for the box
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              children: [
                IconCard(
                  imagePath: 'assets/balance.png',
                  name: 'Balance Commodities',
                  start: start,
                  user: user,
                ),
                IconCard(
                  imagePath: 'assets/details.png',
                  name: 'User Details',
                  start: start,
                  user: user,
                ),
                IconCard(
                  imagePath: 'assets/search.png',
                  name: 'Search Item',
                  start: start,
                  user: user,
                ),
                IconCard(
                  imagePath: 'assets/feedback.png',
                  name: 'Feed-Back',
                  start: start,
                  user: user,
                ),
              ],
            ),
          )),
    );
  }
}

class IconCard extends StatelessWidget {
  final String imagePath;
  final String user;
  final LatLng start;
  final String name;

  const IconCard(
      {super.key,
      required this.imagePath,
      required this.name,
      required this.start,
      required this.user});
  void _onIconTap(BuildContext context) {
    switch (name) {
      case 'Balance Commodities':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Balance(start: start, user: user)));
        break;
      case 'User Details':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserDetails(
                      user: user,
                    )));
        break;
      case 'Search Item':
        // Navigator.push(
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Search(
                      start: start,
                      user: user,
                    )));
        //     context, MaterialPageRoute(builder: (context) => Page3()));
        break;
      case 'Feed-Back':
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedBack()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _onIconTap(context);
      },
      child: Column(
        children: [
          Image.asset(imagePath, width: 110, height: 110),
          const SizedBox(height: 10),
          Text(name),
        ],
      ),
    );
  }
}
