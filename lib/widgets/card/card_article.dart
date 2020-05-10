import 'package:flutter/material.dart';
import 'package:project_teachers/widgets/pills/index.dart';

class CardArticleWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CardArticleState();
  }
}

class _CardArticleState extends State<CardArticleWidget> {
  bool _isLiked = false;
  int _likeNb = 0;
  int _commentNb = 0;
  List<String> _tags = List<String>();

  @override
  void initState() {
    super.initState();
    _tags.add("Tag 1"); // TODO: Remove when real tags are loaded
    _tags.add("Tag 2");
  }

  void _updateLike() {
    if (_likeNb != -1) {
      if (!_isLiked) {
        // TODO: Post like
      } else {
        // TODO: delete like
      }
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked)
          _likeNb++;
        else
          _likeNb--;
      });
    }
  }

  void _goToArticle() {}

  void _goToProfile(BuildContext context) {}

  Widget _buildUser(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: MaterialButton(
        minWidth: 0,
        padding: EdgeInsets.all(0),
        onPressed: () => _goToProfile(context),
        child: Row(
          children: <Widget>[
            Image.asset(
              "assets/img/default_profile_2.png",
              width: 50,
              alignment: Alignment.bottomCenter,
            ),
            SizedBox(width: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Firstname Lastname",
                    textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[700])),
                Text("01 April, 2020", textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 2 && (2 * rowIndex + i) < _tags.length; i++) {
      _rowElements.add(PillProfileWidget(
        text: _tags[2 * rowIndex + i],
        height: 25,
      ));
    }
    return Row(children: _rowElements);
  }

  Widget _buildTags() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(0),
          itemCount: (_tags.length / 2).ceil(),
          itemBuilder: (context, index) {
            return _buildTagsRow(index);
          }),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Text(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          MaterialButton(
            onPressed: () => _updateLike(),
            minWidth: 0,
            child: Row(
              children: <Widget>[
                Image.asset(
                  (_isLiked) ? "assets/img/timeline/like_enabled.png" : "assets/img/timeline/like_disabled.png",
                  scale: 2.5,
                ),
                SizedBox(width: 5),
                Text(
                  (_likeNb >= 0) ? _likeNb.toString() : "...",
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          MaterialButton(
            onPressed: () => _goToArticle(),
            minWidth: 0,
            child: Row(
              children: <Widget>[
                Image.asset(
                  "assets/img/timeline/comment2.png",
                  scale: 2.5,
                ),
                SizedBox(width: 5),
                Text(
                  (_commentNb >= 0) ? _commentNb.toString() : "...",
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 14.0),
            child: Column(
              children: <Widget>[
                _buildUser(context),
                _buildContent(context),
                _buildTags(),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
