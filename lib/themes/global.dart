import 'package:flutter/material.dart';

class ThemeGlobalColor {
  Color mainColor = Color(0xff84dd63);
  Color mainColorLight = Color(0xffcbff4d);
  Color mainColorDark = Color(0xff6baa75);
  Color secondaryColor = Color(0xff69747c);
  Color secondaryColorDark = Color(0xff545454);
  Color appBarColor = Colors.white;
}

class ThemeGlobalShape {
  RoundedRectangleBorder mainButtonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
}

class ThemeGlobalText {
  TextStyle text = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 18.0,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.5,
      color: ThemeGlobalColor().secondaryColorDark);

  TextStyle inputText = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16.0,
      fontWeight: FontWeight.w300,
      letterSpacing: 0,
      color: ThemeGlobalColor().secondaryColorDark);

  TextStyle smallText = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.5,
      color: ThemeGlobalColor().secondaryColorDark);

  TextStyle errorText = TextStyle(
    fontFamily: 'Montserrat',
    color: Colors.redAccent,
  );

  TextStyle mainButtonText = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.w500);

  TextStyle buttonText = TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 12.0,
    color: Colors.white,
  );

  TextStyle appBarText = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 21.0,
      fontWeight: FontWeight.bold,
      color: ThemeGlobalColor().secondaryColorDark);
}
