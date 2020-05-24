import 'package:flutter/material.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/article/index.dart';

class CardArticleWidget extends StatefulWidget {
  final String userId;
  final String postId;
  final bool isAnswer;
  final String username;
  final String content;
  final String date;
  final List<String> tags;
  final List<String> images;
  final int reactionsNumber;
  final int answersNumber;

  CardArticleWidget(
      {@required this.userId,
      @required this.username,
      @required this.postId,
      @required this.isAnswer,
      @required this.content,
      @required this.date,
      this.tags,
      this.images,
      @required this.reactionsNumber,
      this.answersNumber});

  @override
  State<StatefulWidget> createState() {
    return _CardArticleState();
  }
}

class _CardArticleState extends State<CardArticleWidget> {
  bool _isLiked = false;
  TimelineService _timelineService;
  StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _timelineService = TimelineService.instance;
    _storageService = StorageService.instance;
  }

  void _updateLike() {
    if (!_isLiked) {
      // TODO: Post like
    } else {
      // TODO: delete like
    }
  }

  void _goToArticle() {}

  Widget _buildTagsRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 2 && (2 * rowIndex + i) < widget.tags.length; i++) {
      _rowElements.add(Text('#${widget.tags[2 * rowIndex + i]}',
          style: ThemeGlobalText().tag));
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
          itemCount: (widget.tags.length / 2).ceil(),
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
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.content,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              )),
          SizedBox(height: 15),
          widget.isAnswer
              ? Container()
              : widget.images != null &&
                      _storageService.questionImages.containsKey(widget.postId)
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: _storageService
                                .questionImages[widget.postId][index].item2);
                      },
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          _storageService.questionImages[widget.postId].length,
                      shrinkWrap: true)
                  : Container(),
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
                  (_isLiked)
                      ? "assets/img/timeline/like_enabled.png"
                      : "assets/img/timeline/like_disabled.png",
                  scale: 2.5,
                ),
                SizedBox(width: 5),
                Text(
                  widget.reactionsNumber.toString(),
                  style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          widget.answersNumber != null
              ? MaterialButton(
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
                        widget.answersNumber.toString(),
                        style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                )
              : null,
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
                userId: widget.userId,
                userName: widget.username,
                onPressedFunction: null,
                articleDate: widget.date,
              ),
              _buildContent(context),
              widget.tags != null ? _buildTags() : null,
              _buildButtons(context),
            ],
          ),
        ),
      ],
    );
  }
}
