import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/article/index.dart';

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
    _tags.add("Tag1"); // TODO: Remove when real tags are loaded
    _tags.add("Tag2");
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

  Widget _buildTagsRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 2 && (2 * rowIndex + i) < _tags.length; i++) {
      _rowElements.add(Text('#${_tags[2 * rowIndex + i]}', style: ThemeGlobalText().tag));
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
      child: Column(
        children: <Widget>[
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 15),
          Image.asset("assets/img/timeline/picture_example.png"),
      ],
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
        Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: new BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.only(top: 14.0),
          child: Column(
            children: <Widget>[
              ArticleUserWidget(
                userName: "Firstname Lastname",
                onPressedFunction: null,
                articleDate: "21 April 2020",
              ),
              _buildContent(context),
              _buildTags(),
              _buildButtons(context),
            ],
          ),
        ),
      ],
    );
  }
}
