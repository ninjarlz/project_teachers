import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/participant_entity.dart';
import 'package:project_teachers/entities/timeline/answer_entity.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/repositories/timeline/timeline_repository.dart';
import 'package:project_teachers/services/filtering/base_filtering_service.dart';
import 'package:project_teachers/services/filtering/question_filtering_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/tag_service.dart';
import 'package:project_teachers/services/managers/transaction_manager.dart';
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
      _instance._tagService = TagService.instance;
      _instance._transactionManager = TransactionManager.instance;
    }
    return _instance;
  }

  QuestionEntity _selectedQuestion;

  QuestionEntity get selectedQuestion => _selectedQuestion;

  QuestionEntity editedQuestion;

  AnswerEntity editedAnswer;

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

  bool _hasUnreadAnswers = false;

  bool get hasUnreadAnswers => _hasUnreadAnswers;

  TimelineRepository _timelineRepository;
  UserService _userService;
  StorageService _storageService;
  BaseFilteringService _filteringService;
  TagService _tagService;
  TransactionManager _transactionManager;

  void setSelectedQuestion(QuestionEntity question) {
    _selectedQuestion = question;
  }

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
    _hasMoreQuestions = event.documents.length >= _questionsOffset;
    event.documents.forEach((element) {
      QuestionEntity question = QuestionEntity.fromJson(element.data);
      question.id = element.documentID;
      question.authorData.id = question.authorId;
      _questions.add(question);
    });
    _storageService.updateUserListProfileImagesWithQuestions(_questions);
    _storageService.updateQuestionListImages(questions);
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

  void _onUserQuestionListChange(QuerySnapshot event) {
    _userQuestions = List<QuestionEntity>();
    _hasUnreadAnswers = false;
    _hasMoreUserQuestions = event.documents.length >= _userQuestionsOffset;
    event.documents.forEach((element) {
      QuestionEntity question = QuestionEntity.fromJson(element.data);
      _hasUnreadAnswers = question.authorId == _userService.currentUser.uid &&
          question.lastAnswerSeenByAuthor == false;
      question.id = element.documentID;
      question.authorData.id = question.authorId;
      _userQuestions.add(question);
    });
    _storageService.updateQuestionListImages(_userQuestions);
    for (UserQuestionListListener questionListListener
        in _userQuestionListListeners) {
      questionListListener.onUserQuestionListChange();
    }
  }

  void updateUserQuestionList() {
    _userQuestionsOffset += _userQuestionsLimit;
    Query query = _timelineRepository
        .getUserQuestionsQuery(_userService.currentUser.uid)
        .orderBy("lastAnswerSeenByAuthor")
        .orderBy("timestamp", descending: true)
        .limit(_userQuestionsOffset);
    _timelineRepository.subscribeUserQuestions(
        query, _onUserQuestionListChange);
  }

  Future<void> sendQuestionAnswer(
      String answerId, String text, List<String> photoNames) async {
    await _timelineRepository.sendQuestionAnswer(
        _selectedQuestion,
        answerId,
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

  Future<void> updateAnswer(String questionId, String answerId, String content,
      List<String> photoNames) async {
    await _timelineRepository.updateAnswer(
        questionId, answerId, content, photoNames);
  }

  Future<void> updateQuestion(
      String questionId,
      String content,
      List<String> tags,
      SchoolSubject schoolSubject,
      List<String> photoNames,
      List<String> tagsToPost,
      List<String> tagsToRemove) async {
    await _transactionManager
        .runTransaction(await (Transaction transaction) async {
      await _tagService.transactionPostAndRemoveTags(
          tagsToRemove, tagsToPost, transaction);
      await _timelineRepository.transactionUpdateQuestion(
          questionId, content, tags, schoolSubject, photoNames, transaction);
    });
  }

  void _onQuestionAnswersChange(QuerySnapshot event) {
    _selectedQuestionAnswers = List<AnswerEntity>();
    _hasMoreAnswers = event.documents.length >= _answersOffset;
    event.documents.forEach((element) {
      AnswerEntity answer = AnswerEntity.fromJson(element.data);
      answer.id = element.documentID;
      _selectedQuestionAnswers.add(answer);
    });
    _storageService
        .updateUserListProfileImagesWithAnswers(_selectedQuestionAnswers);
    _storageService.updateAnswerListImages(_selectedQuestionAnswers);
    _questionListeners.forEach((element) {
      element.onQuestionChange();
    });
  }

  void _onQuestionChange(DocumentSnapshot event) {
    _selectedQuestion = QuestionEntity.fromJson(event.data);
    _selectedQuestion.id = event.documentID;
    if (!_selectedQuestion.lastAnswerSeenByAuthor &&
        _selectedQuestion.authorId == _userService.currentUser.uid) {
      markQuestionLastAnswerAsSeen(_selectedQuestion.id);
    }
    _questionListeners.forEach((element) {
      element.onQuestionChange();
    });
  }

  Future<void> updateAnswersList() async {
    _answersOffset += _answersLimit;
    _timelineRepository.subscribeQuestion(_selectedQuestion, _answersOffset,
        _onQuestionAnswersChange, _onQuestionChange);
  }

  String generatePostId() {
    return _timelineRepository.generatePostId();
  }

  Future<void> markQuestionLastAnswerAsSeen(String questionId) async {
    await _timelineRepository.markQuestionLastAnswerAsSeen(questionId);
  }

  Future<void> sendQuestion(String questionId, String content,
      SchoolSubject subject, List<String> tags, List<String> photoNames) async {
    await _transactionManager
        .runTransaction(await (Transaction transaction) async {
      await _tagService.transactionPostTags(tags, transaction);
      await _timelineRepository.transactionSendQuestion(
          questionId,
          QuestionEntity(
              _userService.currentUser.uid,
              ParticipantEntity(
                  _userService.currentUser.profileImageName,
                  _userService.currentUser.name,
                  _userService.currentUser.surname),
              Timestamp.now(),
              content,
              0,
              0,
              photoNames,
              subject,
              tags,
              true),
          transaction);
    });
  }

  Future<void> transactionUpdateProfileImageData(String userId,
      String userProfileImageName, Transaction transaction) async {
    await _timelineRepository.transactionUpdateProfileImageData(
        userId, userProfileImageName, transaction);
  }

  Future<void> transactionUpdateUserData(String userId, String name,
      String surname, Transaction transaction) async {
    await _timelineRepository.transactionUpdateUserData(
        userId, name, surname, transaction);
  }

  Future<void> addQuestionReaction(String questionId) async {
    _transactionManager.runTransaction(await (Transaction transaction) async {
      bool isLiked = await _userService.transactionCheckIfPostIsLiked(
          questionId, transaction);
      if (!isLiked) {
        await _userService.transactionAddLikedPost(questionId, transaction);
        await _timelineRepository.transactionAddQuestionReaction(
            questionId, transaction);
      }
    });
  }

  Future<void> removeQuestionReaction(String questionId) async {
    _transactionManager.runTransaction(await (Transaction transaction) async {
      bool isLiked = await _userService.transactionCheckIfPostIsLiked(
          questionId, transaction);
      if (isLiked) {
        await _userService.transactionRemoveLikedPost(questionId, transaction);
        await _timelineRepository.transactionRemoveQuestionReaction(
            questionId, transaction);
      }
    });
  }

  Future<void> addAnswerReaction(String answerId) async {
    await _transactionManager
        .runTransaction(await (Transaction transaction) async {
      bool isLiked = await _userService.transactionCheckIfPostIsLiked(
          answerId, transaction);
      if (!isLiked) {
        await _userService.transactionAddLikedPost(answerId, transaction);
        await _timelineRepository.transactionAddAnswerReaction(
            _selectedQuestion, answerId, transaction);
      }
    });
  }

  Future<void> removeAnswerReaction(String answerId) async {
    _transactionManager.runTransaction(await (Transaction transaction) async {
      bool isLiked = await _userService.transactionCheckIfPostIsLiked(
          answerId, transaction);
      if (isLiked) {
        await _userService.transactionRemoveLikedPost(answerId, transaction);
        await _timelineRepository.transactionRemoveAnswerReaction(
            _selectedQuestion, answerId, transaction);
      }
    });
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
