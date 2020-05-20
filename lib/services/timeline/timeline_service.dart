import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/participant_entity.dart';
import 'package:project_teachers/entities/timeline/answer_entity.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/repositories/timeline/timeline_repository.dart';
import 'package:project_teachers/services/filtering/base_filtering_service.dart';
import 'package:project_teachers/services/filtering/question_filtering_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';

class TimelineService {
  TimelineService._privateConstructor();

  static TimelineService _instance;

  static TimelineService get instance {
    if (_instance == null) {
      _instance = TimelineService._privateConstructor();
      _instance._timelineRepository = TimelineRepository.instance;
      _instance._storageService = StorageService.instance;
      _instance._userService = UserService.instance;
      _instance._filteringService = QuestionFilteringService.instance;
    }
    return _instance;
  }

  QuestionEntity _selectedQuestion;

  QuestionEntity get selectedQuestion => _selectedQuestion;

  List<QuestionEntity> _questions;

  List<QuestionEntity> get questions => _questions;

  bool _hasMoreQuestions = true;

  bool get hasMoreQuestions => _hasMoreQuestions;
  int _questionsLimit = 20;
  int _questionsOffset = 0;

  List<QuestionEntity> _userQuestions;

  List<QuestionEntity> get userQuestions => _userQuestions;
  bool _hasMoreUserQuestions = true;

  bool get hasMoreUserQuestions => _hasMoreUserQuestions;
  int _userQuestionsLimit = 20;
  int _userQuestionsOffset = 0;

  List<AnswerEntity> _selectedQuestionAnswers;

  List<AnswerEntity> get selectedQuestionAnswers => _selectedQuestionAnswers;

  bool _hasMoreAnswers = false;

  bool get hasMoreAnswers => _hasMoreAnswers;
  int _answersLimit = 20;
  int _answersOffset = 0;

  List<QuestionListListener> _questionListListeners =
  List<QuestionListListener>();

  List<QuestionListListener> get questionListListeners =>
      _questionListListeners;

  List<UserQuestionListListener> _userQuestionListListeners =
  List<UserQuestionListListener>();

  List<UserQuestionListListener> get userQuestionListListeners =>
      _userQuestionListListeners;

  List<QuestionListener> _questionListeners = List<QuestionListener>();

  List<QuestionListener> get questionListeners => _questionListeners;

  TimelineRepository _timelineRepository;
  UserService _userService;
  StorageService _storageService;
  BaseFilteringService _filteringService;

  void loginUser() {
    updateQuestionList();
    updateUserQuestionList();
  }

  void logoutUser() {
    resetQuestionList();
    resetUserQuestionList();
    resetAnswerList();
  }

  void resetQuestionList() {
    _questionsOffset = 0;
    if (_questions != null) {
      _questions.clear();
    }
    _hasMoreQuestions = true;
    _timelineRepository.cancelQuestionListSubscription();
  }

  void resetUserQuestionList() {
    _userQuestionsOffset = 0;
    if (_userQuestions != null) {
      _userQuestions.clear();
    }
    _hasMoreUserQuestions = true;
    _timelineRepository.cancelUserQuestionListSubscription();
  }

  void resetAnswerList() {
    _answersOffset = 0;
    if (_selectedQuestionAnswers != null) {
      _selectedQuestion = null;
      _selectedQuestionAnswers.clear();
    }
    _hasMoreAnswers = true;
    _timelineRepository.cancelQuestionSubscription();
  }

  void _onQuestionListChange(QuerySnapshot event) {
    _questions = List<QuestionEntity>();
    if (event.documents.length < _questionsOffset) {
      _hasMoreQuestions = false;
    } else {
      _hasMoreQuestions = true;
    }
    event.documents.forEach((element) {
      QuestionEntity question = QuestionEntity.fromJson(element.data);
      question.id = element.documentID;
      question.authorData.id = question.authorId;
      _questions.add(question);
    });
    _storageService.updateUserListProfileImagesWithQuestions(_questions);
    for (QuestionListListener questionListListener in _questionListListeners) {
      questionListListener.onQuestionListChange();
    }
  }

  void updateQuestionList() {
    _questionsOffset += _questionsLimit;
    Query query = _timelineRepository.questionsRef.limit(_questionsOffset);
    query = _filteringService.prepareQuery(query);
    _timelineRepository.subscribeQuestions(query, _onQuestionListChange);
  }

  void updateUserQuestionList() {}

  Future<void> sendQuestionAnswer(String text, List<String> photoNames) async {
    await _timelineRepository.sendQuestionAnswer(
        _selectedQuestion,
        AnswerEntity(
            _userService.currentUser.uid,
            ParticipantEntity(
                _userService.currentUser.profileImageName,
                _userService.currentUser.name,
                _userService.currentUser.surname),
            Timestamp.now(),
            text,
            0,
            photoNames));
  }

  Future<void> updateProfileImageData(
      String userId, String userProfileImageName) async {
    await _timelineRepository.updateProfileImageData(
        userId, userProfileImageName);
  }

  Future<void> updateUserData(
      String userId, String name, String surname) async {
    await _timelineRepository.updateUserData(userId, name, surname);
  }



}

abstract class QuestionListListener {
  void onQuestionListChange();
}

abstract class UserQuestionListListener {
  void onUserQuestionListChange();
}

abstract class QuestionListener {
  void onQuestionAnswersChange();

  void onQuestionChange();
}
