import 'package:flutter/material.dart';
import 'package:project_teachers/widgets/index.dart';

class Timeline extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return CardArticleWidget();
              },
            ),
          ),
        ],
      ),
    );
  }
}
