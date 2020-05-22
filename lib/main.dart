import 'package:flutter/material.dart';
import 'package:samhar_user/HomePage.dart';
import 'package:samhar_user/register_page.dart';
import 'welcomescreen.dart';
import 'login_page.dart';
import 'Covid_stats.dart';


const myTask = "syncWithTheBackEnd";


void main() async {
  runApp(MyApp());}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginPage.id: (context) => LoginPage(),
        HomePage.id :(context) => HomePage(),
        RegisterPage.id: (content) => RegisterPage(),
        CovidStats.id : (context) => CovidStats(),
      },
    );
  }
}







