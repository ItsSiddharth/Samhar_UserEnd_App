import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'Helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:geolocator/geolocator.dart';
import 'coordinate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

var childRef;
FirebaseUser loggedInUser;
String lat;
String long;
String apisender;



Future<void> addNewEntry(latitude, longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Coordinate coordinate = Coordinate(
      latitude: latitude,
      longitude: longitude,
      datetime: DateTime.now().toString());
  lat = coordinate.latitude.toString();
  long = coordinate.longitude.toString();
  apisender = prefs.getString('email');
  print(apisender);
  try {
    http.Response response = await http.get(
        'http://192.168.43.129:5000/checkpost/$apisender/$lat/$long');
  }
  catch (e){
    print(e);
  }
//  print(coordinate.latitude);
//  print(coordinate.longitude);
  return Future.delayed(const Duration(minutes: 1));
}

void foregroundServiceFunction() async {
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  addNewEntry(position.latitude, position.longitude);
}

void maybeStartFGS() async {
  print('Starting FGS');
  print('Done!');
  if (!(await ForegroundService.foregroundServiceIsStarted())) {
    await ForegroundService.setServiceIntervalSeconds(5); //necessity of editMode is dubious (see function comments) await ForegroundService.notification.startEditMode();
    await ForegroundService.notification
        .setTitle("Location stream is ON");
    await ForegroundService.notification
        .setText("You're data is in safe hands");

    await ForegroundService.notification.finishEditMode();

    await ForegroundService.startForegroundService(foregroundServiceFunction);
    await ForegroundService.getWakeLock();
  }
  await ForegroundService.notification
      .setPriority(AndroidNotificationPriority.LOW);
}

class ScreenWithIndex {
  final Widget screen;
  final int index;

  ScreenWithIndex({this.screen, this.index});
}


final GlobalKey<AnimatedCircularChartState> _chartKey =
new GlobalKey<AnimatedCircularChartState>();


class CovidStats extends StatefulWidget {
  static const String id = 'CovidStats';
  @override
  _CovidStatsState createState() => _CovidStatsState();
}

class _CovidStatsState extends State<CovidStats> {

  final _auth = FirebaseAuth.instance;
  String email;

  @override
  void initState() {
    //533
    _initializePage();
    super.initState();
    floatingIcon = Icons.stop;
    getCurrentUser();
  }
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

  void _afterLayout(_) {}

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text(
              'We are dedicated to protect you',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: Text(
              'But we will need your cooperation for that, please allow it to track your location',
              style: TextStyle(color: Colors.grey),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'NO',
                  style: TextStyle(
                    color: Color(0xFFFA6400),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('I AM IN',
                    style: TextStyle(
                      color: Color(0xFFFA6400),
                      fontWeight: FontWeight.w400,
                    )),
                onPressed: () async {
                  Navigator.of(context).pop();
                  GeolocationStatus geolocationStatus =
                  await Geolocator().checkGeolocationPermissionStatus();
                  if ((geolocationStatus == GeolocationStatus.denied ||
                      geolocationStatus == GeolocationStatus.disabled)) {
                    print(
                        'Location permission not given! Asking for permission');
                    final PermissionStatus permissionStatus =
                    await Permission.locationWhenInUse.request();
                    if (permissionStatus == PermissionStatus.granted) {
                      maybeStartFGS();
                    } else {}
                  } else {
                    maybeStartFGS();
                  }
                },
              ),
            ],
          );
        });
  }
  void _initializePage() async {
    //await _listenLocation();
    // timer = Timer.periodic(Duration(seconds: 10), (Timer t) => addNewEntry());
    GeolocationStatus geolocationStatus =
    await Geolocator().checkGeolocationPermissionStatus();
    print('((_))');
    print(geolocationStatus);
    if (geolocationStatus == GeolocationStatus.granted) {
      maybeStartFGS();
    } else if ((geolocationStatus == GeolocationStatus.denied ||
        geolocationStatus == GeolocationStatus.disabled ||
        geolocationStatus == GeolocationStatus.restricted ||
        geolocationStatus == GeolocationStatus.unknown)) {
      print('Location permission not given! Asking for permission');
      _showDialog();
    } else {
      maybeStartFGS();
    }
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    //_setUpListener();
  }

  var floatingIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03D9BF),
        title: Text('Stats'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 27.0),
        child: FloatingActionButton(
          onPressed: () async {
            final fgsIsRunning = await ForegroundService.foregroundServiceIsStarted();
            if (fgsIsRunning) {
              setState(() {
                floatingIcon = Icons.play_arrow;
              });
              await ForegroundService.stopForegroundService();
              print('Foreground process stopped');
            } else {
              setState(() {
                floatingIcon = Icons.pause;
              });
              maybeStartFGS();
              print('Foreground process started!');
            }
          },
          child: Tooltip(
            showDuration: Duration(),
            message: 'Stop Collecting Location Data',
            child: Icon(floatingIcon),
          ),
          backgroundColor: Colors.red,
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
                  onPressed: (){
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
                  onPressed: (){
                    Navigator.pushNamed(context, HomePage.id);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: AndroidFirstPage(),
    );
  }
}


