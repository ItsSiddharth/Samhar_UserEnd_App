import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'welcomescreen.dart';

class RegisterPage extends StatefulWidget {
  static const String id = 'RegisterPage';
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String email = '';
  String password = '';
  String PhoneNumber ;
  String AADHAR ;
  String id ;

  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  final db = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 120.0),
            child: Container(
              height: 550,
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
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Please Register to proceed to Login',
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
                          decoration: InputDecoration(
                              hintText: 'Email-ID'
                          ),
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
                          decoration: InputDecoration(
                              hintText: 'Password'
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 20),
                        child: TextField(
                          textAlign: TextAlign.left,
                          onChanged: (value) {
                            //Do something with the user input.
                            AADHAR = value.toString();
                          },
                          decoration: InputDecoration(
                              hintText: 'AADHAR Number'
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 20),
                        child: TextField(
                          textAlign: TextAlign.left,
                          onChanged: (value) {
                            //Do something with the user input.
                            PhoneNumber = value.toString();
                          },
                          decoration: InputDecoration(
                              hintText: 'Mobile Number'
                          ),
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
                              color: Color(0xFF03D9BF),
                          ),
                          child: Center(
                            child: Text('Register', style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            showSpinner=true;
                          });
                          try {
                            print("###################");
                            await db.collection('$email').document("doc").setData({
                              'AADHAR': '$AADHAR',
                              'Mobile': '$PhoneNumber',
                              'Status' : 'Not Updated',
                            });
                            final newUser = await _auth.createUserWithEmailAndPassword(
                                email: email.trim(), password: password);
                            if(newUser!= null){
                              Navigator.pushNamed(context, WelcomeScreen.id);
                              setState(() {
                                showSpinner=false;
                              });
                            }
                          }
                          catch(e){
                            print(e);
                            setState(() {
                              showSpinner=false;
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
