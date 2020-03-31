import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';

// ignore: must_be_immutable
class TextErrorWidget extends StatefulWidget {
  String text;

  TextErrorWidget({@required this.text});

  @override
  State<StatefulWidget> createState() => _TextErrorWidgetState();

}

class _TextErrorWidgetState extends State<TextErrorWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.text != null && widget.text.length > 0) {
      return Text(
        widget.text,
        style: ThemeGlobalText().errorText,
      );
    } else return Container();
  }
}