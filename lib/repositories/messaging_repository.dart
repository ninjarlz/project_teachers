import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/conversation_entity.dart';
import 'package:project_teachers/entities/conversation_participant_entity.dart';
import 'package:project_teachers/entities/message_entity.dart';

class MessagingRepository {
  static const String DB_ERROR_MSG = "An error with database occured: ";

  MessagingRepository._privateConstructor();

  static MessagingRepository _instance;

  static MessagingRepository get instance {
    if (_instance == null) {
      _instance = MessagingRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._conversationsRef =
          _instance._database.collection("Conversations");
    }
    return _instance;
  }

  StreamSubscription<QuerySnapshot> _conversationListSub;
  StreamSubscription<QuerySnapshot> _conversationSub;
  CollectionReference _conversationsRef;
  Firestore _database;

  void cancelConversationListSubscription() {
    if (_conversationListSub != null) {
      _conversationListSub.cancel();
    }
    _conversationListSub = null;
  }

  void cancelConversationSubscription() {
    if (_conversationSub != null) {
      _conversationSub.cancel();
    }
    _conversationSub = null;
  }

  void subscribeUserConversations(
      String userId, int limit, Function onConversationListChange) {
//    FOR ADDING TEST DATA
//    for (int i = 0; i < 100; i++) {
//
//      _conversationsRef.document("test test" + (i + 20).toString()).setData(ConversationEntity(["FyRi1nGkcBUHKB4HOuS9WIO8Sex1","test test" + (i + 20).toString()], Timestamp.now(), "test test" + (i + 20).toString(), "elo").toJson());
//      _conversationsRef.document("test test" + (i + 20).toString()).collection("Messages").document("test test" + (i + 20).toString()).setData(MessageEntity("elo", "test test" + (i + 20).toString(), Timestamp.now()).toJson());
//    }
// FOR REMOVING TEST DATA
//    for (int i = 0; i < 100; i++) {
//      _conversationsRef.document("test test" + (i + 20).toString()).collection("Messages").document("test test" + (i + 20).toString()).delete();
//      _conversationsRef.document("test test" + (i + 20).toString()).delete();
//    }

    cancelConversationListSubscription();
    Query query = _conversationsRef
        .where("participants", arrayContains: userId)
        .limit(limit)
        .orderBy("lastMsgTimestamp", descending: true);
    _conversationListSub = query.snapshots().listen(onConversationListChange);
    _conversationListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  void subscribeConversation(ConversationEntity conversation, int limit,
      Function onConversationChange) {
    cancelConversationSubscription();
    _conversationSub = _conversationsRef
        .document(conversation.id)
        .collection("Messages")
        .limit(limit)
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen(onConversationChange);
    _conversationSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  Future<void> updateConversation(ConversationEntity conversation) async {
    await _conversationsRef
        .document(conversation.id)
        .setData(conversation.toJson());
  }

  Future<void> sendConversationMessage(
      ConversationEntity conversation, MessageEntity message) async {
    await _database.runTransaction((transaction) async {
      await _conversationsRef
          .document(conversation.id)
          .collection("Messages")
          .add(message.toJson());
      await transaction.update(_conversationsRef
          .document(conversation.id), {
        "lastMsgTimestamp": message.timestamp,
        "lastMsgSenderId": message.senderId,
        "lastMsgText": message.text
      });
    });
  }

  Future<void> updateProfileImageData(
      String userId,
      String userProfileImageName,
      DocumentReference conversationsReference) async {
    await _database.runTransaction((transaction) async {
      await transaction.update(conversationsReference,
          {"participantsData.$userId.profileImageName": userProfileImageName});
    });
  }

  Future<void> updateUserData(String userId, String name, String surname,
      DocumentReference conversationsReference) async {
    await _database.runTransaction((transaction) async {
      await transaction.update(conversationsReference, {
        "participantsData.$userId.name": name,
        "participantsData.$userId.surname": surname
      });
    });
  }
}
