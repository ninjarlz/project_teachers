import 'package:flutter/material.dart';

class AnimationCircularProgressWidget extends StatefulWidget {
  final bool status;

  AnimationCircularProgressWidget({this.status});

  @override
  State<StatefulWidget> createState() => _AnimationCircularProgressWidgetState();

}

class _AnimationCircularProgressWidgetState extends State<AnimationCircularProgressWidget> {
  @override
  Widget build(BuildContext context) {
      return Center(child: widget.status == true ? CircularProgressIndicator() : Container());
  }
}