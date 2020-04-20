import 'package:flutter/material.dart';

class TextIconWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextStyle textStyle;

  TextIconWidget({@required this.icon, @required this.text, @required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Icon(icon),
          SizedBox(width: 10),
          Text(
            text,
            style: textStyle
          ),
        ],
      ),
    );
  }

}