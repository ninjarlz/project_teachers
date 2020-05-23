import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/themes/global.dart';

abstract class  BaseInputWithIconWidgetState<T extends StatefulWidget> extends State<T> {

  InputDecoration setDecoration(String hint, [Icon icon]) {
    return InputDecoration(
      labelText: hint,
      prefixIcon: icon,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          gapPadding: 3,
          borderSide: BorderSide(color: ThemeGlobalColor().textColor, style: BorderStyle.solid, width: 10.0)),
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }
}