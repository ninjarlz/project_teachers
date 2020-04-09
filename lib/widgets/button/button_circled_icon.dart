import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

// ignore: must_be_immutable
class ButtonCircledIconWidget extends StatefulWidget {
  final IconData icon;
  final Function submit;

  ButtonCircledIconWidget({@required this.icon, @required this.submit});

  @override
  State<StatefulWidget> createState() => _ButtonCircledIconWidgetState();

}

class _ButtonCircledIconWidgetState extends State<ButtonCircledIconWidget> {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
          onPressed: () => widget.submit(),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 25.0,
          ),
          shape: CircleBorder(),
          fillColor: ThemeGlobalColor().buttonColor,
          padding: EdgeInsets.all(15),
    );
  }
}