import 'package:flutter/material.dart';
import 'package:project_teachers/entities/timeline/answer_entity.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class QuestionAnswers extends StatefulWidget {
  static Stack questionAnswersFloatingActionButton(BuildContext context) {
    AppStateManager appStateManager =
        Provider.of<AppStateManager>(context, listen: false);

    return Stack(
      children: <Widget>[
        Align(
            alignment:
                Alignment.lerp(Alignment.topRight, Alignment.centerRight, 0.19),
            child: FloatingActionButton(
                onPressed: appStateManager.previousState,
                backgroundColor: ThemeGlobalColor().mainColor,
                child: Icon(Icons.arrow_back))),
        Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
                onPressed: () {
                  appStateManager.changeAppState(AppState.POST_ANSWER);
                },
                backgroundColor: ThemeGlobalColor().mainColor,
                child: Icon(Icons.add))),
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _QuestionAnswersState();
}

class _QuestionAnswersState extends State<QuestionAnswers>
    implements
        QuestionListener,
        UserListProfileImagesListener,
        QuestionsListImagesListener,
        AnswersListImagesListener {
  bool _isLoading = false;
  TimelineService _timelineService;
  StorageService _storageService;
  ScrollController _scrollController = ScrollController();
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _timelineService = TimelineService.instance;
    _storageService = StorageService.instance;
    _storageService.userListProfileImageListeners.add(this);
    _storageService.questionsListImagesListener.add(this);
    _storageService.answersListImagesListener.add(this);
    _timelineService.questionListeners.add(this);
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreAnswers();
      }
    });
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      if (_appStateManager.prevState != AppState.POST_ANSWER) {
        _timelineService.updateAnswersList();
      }
    });
  }

  Future<void> _loadMoreAnswers() async {
    if (!_timelineService.hasMoreAnswers || _isLoading) {
      return;
    }
    _timelineService.updateAnswersList();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listViewContent = List<Widget>();
    if (_timelineService.selectedQuestion != null) {
      listViewContent.add(CardArticleWidget(
        userId: _timelineService.selectedQuestion.authorId,
        postId: _timelineService.selectedQuestion.id,
        isAnswer: false,
        username: _timelineService.selectedQuestion.authorData.name +
            " " +
            _timelineService.selectedQuestion.authorData.surname,
        content: _timelineService.selectedQuestion.content,
        date: DateFormat('dd MMM kk:mm').format(
            DateTime.fromMillisecondsSinceEpoch(_timelineService
                .selectedQuestion.timestamp.millisecondsSinceEpoch)),
        reactionsNumber: _timelineService.selectedQuestion.reactionsCounter,
        answersNumber: _timelineService.selectedQuestion.answersCounter,
        images: _timelineService.selectedQuestion.photoNames,
        tags: _timelineService.selectedQuestion.tags,
        subjectsTranslation: Translations.of(context)
            .text(_timelineService.selectedQuestion.schoolSubject.label),
      ));
    }
    listViewContent.add(Padding(
        padding: EdgeInsets.all(10),
        child: Text(Translations.of(context).text("answers") + ":",
            style: ThemeGlobalText().titleText)));
    if (_timelineService.selectedQuestionAnswers != null &&
        _timelineService.selectedQuestionAnswers.length > 0) {
      listViewContent.addAll(_timelineService.selectedQuestionAnswers
          .map((answer) => CardArticleWidget(
              userId: answer.authorId,
              postId: answer.id,
              isAnswer: true,
              username:
                  answer.authorData.name + " " + answer.authorData.surname,
              content: answer.content,
              date: DateFormat('dd MMM kk:mm').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      answer.timestamp.millisecondsSinceEpoch)),
              reactionsNumber: answer.reactionsCounter,
              images: answer.photoNames))
          .toList());
    } else {
      listViewContent.add(Center(
          child: Text(Translations.of(context).text("no_results") + "...")));
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(color: ThemeGlobalColor().containerColor),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listViewContent.length,
              itemBuilder: (context, index) {
                return listViewContent[index];
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
  void dispose() {
    super.dispose();
    _storageService.userListProfileImageListeners.remove(this);
    _storageService.questionsListImagesListener.remove(this);
    _storageService.answersListImagesListener.remove(this);
    _timelineService.questionListeners.remove(this);
    if (_appStateManager.appState != AppState.POST_ANSWER) {
      _timelineService.resetAnswerList();
    }
  }

  @override
  void onUserListProfileImagesChange(List<String> updatedUsersIds) {
    List<String> usersIds = _timelineService.selectedQuestionAnswers
        .map((a) => a.authorId)
        .toList();
    if (!usersIds.contains(_timelineService.selectedQuestion.authorId)) {
      usersIds.add(_timelineService.selectedQuestion.authorId);
    }
    String id = usersIds.firstWhere(
        (element) => updatedUsersIds.contains(element),
        orElse: () => null);
    if (id != null) {
      setState(() {});
    }
  }

  @override
  void onQuestionListImagesChange(List<String> updatedQuestions) {
    if (updatedQuestions.contains(_timelineService.selectedQuestion.id)) {
      setState(() {});
    }
  }

  @override
  void onQuestionAnswersChange() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onQuestionChange() {
    if (_timelineService.selectedQuestion == null) {
      _appStateManager.previousState();
      return;
    }
    setState(() {});
  }

  @override
  void onAnswerListImagesChange(List<String> updatedAnswers) {
    List<String> answersIds =
        _timelineService.selectedQuestionAnswers.map((a) => a.id).toList();
    String id = answersIds.firstWhere(
        (element) => updatedAnswers.contains(element),
        orElse: () => null);
    if (id != null) {
      setState(() {});
    }
  }
}
