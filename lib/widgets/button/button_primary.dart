import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

// ignore: must_be_immutable
class ButtonPrimaryWidget extends StatefulWidget {
  final String text;
  final Function submit;

  ButtonPrimaryWidget({@required this.text, @required this.submit});

  @override
  State<StatefulWidget> createState() => _ButtonPrimaryWidgetState();

}

class _ButtonPrimaryWidgetState extends State<ButtonPrimaryWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          height: 50,
            child: RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                color: ThemeGlobalColor().buttonColor,
                child: Text(
                    widget.text,
                    style: TextStyle(fontSize: 20.0, color: Colors.white)
                ),
                onPressed: () => widget.submit()
            )
        )
    );
  }
}