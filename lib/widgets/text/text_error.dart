import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

class TextErrorWidget extends StatelessWidget {
  final String text;

  TextErrorWidget({@required this.text});

  @override
  Widget build(BuildContext context) {
    if (text != null && text.length > 0) {
      return Text(
        text,
        style: ThemeGlobalText().errorText,
      );
    } else return Container();
  }

}
