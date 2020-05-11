import 'package:flutter/material.dart';

class ArticleUserWidget extends StatefulWidget {
  final String userImage;
  final String userName;
  final String articleDate;
  final Function onPressedFunction;

  ArticleUserWidget({@required this.userName, @required this.onPressedFunction, this.userImage, this.articleDate});

  @override
  State<StatefulWidget> createState() => _ArticleUserState();
}

class _ArticleUserState extends State<ArticleUserWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: MaterialButton(
        minWidth: 0,
        padding: EdgeInsets.all(0),
        onPressed: () => widget.onPressedFunction(),
        child: Row(
          children: <Widget>[
            Image.asset(
              widget.userImage == null ? "assets/img/default_profile_2.png" : widget.userImage,
              width: 50,
              alignment: Alignment.bottomCenter,
            ),
            SizedBox(width: 5),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.userName,
                    textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[700])),
                widget.articleDate == null
                    ? Container()
                    : Text(widget.articleDate, textAlign: TextAlign.right, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
