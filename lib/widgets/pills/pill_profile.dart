import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

// ignore: must_be_immutable
class PillProfileWidget extends StatefulWidget {
  final Color color;
  final String text;

  PillProfileWidget({@required this.text, this.color});

  @override
  State<StatefulWidget> createState() => __PillProfileWidgetState();
}

class __PillProfileWidgetState extends State<PillProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width / 3.5,
      height: 40,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
        color: widget.color == null ? ThemeGlobalColor().buttonColor : widget.color,
        child: Padding(padding: EdgeInsets.all(5), child: Align(
          alignment: Alignment.center,
          child: Text(
            widget.text,
            style: TextStyle(fontSize: 10.0, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),),
      ),
    );
  }
}
