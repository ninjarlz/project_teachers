import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/timeline/answer_entity.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';

class TimelineRepository {
  static const String DB_ERROR_MSG = "An error with database occured: ";

  TimelineRepository._privateConstructor();

  static TimelineRepository _instance;

  static TimelineRepository get instance {
    if (_instance == null) {
      _instance = TimelineRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._questionsRef = _instance._database.collection("Questions");
    }
    return _instance;
  }

  StreamSubscription<QuerySnapshot> _questionListSub;
  StreamSubscription<QuerySnapshot> _userQuestionListSub;
  StreamSubscription<QuerySnapshot> _questionAnswersSub;
  StreamSubscription<DocumentSnapshot> _questionSub;

  CollectionReference _questionsRef;

  CollectionReference get questionsRef => _questionsRef;

  Firestore _database;

  void cancelQuestionListSubscription() {
    if (_questionListSub != null) {
      _questionListSub.cancel();
    }
    _questionListSub = null;
  }

  void cancelUserQuestionListSubscription() {
    if (_userQuestionListSub != null) {
      _userQuestionListSub.cancel();
    }
    _userQuestionListSub = null;
  }

  void cancelQuestionSubscription() {
    if (_questionAnswersSub != null) {
      _questionAnswersSub.cancel();
    }
    _questionAnswersSub = null;
    if (_questionSub != null) {
      _questionSub.cancel();
    }
    _questionSub = null;
  }

  void subscribeUserConversations(
      Query query, Function onUserQuestionListChange) {
    cancelUserQuestionListSubscription();
    _userQuestionListSub = query.snapshots().listen(onUserQuestionListChange);
    _userQuestionListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  Query getUserQuestionsQuery(String userId) {
    return _questionsRef.where("authorId", isEqualTo: userId);
  }

  void subscribeQuestions(Query query, Function onQuestionListChange) {
    cancelQuestionListSubscription();
    _questionListSub = query.snapshots().listen(onQuestionListChange);
    _questionListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  void subscribeUserQuestions(Query query, Function onQuestionListChange) {
    cancelUserQuestionListSubscription();
    _userQuestionListSub = query.snapshots().listen(onQuestionListChange);
    _userQuestionListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  void subscribeQuestion(QuestionEntity question, int limit,
      Function onConversationMessagesChange, Function onConversationChange) {
    cancelQuestionSubscription();
    _questionAnswersSub = _questionsRef
        .document(question.id)
        .collection("Answers")
        .limit(limit)
        .orderBy("timestamp")
        .snapshots()
        .listen(onConversationMessagesChange);
    _questionAnswersSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
    _questionSub = _questionsRef
        .document(question.id)
        .snapshots()
        .listen(onConversationChange);
    _questionSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  Future<void> updateQuestion(QuestionEntity question) async {
    await _questionsRef.document(question.id).setData(question.toJson());
  }

  Future<void> addQuestion(QuestionEntity question) async {
    await _questionsRef.add(question.toJson());
  }

  Future<void> deleteQuestion(QuestionEntity question) async {
    await _questionsRef.document(question.id).delete();
  }

  String generatePostId() {
    return _questionsRef.document().documentID;
  }

  Future<void> sendQuestionAnswer(
      QuestionEntity question, String answerId, AnswerEntity answer) async {
    await _database.runTransaction(await (Transaction transaction) async {
      transaction.set(
          _questionsRef
              .document(question.id)
              .collection("Answers")
              .document(answerId),
          answer.toJson());
      transaction.update(_questionsRef.document(question.id),
          {"answersCounter": FieldValue.increment(1)});
    });
  }

  Future<void> transactionSendQuestion(String questionId,
      QuestionEntity question, Transaction transaction) async {
    await transaction.set(
        _questionsRef.document(questionId), question.toJson());
    return questionId;
  }

  Future<void> transactionAddQuestionReaction(
      String questionId, Transaction transaction) async {
    await transaction.update(_questionsRef.document(questionId),
        {"reactionsCounter": FieldValue.increment(1)});
  }

  Future<void> transactionRemoveQuestionReaction(
      String questionId, Transaction transaction) async {
    await transaction.update(_questionsRef.document(questionId),
        {"reactionsCounter": FieldValue.increment(-1)});
  }

  Future<void> transactionAddAnswerReaction(
      QuestionEntity question, String answerId, Transaction transaction) async {
    await transaction.update(
        _questionsRef
            .document(question.id)
            .collection("Answers")
            .document(answerId),
        {"reactionsCounter": FieldValue.increment(1)});
  }

  Future<void> transactionRemoveAnswerReaction(
      QuestionEntity question, String answerId, Transaction transaction) async {
    await transaction.update(
        _questionsRef
            .document(question.id)
            .collection("Answers")
            .document(answerId),
        {"reactionsCounter": FieldValue.increment(-1)});
  }

  Future<void> transactionUpdateProfileImageData(String userId,
      String userProfileImageName, Transaction transaction) async {
    QuerySnapshot querySnapshot =
        await _questionsRef.where("authorId", isEqualTo: userId).getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      await transaction.update(documentSnapshot.reference,
          {"authorData.profileImageName": userProfileImageName});
    }
  }

  Future<void> transactionUpdateUserData(String userId, String name,
      String surname, Transaction transaction) async {
    QuerySnapshot querySnapshot =
        await _questionsRef.where("authorId", isEqualTo: userId).getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      await transaction.update(documentSnapshot.reference,
          {"authorData.name": name, "authorData.surname": surname});
    }
  }
}
