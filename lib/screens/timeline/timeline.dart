import 'package:flutter/material.dart';
import 'package:project_teachers/screens/timeline/post.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/themes/index.dart';

class Timeline extends StatefulWidget {
  static FloatingActionButton timelineFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TimelinePost()));
        },
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.add));
  }

  @override
  State<StatefulWidget> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  TextEditingController _searchCtrl = TextEditingController();

  void _searchFilter() {
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          InputSearchWidget(
            ctrl: _searchCtrl,
            submitChange: _searchFilter,
          ),
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
