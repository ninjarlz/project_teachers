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
    cancelUserQuestionListSubscription();
    _questionListSub = query.snapshots().listen(onQuestionListChange);
    _questionListSub.onError((o) {
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
        .orderBy("timestamp", descending: true)
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

  Future<void> sendQuestionAnswer(
      QuestionEntity question, AnswerEntity answer) async {
    await _database.runTransaction((transaction) async {
      await _questionsRef
          .document(question.id)
          .collection("Answers")
          .add(answer.toJson());
      await transaction.update(_questionsRef.document(question.id),
          {"answersCounter": question.answersCounter + 1});
    });
  }

  Future<void> addQuestionReaction(QuestionEntity question) async {
    await _database.runTransaction((transaction) async {
      await transaction.update(_questionsRef.document(question.id),
          {"answersCounter": question.reactionsCounter + 1});
    });
  }

  Future<void> addAnswerReaction(
      QuestionEntity question, AnswerEntity answer) async {
    await _database.runTransaction((transaction) async {
      await transaction.update(
          _questionsRef
              .document(question.id)
              .collection("Answers")
              .document(answer.id),
          {"answersCounter": answer.reactionsCounter + 1});
    });
  }

  Future<void> updateProfileImageData(
      String userId, String userProfileImageName) async {
    QuerySnapshot querySnapshot =
        await _questionsRef.where("authorId", isEqualTo: userId).getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      await _database.runTransaction((transaction) async {
        await transaction.update(documentSnapshot.reference,
            {"authorData.profileImageName": userProfileImageName});
      });
    }
  }

  Future<void> updateUserData(
      String userId, String name, String surname) async {
    QuerySnapshot querySnapshot =
        await _questionsRef.where("authorId", isEqualTo: userId).getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      await _database.runTransaction((transaction) async {
        await transaction.update(documentSnapshot.reference,
            {"authorData.name": name, "authorData.surname": surname});
      });
    }
  }
}
