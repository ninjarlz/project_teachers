import 'dart:async';
import 'package:project_teachers/entities/users/user_enums.dart';
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

  Future<void> transactionUpdateQuestion(
      String questionId,
      String content,
      List<String> tags,
      SchoolSubject schoolSubject,
      List<String> photoNames,
      Transaction transaction) async {
    await transaction.update(_questionsRef.document(questionId), {
      "content": content,
      "tags": tags,
      "schoolSubject": schoolSubject.label,
      "photoNames": photoNames
    });
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
      if (answer.authorId != question.authorId) {
        transaction.update(_questionsRef.document(question.id), {
          "answersCounter": FieldValue.increment(1),
          "lastAnswerSeenByAuthor": false
        });
      } else {
        transaction.update(_questionsRef.document(question.id),
            {"answersCounter": FieldValue.increment(1)});
      }
    });
  }

  Future<void> updateAnswer(String questionId, String answerId, String content,
      List<String> photoNames) async {
    await _questionsRef
        .document(questionId)
        .collection("Answers")
        .document(answerId)
        .updateData({"content": content, "photoNames": photoNames});
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
    QuerySnapshot answersQuerySnapshot = await _database
        .collectionGroup("Answers")
        .where("authorId", isEqualTo: userId)
        .getDocuments();
    for (DocumentSnapshot documentSnapshot in answersQuerySnapshot.documents) {
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
    QuerySnapshot answersQuerySnapshot = await _database
        .collectionGroup("Answers")
        .where("authorId", isEqualTo: userId)
        .getDocuments();
    for (DocumentSnapshot documentSnapshot in answersQuerySnapshot.documents) {
      await transaction.update(documentSnapshot.reference,
          {"authorData.name": name, "authorData.surname": surname});
    }
  }

  Future<void> markQuestionLastAnswerAsSeen(String questionId) async {
    await _database.runTransaction(await (Transaction transaction) async {
      await transaction.update(
          _questionsRef.document(questionId), {"lastAnswerSeenByAuthor": true});
    });
  }
}
