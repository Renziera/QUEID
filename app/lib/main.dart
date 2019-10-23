import 'package:flutter/material.dart';
import 'package:queid/splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QUE.ID',
      theme: ThemeData(
        primarySwatch: BIRU,
        fontFamily: 'Metropolis',
        buttonTheme: ButtonThemeData(
          buttonColor: BIRU,
          textTheme: ButtonTextTheme.primary,
        )
      ),
      home: SplashScreen(),
    );
  }
}

const MaterialColor BIRU = const MaterialColor(0xFF4370E1, const {
  50: Color.fromRGBO(67, 112, 225, .1),
  100: Color.fromRGBO(67, 112, 225, .2),
  200: Color.fromRGBO(67, 112, 225, .3),
  300: Color.fromRGBO(67, 112, 225, .4),
  400: Color.fromRGBO(67, 112, 225, .5),
  500: Color.fromRGBO(67, 112, 225, .6),
  600: Color.fromRGBO(67, 112, 225, .7),
  700: Color.fromRGBO(67, 112, 225, .8),
  800: Color.fromRGBO(67, 112, 225, .9),
  900: Color.fromRGBO(67, 112, 225, 1),
});