class AndroidFirstPage extends StatefulWidget {
  const AndroidFirstPage({Key key}) : super(key: key);

  @override
  _AndroidFirstPageState createState() => _AndroidFirstPageState();
}

class _AndroidFirstPageState extends State<AndroidFirstPage> with AutomaticKeepAliveClientMixin {
  int totalCases = 0;
  int prevTotalCases = 0;
  int deaths = 0;
  int recovered = 0;
  int confirmed = 0;
  int prevDayDeaths = 0;
  int prevDayRecovered = 0;
  int prevDayConfirmed = 0;
  bool valueReceived = false;
  String deathPercentage = "0.0";
  String recoveredPercentage = "0.0";
  String confirmedPercentage = "0.0";

  bool busy = true;

  void getData() async {
    setState(() {
      busy = true;
    });
    NetworkHelper covidData =
    NetworkHelper('https://pomber.github.io/covid19/timeseries.json');
    var globalData = await covidData.getData();
    print(globalData["India"].reversed.toList()[0]);

    if (this.mounted) {
      setState(() {
        recovered = globalData["India"].reversed.toList()[0]["recovered"];
        deaths = globalData["India"].reversed.toList()[0]["deaths"];
        confirmed = globalData["India"].reversed.toList()[0]["confirmed"];
        prevDayRecovered =
        globalData["India"].reversed.toList()[1]["recovered"];
        prevDayDeaths = globalData["India"].reversed.toList()[1]["deaths"];
        prevDayConfirmed =
        globalData["India"].reversed.toList()[1]["confirmed"];
        totalCases = recovered + deaths + confirmed;
        prevTotalCases = prevDayRecovered + prevDayDeaths + prevDayConfirmed;
        deathPercentage = ((deaths / totalCases) * 100).toStringAsFixed(2);
        recoveredPercentage =
            ((recovered / totalCases) * 100).toStringAsFixed(2);
        confirmedPercentage =
            ((confirmed / totalCases) * 100).toStringAsFixed(2);
        valueReceived = true;
      });
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    List<CircularStackEntry> data = <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(recovered.toDouble(), Color(0xFF03D9BF),
              rankKey: 'Q2'),
          new CircularSegmentEntry(confirmed.toDouble(), Color(0xFFFF9D42),
              rankKey: 'Q3'),
          new CircularSegmentEntry(deaths.toDouble(), Colors.black,
              rankKey: 'Q1'),
        ],
        rankKey: 'Quarterly Profits',
      ),
    ];

    return Scaffold(
        body: busy
            ? Container(
          child: Center(
            child: CircularProgressIndicator(
              // backgroundColor: Color(0xFFFBD7BF),
              // valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFBD7BF)),
            ),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Todays Report',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              valueReceived
                  ? Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: <Widget>[
                    AnimatedCircularChart(
                      key: _chartKey,
                      size: Size(
                          MediaQuery.of(context).size.width / 1.5,
                          MediaQuery.of(context).size.height / 2.2),
                      initialChartData: data,
                      chartType: CircularChartType.Radial,
                    ),
                    Positioned(
                      top: 40,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Death $deathPercentage%',
                            style:
                            TextStyle(color: Color(0xFFAE4500)),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFFEAD0BF),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: MediaQuery.of(context).size.width * 0.3,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Recovered $recoveredPercentage%',
                            style:
                            TextStyle(color: Color(0xFFFF9148)),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFFFBD7BF),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Confirmed $confirmedPercentage%',
                            style:
                            TextStyle(color: Color(0xFFFA6400)),
                          ),
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(0xFFFCE3D1),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : SpinKitRotatingCircle(
                color: Colors.white,
                size: 50.0,
              ),
              Row(
                children: <Widget>[
                  Card_template(
                    text: 'Confirmed',
                    value: confirmed > prevDayConfirmed
                        ? '${confirmed.toString()}(+${confirmed - prevDayConfirmed})'
                        : '${confirmed.toString()}(-${prevDayConfirmed - confirmed})',
                    colour: Color(0xFFFF9D42),
                  ),
                  Card_template(
                    text: 'Total Cases',
                    value: totalCases > prevTotalCases
                        ? '${totalCases.toString()}(+${totalCases - prevTotalCases})'
                        : '${totalCases.toString()}(-${prevTotalCases - totalCases})',
                    colour: Colors.red,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Card_template(
                    text: 'Recovered',
                    value: recovered > prevDayRecovered
                        ? '${recovered.toString()}(+${recovered - prevDayRecovered})'
                        : '${recovered.toString()}(-${prevDayRecovered - recovered})',
                    colour: Color(0xFF03D9BF),
                  ),
                  Card_template(
                    text: 'Deaths',
                    value: deaths > prevDayDeaths
                        ? '${deaths.toString()}(+${deaths - prevDayDeaths})'
                        : '${deaths.toString()}(-${prevDayDeaths - deaths})',
                    colour: Colors.black26,
                  )
                ],
              ),
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class Card_template extends StatelessWidget {
  Card_template({@required this.text, @required this.value, this.colour});

  final String text;
  final String value;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0), color: colour),
        width: MediaQuery.of(context).size.width * 0.45,
        height: 100.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                text,
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}