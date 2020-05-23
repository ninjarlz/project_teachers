import 'package:flutter/material.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Timeline extends StatefulWidget {
  static FloatingActionButton timelineFloatingActionButton(
      BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          AppStateManager appStateManager =
          Provider.of<AppStateManager>(context, listen: false);
          appStateManager.changeAppState(AppState.POST_QUESTION);
        },
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.add));
  }

  @override
  State<StatefulWidget> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline>
    implements QuestionListListener, UserListProfileImagesListener {
  TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;
  TimelineService _timelineService;
  StorageService _storageService;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _timelineService = TimelineService.instance;
    _storageService = StorageService.instance;
    _timelineService.questionListListeners.add(this);
    _storageService.userListProfileImageListeners.add(this);
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreQuestions();
      }
    });
  }

  void _searchFilter() {}

  Future<void> _loadMoreQuestions() async {
    if (!_timelineService.hasMoreQuestions || _isLoading) {
      return;
    }
    _timelineService.updateQuestionList();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(color: ThemeGlobalColor().containerColor),
      child: Column(
        children: [
          Container(
            decoration: new BoxDecoration(color: Colors.white),
            padding: EdgeInsets.only(left: 20, top: 10, right: 20),
            child: InputSearchWidget(
              ctrl: _searchCtrl,
              submitChange: _searchFilter,
            ),
          ),
          Expanded(
            child: _timelineService.questions == null ||
                    _timelineService.questions.length == 0
                ? Center(
                    child: Text(
                        Translations.of(context).text("no_results") + "..."),
                  )
                : ListView.builder(
                    itemCount: _timelineService.questions.length,
                    itemBuilder: (context, index) {
                      QuestionEntity question =
                          _timelineService.questions[index];
                      return CardArticleWidget(
                          userId: question.authorId,
                          username: question.authorData.name +
                              " " +
                              question.authorData.surname,
                          content: question.content,
                          date: DateFormat('dd MMM kk:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  question.timestamp.millisecondsSinceEpoch)),
                          reactionsNumber: question.reactionsCounter,
                          answersNumber: question.answersCounter,
                          images: question.photoNames,
                          tags: question.tags);
                    },
                  ),
          ),
          _isLoading
              ? Text(
                  Translations.of(context).text("loading") + "...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  void onQuestionListChange() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timelineService.questionListListeners.remove(this);
    _storageService.userListProfileImageListeners.remove(this);
  }

  @override
  void onUserListProfileImagesChange(List<String> updatedUsersIds) {
    setState(() {});
  }
}
