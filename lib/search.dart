import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/search_map.dart';

class Search extends StatefulWidget {
  final LatLng start;
  final String user;
  const Search({super.key, required this.start, required this.user});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<String> selectedValues = [];
  final List<String> checkboxValues = [
    'Rice',
    'Wheat',
    'GroundNuts',
    'Soaps',
    'Paapad',
    'Oil',
    'Sugar',
    'Salt',
    'Black Gram',
    'Red Gram',
    'Green Gram',
    'Kerosene',
    'Tea',
    'Tamarind',
  ];

  void _handleCheckboxValueChanged(String value, bool checked) {
    setState(() {
      if (checked) {
        if (!_containsValue(value)) {
          selectedValues.add(value);
        }
      } else {
        selectedValues.remove(value);
      }
    });
  }

  bool _containsValue(String value) {
    return selectedValues.contains(value);
  }

  void _showOptionsNotSelectedPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Options Not Selected'),
          content: const Text('Please select at least one option.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendItems() async {
    if (selectedValues.isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchMaps(
                  start: widget.start,
                  user: widget.user,
                  items: selectedValues)));
    } else {
      _showOptionsNotSelectedPopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search item'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
        itemCount: checkboxValues.length,
        itemBuilder: (context, index) {
          final value = checkboxValues[index];
          return Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              title: Text(value, style: const TextStyle(fontSize: 16.0)),
              value: _containsValue(value),
              onChanged: (bool? checked) =>
                  _handleCheckboxValueChanged(value, checked ?? false),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _sendItems();
        },
        child: const Icon(Icons.search_sharp),
      ),
    );
  }
}
