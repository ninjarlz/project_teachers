import 'package:flutter/material.dart';

class ThemeGlobalColor {
  Color mainColor = Color(0xffFCC42C);
  Color mainColorLight = Color(0xffFFEB3B);
  Color mainColorDark = Color(0xffF9A825);
  Color secondaryColor = Color(0xff54CCE4);
  Color secondaryColorDark = Color(0xff03A9F4);
  Color buttonColor = Color(0xffFCC42C);
  Color textColor = Color(0xff403C3C);
  Color smallTextColor = Color(0xffC4C4CC);
  Color containerColor = Color(0xffE0F7FA);
  Color backgroundColor = Colors.white;
  Color appBarColor = Colors.white;
}

class ThemeGlobalShape {
  RoundedRectangleBorder mainButtonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
}

class ThemeGlobalText {
  TextStyle titleText = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: ThemeGlobalColor().textColor);

  TextStyle text = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: ThemeGlobalColor().textColor);

  TextStyle inputText = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: ThemeGlobalColor().textColor);

  TextStyle smallText = TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300, color: ThemeGlobalColor().smallTextColor);

  TextStyle errorText = TextStyle(color: Colors.redAccent);

  TextStyle mainButtonText = TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w500);

  TextStyle buttonText = TextStyle(fontSize: 12.0, color: Colors.white);

  TextStyle appBarText = TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold, color: ThemeGlobalColor().secondaryColorDark);
}
