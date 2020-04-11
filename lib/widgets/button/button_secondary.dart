import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class ButtonSecondaryWidget extends StatefulWidget {
  final String text;
  final Function submit;
  final double size;

  ButtonSecondaryWidget({@required this.text, @required this.submit, this.size});

  @override
  State<StatefulWidget> createState() => _ButtonSecondaryWidgetState();

}

class _ButtonSecondaryWidgetState extends State<ButtonSecondaryWidget> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
          widget.text,
          style: TextStyle(fontSize: widget.size != null ? widget.size : 18.0, fontWeight: FontWeight.w300, color: ThemeGlobalColor().textColor)
      ),
      onPressed: () => widget.submit(),
    );
  }
}