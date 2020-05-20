import 'package:flutter/material.dart';
import 'package:project_teachers/services/storage/storage_service.dart';

class ArticleUserWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String articleDate;
  final Function onPressedFunction;

  ArticleUserWidget(
      {@required this.userName,
      @required this.onPressedFunction,
      this.userId,
      this.articleDate});

  @override
  State<StatefulWidget> createState() => _ArticleUserState();
}

class _ArticleUserState extends State<ArticleUserWidget> {
  StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService.instance;
  }

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
            Container(
                width: 50,
                child: Material(
                    child: _storageService.userImages.containsKey(widget.userId)
                        ? _storageService.userImages[widget.userId].item2
                        : Image.asset(
                            "assets/img/default_profile_2.png",
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                          ),
                    elevation: 5.0,
                    shape: CircleBorder(),
                    clipBehavior: Clip.antiAlias)),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(widget.userName,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey[700])),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(widget.articleDate,
                        textAlign: TextAlign.right,
                        style:
                            TextStyle(fontSize: 10, color: Colors.grey[500]))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
