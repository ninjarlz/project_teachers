import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_teachers/services/filtering/question_filtering_service.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/article/index.dart';
import 'package:project_teachers/widgets/pills/pill_profile.dart';
import 'package:provider/provider.dart';

class CardArticleWidget extends StatefulWidget {
  final String userId;
  final String postId;
  final bool isAnswer;
  final String username;
  final String content;
  final String date;
  final Function goToPost;
  final String subjectsTranslation;
  final List<String> tags;
  final List<String> images;
  final int reactionsNumber;
  final int answersNumber;
  final bool isEditable;
  final Function onEdit;
  final bool lastAnswerSeenByAuthor;

  CardArticleWidget(
      {@required this.userId,
      @required this.username,
      @required this.postId,
      @required this.isAnswer,
      @required this.content,
      @required this.date,
      this.goToPost,
      this.subjectsTranslation,
      this.tags,
      this.images,
      @required this.reactionsNumber,
      this.answersNumber,
      this.isEditable = false,
      this.onEdit,
      this.lastAnswerSeenByAuthor});

  @override
  State<StatefulWidget> createState() {
    return _CardArticleState();
  }
}

class _CardArticleState extends State<CardArticleWidget> {
  StorageService _storageService;
  TimelineService _timelineService;
  UserService _userService;
  QuestionFilteringService _filteringService;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService.instance;
    _timelineService = TimelineService.instance;
    _userService = UserService.instance;
    _filteringService = QuestionFilteringService.instance;
  }

  Future<void> _updateLike() async {
    if (!_userService.currentUser.likedPosts.contains(widget.postId)) {
      if (widget.userId == _userService.currentUser.uid) {
        Fluttertoast.showToast(
            msg: Translations.of(context).text("like_own_post"));
        return;
      }
      if (!widget.isAnswer) {
        await _timelineService.addQuestionReaction(widget.postId);
      } else {
        await _timelineService.addAnswerReaction(widget.postId);
      }
    } else {
      if (!widget.isAnswer) {
        await _timelineService.removeQuestionReaction(widget.postId);
      } else {
        await _timelineService.removeAnswerReaction(widget.postId);
      }
    }
  }

  Widget _buildTagsRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 2 && (2 * rowIndex + i) < widget.tags.length; i++) {
      _rowElements.add(GestureDetector(
          child: Text('#${widget.tags[2 * rowIndex + i]}',
              style: ThemeGlobalText().tag),
          onTap: () {
            _onTagTapped(widget.tags[2 * rowIndex + i]);
          }));
    }
    return Row(children: _rowElements);
  }

  void _onTagTapped(String tag) {
    _filteringService.resetFilters();
    _filteringService.selectedTag = tag;
    _filteringService.orderingField = _filteringService.orderingValues[0];
    _timelineService.resetQuestionList();
    _timelineService.updateQuestionList();
    Provider.of<AppStateManager>(context, listen: false)
        .changeAppState(AppState.TIMELINE);
  }

  Widget _buildSubjectRow() {
    if (widget.subjectsTranslation == Translations.of(context).text("none")) {
      return Container();
    }
    return Align(
        alignment: Alignment.centerLeft,
        child: PillProfileWidget(
          text: widget.subjectsTranslation,
          color: ThemeGlobalColor().secondaryColor,
        ));
  }

  Widget _buildWaitingScreen() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
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

  Widget _buildAnswer() {
    return (widget.images != null
        ? _storageService.answerImages.containsKey(widget.postId)
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: _storageService
                          .answerImages[widget.postId][index].item2);
                },
                physics: NeverScrollableScrollPhysics(),
                itemCount: _storageService.answerImages[widget.postId].length,
                shrinkWrap: true)
            : _buildWaitingScreen()
        : Container());
  }

  Widget _buildQuestion() {
    return (widget.images != null
        ? _storageService.questionImages.containsKey(widget.postId)
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: _storageService
                          .questionImages[widget.postId][index].item2);
                },
                physics: NeverScrollableScrollPhysics(),
                itemCount: _storageService.questionImages[widget.postId].length,
                shrinkWrap: true)
            : _buildWaitingScreen()
        : Container());
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
          widget.isAnswer ? _buildAnswer() : _buildQuestion(),
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
            onPressed: _updateLike,
            minWidth: 0,
            child: Row(
              children: <Widget>[
                Image.asset(
                  (_userService.currentUser.likedPosts != null &&
                          _userService.currentUser.likedPosts
                              .contains(widget.postId))
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
                  onPressed: widget.goToPost,
                  minWidth: 0,
                  child: Row(
                    children: <Widget>[
                      !widget.lastAnswerSeenByAuthor &&
                              widget.userId == _userService.currentUser.uid
                          ? Image.asset(
                              "assets/img/timeline/comment2new.png",
                              scale: 2.5,
                            )
                          : Image.asset(
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
              : Container(),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ArticleUserWidget(
                  userId: widget.userId,
                  userName: widget.username,
                  articleDate: widget.date,
                ),
                widget.isEditable
                    ? IconButton(
                        icon: Icon(Icons.edit), onPressed: widget.onEdit)
                    : Container()
              ]),
              _buildContent(context),
              widget.subjectsTranslation != null
                  ? _buildSubjectRow()
                  : Container(),
              widget.tags != null ? _buildTags() : Container(),
              _buildButtons(context),
            ],
          ),
        ),
      ],
    );
  }
}
