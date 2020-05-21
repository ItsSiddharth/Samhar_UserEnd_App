import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:samhar_user/Covid_stats.dart';
import 'HomePage.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'LoginPage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 120.0),
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(40.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    new BoxShadow(
                      color: Color(0xFF000000).withOpacity(0.39),
                      blurRadius: 20.0,
                    ),
                  ]),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                      children: <Widget>[
                        Text(
                          'Please login to access your QR-Code and Restriction details',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 20),
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.left,
                            onChanged: (value) {
                              //Do something with the user input.
                              email = value;
                            },
                            decoration: InputDecoration(hintText: 'Username'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 20),
                          child: TextField(
                            obscureText: true,
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.left,
                            onChanged: (value) {
                              //Do something with the user input.
                              password = value;
                            },
                            decoration: InputDecoration(hintText: 'Password'),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 30,
                        ),
                        FlatButton(
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: Color(0xFF03D9BF)),
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              showSpinner = true;
                            });
                            try {
                              final newUser = await _auth.signInWithEmailAndPassword(
                                  email: email.trim(), password: password);
                              if (newUser != null) {
                                Navigator.pushNamed(context, CovidStats.id);
                                setState(() {
                                  showSpinner = false;
                                });
                              }
                            } catch (e) {
                              print(e);
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          },
                        )
                      ],
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}