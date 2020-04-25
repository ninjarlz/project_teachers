import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
abstract class  BaseInputSearchWidgetState<T extends StatefulWidget> extends State<T> {
  InputDecoration setDecoration() {
    Icon search = Icon(Icons.search, color: ThemeGlobalColor().secondaryColorDark);
    return InputDecoration(
      labelText: Translations.of(context).text("global_search"),
      prefixIcon: search,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          gapPadding: 3,
          borderSide: BorderSide(color: ThemeGlobalColor().secondaryColorDark, style: BorderStyle.solid, width: 1)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          gapPadding: 3,
          borderSide: BorderSide(color: ThemeGlobalColor().secondaryColorDark, style: BorderStyle.solid, width: 10.0)),
      contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
    );
  }
}