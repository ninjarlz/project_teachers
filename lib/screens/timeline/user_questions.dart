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

class UserQuestions extends StatefulWidget {
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
  State<StatefulWidget> createState() => _UserQuestionsState();
}

class _UserQuestionsState extends State<UserQuestions>
    implements
        UserQuestionListListener,
        QuestionsListImagesListener,
        UserListener,
        UserProfileImageListener {
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
    _timelineService.userQuestionListListeners.add(this);
    _storageService.questionsListImagesListener.add(this);
    _storageService.userProfileImageListeners.add(this);
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

  void _onEdit(QuestionEntity questionEntity) {
    _timelineService.editedQuestion = questionEntity;
    _appStateManager.changeAppState(AppState.EDIT_QUESTION);
  }

  Future<void> _loadMoreQuestions() async {
    if (!_timelineService.hasMoreUserQuestions || _isLoading) {
      return;
    }
    _timelineService.updateUserQuestionList();
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
          Expanded(
            child: _timelineService.userQuestions == null ||
                    _timelineService.userQuestions.length == 0
                ? Center(
                    child: Text(
                        Translations.of(context).text("no_results") + "..."),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _timelineService.userQuestions.length,
                    itemBuilder: (context, index) {
                      QuestionEntity question =
                          _timelineService.userQuestions[index];
                      return CardArticleWidget(
                        lastAnswerSeenByAuthor: question.lastAnswerSeenByAuthor,
                        goToPost: () {
                          _timelineService.setSelectedQuestion(question);
                          _appStateManager
                              .changeAppState(AppState.QUESTION_ANSWERS);
                        },
                        isEditable: true,
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
                        date: DateFormat('dd MMM kk:mm', Translations.of(context).text("lang")).format(
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
  void dispose() {
    super.dispose();
    _timelineService.userQuestionListListeners.remove(this);
    _storageService.questionsListImagesListener.remove(this);
    _storageService.userProfileImageListeners.remove(this);
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

  @override
  void onUserQuestionListChange() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onUserProfileImageChange() {
    setState(() {});
  }
}
