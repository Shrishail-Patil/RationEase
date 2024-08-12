import 'package:flutter/material.dart';
import 'package:map/getlocation.dart';
import 'package:flutter/services.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'dart:convert';
// import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String user = prefs.getString('login') ?? "";
  runApp(MyApp(
    isLogin: isLoggedIn,
    user: user,
  ));
}

class MyApp extends StatelessWidget {
  final String user;
  final bool isLogin;
  const MyApp({super.key, required this.isLogin, required this.user});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isLogin ? Home(user: user) : const MyLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _aadharNo = TextEditingController();
  final TextEditingController _rationNo = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoginWithNumber = true;
  bool _formSubmitted = false;
  var t1 = 'Login with Aadhar No.';
  var t2 = 'Login with Ration Card No.';
  var t3 = 'Login with Ration Card No.';

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

  void _toggleTextBox() {
    setState(() {
      _isLoginWithNumber ? _aadharNo.text = "" : _rationNo.text = "";
      _isLoginWithNumber = !_isLoginWithNumber;
    });
    if (_isLoginWithNumber) {
      t3 = t2;
    } else {
      t3 = t1;
    }
  }

  @override
  void dispose() {
    _aadharNo.dispose();
    _rationNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/loginbg.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: const EdgeInsets.only(left: 35, top: 130),
              child: const Text(
                'Welcome\nto RationEase',
                style: TextStyle(color: Colors.black, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 35, right: 35),
                          child: Column(
                            children: [
                              Visibility(
                                visible: _isLoginWithNumber,
                                child: TextFormField(
                                  controller: _aadharNo,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]'))
                                  ],
                                  validator: (value) {
                                    if (_formSubmitted &&
                                        value?.isEmpty == true) {
                                      return 'Please Enter Aadhar Number';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Aadhar Number',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !_isLoginWithNumber,
                                child: TextFormField(
                                  controller: _rationNo,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]'))
                                  ],
                                  validator: (value) {
                                    if (_formSubmitted &&
                                        value?.isEmpty == true) {
                                      return 'Please Enter Ration Number';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Ration Number',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Log in',
                                    style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: const Color(0xff4c505b),
                                    child: IconButton(
                                        color: Colors.white,
                                        onPressed: () async {
                                          setState(() {
                                            _formSubmitted = true;
                                          });

                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Handle the form submission here
                                            String value = _isLoginWithNumber
                                                ? _aadharNo.text
                                                : _rationNo.text;
                                            var a;
                                            if (_isLoginWithNumber) {
                                              print(value);
                                              final response = await http.post(
                                                Uri.parse(
                                                    'http://10.0.2.2/sql_test/login.php'),
                                                // 'http://192.168.157.142/sql_test/login1.php'),
                                                body: {
                                                  'login': value,
                                                  'check': '1'
                                                },
                                              );
                                              a = jsonDecode(response.body);
                                              print(a);
                                            } else {
                                              print(value);
                                              final response = await http.post(
                                                Uri.parse(
                                                    'http://10.0.2.2/sql_test/login.php'),
                                                // 'http://192.168.157.142/sql_test/login1.php'),
                                                body: {
                                                  'login': value,
                                                  'check': '0'
                                                },
                                              );
                                              a = jsonDecode(response.body);
                                              print(a);
                                            }
                                            if (a == "fail") {
                                              // ignore: use_build_context_synchronously
                                              _showOptionsNotSelectedPopup(
                                                  context,
                                                  _isLoginWithNumber
                                                      ? "Invalid Aadhar Number"
                                                      : "Invalid Ration Number");
                                            } else {
                                              bool loginSuccess = true;
                                              if (loginSuccess) {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setBool(
                                                    'isLoggedIn', true);
                                                prefs.setString('login',
                                                    a[0]['ration card']);

                                                // ignore: use_build_context_synchronously
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Home(
                                                            user: a[0]
                                                                ['ration card'],
                                                          )),
                                                );
                                              }
                                            }
                                            // Perform any actions you need with the value
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                        )),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // Navigator.pushNamed(context, '/loginr');
                                      _toggleTextBox();
                                    },
                                    style: const ButtonStyle(),
                                    child: Text(
                                      t3,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Color(0xff4c505b),
                                          fontSize: 18),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
