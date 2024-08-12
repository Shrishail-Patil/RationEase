import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class FeedBack extends StatefulWidget {
  String? dealer;
  FeedBack({super.key, this.dealer});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<FeedBack> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showNameError = false;
  bool _showFeedbackError = false;

  void _showOptionsNotSelectedPopup(BuildContext context, String a) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(a)),
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

  @override
  void dispose() {
    _nameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.dealer == null
        ? ""
        : widget
            .dealer!; // Predefined text for name // Predefined text for feedback

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input box for the name (limited to 15 characters)
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Dealer Id';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Dealer-Id (only numbers allowed)',
                  border: const OutlineInputBorder(),
                  errorText: _showNameError ? 'Please enter a Dealer Id' : null,
                ),
              ),
              const SizedBox(height: 16),
              // Input box for feedback
              TextFormField(
                controller: _feedbackController,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter feedback';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Feedback',
                  border: const OutlineInputBorder(),
                  errorText:
                      _showFeedbackError ? 'Please enter feedback' : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _showNameError = _nameController.text.isEmpty;
                    _showFeedbackError = _feedbackController.text.isEmpty;
                  });

                  if (_formKey.currentState!.validate()) {
                    // Handle the form submission here
                    String name = _nameController.text;
                    String feedback = _feedbackController.text;
                    final response = await http.post(
                      Uri.parse('http://10.0.2.2/sql_test/feed.php'),
                      // Uri.parse('http://192.168.157.142/sql_test/feed1.php'),
                      body: {'dealer': name, 'feed': feedback},
                    );
                    var a = jsonDecode(response.body);
                    _showOptionsNotSelectedPopup(context, a);
                    if (a == 'Feedback Posted') {
                      _nameController.text = '';
                      _feedbackController.text = '';
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
