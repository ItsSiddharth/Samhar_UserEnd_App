import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Covid_stats.dart';
import 'package:qr_flutter/qr_flutter.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class HomePage extends StatefulWidget {
  static const String id = 'HomePage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  String email;
  String AADHAR;
  String PhNo;
  String id;
  bool showSpinner = false;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
//    readData();
  }
//
//  void readData() async {
//    DocumentSnapshot snapshot =
//        await _fireStore.collection(email).document().get();
//    print("##############");
//    print(email);
//    print(snapshot.data);
//    print(snapshot.data['AADHAR']);
//    AADHAR = snapshot.data['AADHAR'];
//  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        email = loggedInUser.email.toString();
      }
    } catch (e) {
      print(e);
    }
  }

  Card buildItem(DocumentSnapshot doc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'AADHAR: ${doc.data['AADHAR']}',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Center(
              child: Text(
                'Mobile: ${doc.data['Mobile']}',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Status: ',
                    style: TextStyle(fontSize: 24),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      color: doc.data['Status'].toString() == 'Mid'
                          ? Colors.orange
                          : doc.data['Status'].toString() == 'Low'
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            QrImage(
              data:
                  '{"0": ["${doc.data['AADHAR']}", "${doc.data['Mobile']}", "${doc.data['Status']}"]}',
//                {"0": ["255359739586.0", "8472699987.0", "High"]}
            ),
          ],
        ),
      ),
    );
  }

//  color: Category=='Mid' ? Colors.orange: Category=='Low' ? Colors.green:Colors.red,   ${doc.data['Status']}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF03D9BF),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("User Logged In"),
              FlatButton(
                onPressed: () {
                  setState(() {
                    showSpinner = true;
                  });
                },
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF03D9BF),
                ),
                child: Center(
                    child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'USER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: FlatButton(
                    child: Text('COVID-19'),
                    onPressed: () {
                      Navigator.pushNamed(context, CovidStats.id);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: FlatButton(
                    child: Text('Your Covid Prediction'),
                    onPressed: () {
                      Navigator.pushNamed(context, HomePage.id);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Center(
            child: showSpinner
                ? Column(
                    children: <Widget>[
                      StreamBuilder<QuerySnapshot>(
                        stream: _fireStore.collection(email).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                  children: snapshot.data.documents
                                      .map((doc) => buildItem(doc))
                                      .toList()),
                            );
                          } else {
                            print('LOL');
                            return Container(
                              color: Colors.white,
                            );
                          }
                        },
                      )
                    ],
                  )
                : Container(
                    child: Center(
                      child: Text('Loading ....'),
                    ),
                  )),
      ),
    );
  }
}
