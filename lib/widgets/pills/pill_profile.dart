import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class PillProfileWidget extends StatelessWidget {
  final Color color;
  final String text;

  PillProfileWidget({@required this.text, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width / 3.5,
      height: 40,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
        color: color == null ? ThemeGlobalColor().buttonColor : color,
        child: Padding(padding: EdgeInsets.all(5), child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(fontSize: 10.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),),
      ),
    );
  }
}
