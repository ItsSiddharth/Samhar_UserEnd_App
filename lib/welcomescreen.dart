import 'package:flutter/material.dart';
import 'package:samhar_user/login_page.dart';
import 'package:samhar_user/register_page.dart';


class WelcomeScreen extends StatefulWidget {
  static const String id = 'WelcomeScreen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF03D9BF),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                ClipPath(
                  clipper: OrangeClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    width: MediaQuery.of(context).size.width,
                    color: Color(0xFFFF9D42),
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width * 0.7,
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
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Image(
                      image: AssetImage('images/logo.png'),
                      height: 100,
                      width: 100,
                    ),
                  ),
                  Text(
                    'Third Eye',
                    style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 130,
                  ),
                  FlatButton(
                    onPressed: (){
                      Navigator.pushNamed(context, LoginPage.id);
                    },
                    child: Container(
                      height: 44,
                      width: 150,
                      child: Center(
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF50DAC9),
                        borderRadius: BorderRadius.all(
                          Radius.circular(60.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  FlatButton(
                    onPressed: (){
                      Navigator.pushNamed(context, RegisterPage.id);
                    },
                    child: Container(
                      height: 44,
                      width: 150,
                      child: Center(
                        child: Text(
                          ' REGISTER',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF50DAC9),
                        borderRadius: BorderRadius.all(
                          Radius.circular(60.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OrangeClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height * 0.66);
//    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
