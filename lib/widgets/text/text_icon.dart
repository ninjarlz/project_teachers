import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

// ignore: must_be_immutable
class TextIconWidget extends StatefulWidget {
  IconData icon;
  String text;

  TextIconWidget({@required this.icon, @required this.text});

  @override
  State<StatefulWidget> createState() => _TextIconWidgetState();
}

class _TextIconWidgetState extends State<TextIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Icon(widget.icon),
          SizedBox(width: 10),
          Text(
            widget.text,
            style: ThemeGlobalText().text,
          ),
        ],
      ),
    );
  }
}