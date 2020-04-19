import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class TextIconWidget extends StatelessWidget {
  final IconData icon;
  final String text;

  TextIconWidget({@required this.icon, @required this.text});

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
            style: ThemeGlobalText().text,
          ),
        ],
      ),
    );
  }

}