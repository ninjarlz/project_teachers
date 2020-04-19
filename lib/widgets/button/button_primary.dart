import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class ButtonPrimaryWidget extends StatelessWidget {
  final String text;
  final Function submit;

  ButtonPrimaryWidget({@required this.text, @required this.submit});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
            height: 50,
            child: RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
                color: ThemeGlobalColor().buttonColor,
                child: Text(
                    text,
                    style: TextStyle(fontSize: 20.0, color: Colors.white)
                ),
                onPressed: () => submit()
            )
        )
    );
  }

}