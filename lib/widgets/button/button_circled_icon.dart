import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class ButtonCircledIconWidget extends StatelessWidget {
  final IconData icon;
  final Function submit;

  ButtonCircledIconWidget({@required this.icon, @required this.submit});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () => submit(),
      child: Icon(
        icon,
        color: Colors.white,
        size: 25.0,
      ),
      shape: CircleBorder(),
      fillColor: ThemeGlobalColor().buttonColor,
      padding: EdgeInsets.all(15),
    );
  }

}

