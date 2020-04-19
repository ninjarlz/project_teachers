import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class ButtonSecondaryWidget extends StatelessWidget {
  final String text;
  final Function submit;
  final double size;

  ButtonSecondaryWidget({@required this.text, @required this.submit, this.size});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
          text,
          style: TextStyle(fontSize: size != null ? size : 18.0, fontWeight: FontWeight.w300, color: ThemeGlobalColor().textColor)
      ),
      onPressed: () => submit(),
    );
  }

}