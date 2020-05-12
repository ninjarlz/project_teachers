import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineRepository {

  TimelineRepository._privateConstructor();
  static TimelineRepository _instance;
  static TimelineRepository get instance {
    if (_instance == null) {
      _instance = TimelineRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._questionsRef =
          _instance._database.collection("Questions");
    }
    return _instance;
  }

  StreamSubscription<QuerySnapshot> _questionListSub;
  StreamSubscription<QuerySnapshot> _userQuestionListSub;
  StreamSubscription<QuerySnapshot> _questionAnswersSub;
  StreamSubscription<DocumentSnapshot> _questionSub;
  CollectionReference _questionsRef;
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

//  void subscribeUserConversations(
//      String userId, int limit, Function onUserQuestionListChange) {
//      cancelUserQuestionListSubscription();
//      Query query = _conversationsRef
//        .where("participants", arrayContains: userId)
//        .limit(limit)
//        .orderBy("lastMsgTimestamp", descending: true);
//    _conversationListSub = query.snapshots().listen(onConversationListChange);
//    _conversationListSub.onError((o) {
//      print(DB_ERROR_MSG + o.message);
//    });
//  }
//
//  void subscribeConversation(ConversationEntity conversation, int limit,
//      Function onConversationMessagesChange, Function onConversationChange) {
//    cancelConversationSubscription();
//    _conversationMessagesSub = _conversationsRef
//        .document(conversation.id)
//        .collection("Messages")
//        .limit(limit)
//        .orderBy("timestamp", descending: true)
//        .snapshots()
//        .listen(onConversationMessagesChange);
//    _conversationMessagesSub.onError((o) {
//      print(DB_ERROR_MSG + o.message);
//    });
//    _conversationSub = _conversationsRef
//        .document(conversation.id)
//        .snapshots()
//        .listen(onConversationChange);
//    _conversationSub.onError((o) {
//      print(DB_ERROR_MSG + o.message);
//    });
//  }
//
//  Future<void> updateConversation(ConversationEntity conversation) async {
//    await _conversationsRef
//        .document(conversation.id)
//        .setData(conversation.toJson());
//  }
//
//  Future<void> sendConversationMessage(
//      ConversationEntity conversation, MessageEntity message) async {
//    await _database.runTransaction((transaction) async {
//      await _conversationsRef
//          .document(conversation.id)
//          .collection("Messages")
//          .add(message.toJson());
//      await transaction.update(_conversationsRef.document(conversation.id), {
//        "lastMsgTimestamp": message.timestamp,
//        "lastMsgSenderId": message.senderId,
//        "lastMsgText": message.text,
//        "lastMsgSeen": false
//      });
//    });
//  }
//
//  Future<void> updateProfileImageData(
//      String userId, String userProfileImageName, String conversationId) async {
//    await _database.runTransaction((transaction) async {
//      await transaction.update(_conversationsRef.document(conversationId),
//          {"participantsData.$userId.profileImageName": userProfileImageName});
//    });
//  }
//
//  Future<void> updateUserData(
//      String userId, String name, String surname, String conversationId) async {
//    await _database.runTransaction((transaction) async {
//      await transaction.update(_conversationsRef.document(conversationId), {
//        "participantsData.$userId.name": name,
//        "participantsData.$userId.surname": surname
//      });
//    });
//  }
//
//  Future<void> markConversationLastMsgAsSeen(String conversationId) async {
//    await _database.runTransaction((transaction) async {
//      await transaction.update(_conversationsRef.document(conversationId), {
//        "lastMsgSeen": true,
//      });
//    });
//  }
//
//
//  Future<ConversationEntity> getConversation(String conversationId) async {
//    DocumentSnapshot conversationSnapshot =
//    await _conversationsRef.document(conversationId).get();
//    if (!conversationSnapshot.exists) {
//      return null;
//    }
//    ConversationEntity conversation =
//    ConversationEntity.fromSnapshot(conversationSnapshot);
//    conversation.id = conversationId;
//    return conversation;
//  }
}