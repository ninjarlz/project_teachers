import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AnimationCircularProgressWidget extends StatefulWidget {
  bool status;

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