import 'package:flutter/material.dart';

class AnimationCircularProgressWidget extends StatelessWidget {
  final bool status;

  AnimationCircularProgressWidget({this.status});
  @override
  Widget build(BuildContext context) {
    return Center(child: status == true ? CircularProgressIndicator() : Container());
  }
}