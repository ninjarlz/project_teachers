import 'package:flutter/material.dart';
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
    implements
        QuestionListListener,
        UserListProfileImagesListener,
        QuestionsListImagesListener,
        UserListener {
  bool _isLoading = false;
  TimelineService _timelineService;
  UserService _userService;
  StorageService _storageService;
  ScrollController _scrollController = ScrollController();
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _timelineService = TimelineService.instance;
    _storageService = StorageService.instance;
    _userService = UserService.instance;
    _timelineService.questionListListeners.add(this);
    _storageService.userListProfileImageListeners.add(this);
    _storageService.questionsListImagesListener.add(this);
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreQuestions();
      }
    });
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  Future<void> _loadMoreQuestions() async {
    if (!_timelineService.hasMoreQuestions || _isLoading) {
      return;
    }
    _timelineService.updateQuestionList();
    setState(() {
      _isLoading = true;
    });
  }

  void _onEdit(QuestionEntity questionEntity) {
    _timelineService.editedQuestion = questionEntity;
    _appStateManager.changeAppState(AppState.EDIT_QUESTION);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(color: ThemeGlobalColor().containerColor),
      child: Column(
        children: [
          Expanded(
            child: _timelineService.questions == null ||
                    _timelineService.questions.length == 0
                ? Center(
                    child: Text(
                        Translations.of(context).text("no_results") + "..."),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _timelineService.questions.length,
                    itemBuilder: (context, index) {
                      QuestionEntity question =
                          _timelineService.questions[index];
                      return CardArticleWidget(
                        lastAnswerSeenByAuthor: question.lastAnswerSeenByAuthor,
                        goToPost: () {
                          _timelineService.setSelectedQuestion(question);
                          _appStateManager
                              .changeAppState(AppState.QUESTION_ANSWERS);
                        },
                        isEditable:
                            question.authorId == _userService.currentUser.uid,
                        onEdit: () {
                          _onEdit(question);
                        },
                        userId: question.authorId,
                        postId: question.id,
                        isAnswer: false,
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
                        tags: question.tags,
                        subjectsTranslation: Translations.of(context)
                            .text(question.schoolSubject.label),
                      );
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
    _storageService.questionsListImagesListener.remove(this);
    _storageService.userListProfileImageListeners.remove(this);
  }

  @override
  void onUserListProfileImagesChange(List<String> updatedUsersIds) {
    List<String> usersIds =
        _timelineService.questions.map((e) => e.authorId).toList();
    String id = usersIds.firstWhere(
        (element) => updatedUsersIds.contains(element),
        orElse: () => null);
    if (id != null) {
      setState(() {});
    }
  }

  @override
  void onQuestionListImagesChange(List<String> updatedQuestions) {
    List<String> questionIds =
        _timelineService.questions.map((e) => e.id).toList();
    String id = questionIds.firstWhere(
        (element) => updatedQuestions.contains(element),
        orElse: () => null);
    if (id != null) {
      setState(() {});
    }
  }

  @override
  void onUserDataChange() {
    setState(() {});
  }
}
