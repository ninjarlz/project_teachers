import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/entities/messaging/message_entity.dart';
import 'package:project_teachers/entities/participant_entity.dart';

class MessagingRepository {
  static const String DB_ERROR_MSG = "An error with database occured: ";
  static const String CONVERSATIONS_COLLECTION_NAME = "Conversations";
  static const String MESSAGES_COLLECTION_NAME = "Messages";

  MessagingRepository._privateConstructor();

  static MessagingRepository _instance;

  static MessagingRepository get instance {
    if (_instance == null) {
      _instance = MessagingRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._conversationsRef = _instance._database.collection(CONVERSATIONS_COLLECTION_NAME);
    }
    return _instance;
  }

  StreamSubscription<QuerySnapshot> _conversationListSub;
  StreamSubscription<QuerySnapshot> _conversationMessagesSub;
  StreamSubscription<DocumentSnapshot> _conversationSub;
  CollectionReference _conversationsRef;
  Firestore _database;

  void cancelConversationListSubscription() {
    if (_conversationListSub != null) {
      _conversationListSub.cancel();
    }
    _conversationListSub = null;
  }

  void cancelConversationSubscription() {
    if (_conversationMessagesSub != null) {
      _conversationMessagesSub.cancel();
    }
    _conversationMessagesSub = null;
    if (_conversationSub != null) {
      _conversationSub.cancel();
    }
    _conversationSub = null;
  }

  void subscribeUserConversations(String userId, int limit, Function onConversationListChange) {
    cancelConversationListSubscription();
    Query query = _conversationsRef
        .where(ConversationEntity.PARTICIPANTS_DATA_FIELD_NAME, arrayContains: userId)
        .limit(limit)
        .orderBy(ConversationEntity.LAST_MSG_TIMESTAMP_FIELD_NAME, descending: true);
    _conversationListSub = query.snapshots().listen(onConversationListChange);
    _conversationListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  void subscribeConversation(String conversationId, int limit, Function onConversationMessagesChange,
      Function onConversationChange) {
    cancelConversationSubscription();
    _conversationMessagesSub = _conversationsRef
        .document(conversationId)
        .collection(MESSAGES_COLLECTION_NAME)
        .limit(limit)
        .orderBy(MessageEntity.TIMESTAMP_FIELD_NAME, descending: true)
        .snapshots()
        .listen(onConversationMessagesChange);
    _conversationMessagesSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
    _conversationSub = _conversationsRef.document(conversationId).snapshots().listen(onConversationChange);
    _conversationSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  Future<void> updateConversation(ConversationEntity conversation) async {
    await _conversationsRef.document(conversation.id).setData(conversation.toJson());
  }

  Future<void> addConversationMessage(String conversationId, MessageEntity message) async {
    await _database.runTransaction(await (Transaction transaction) async {
      transaction.set(_conversationsRef.document(conversationId).collection(MESSAGES_COLLECTION_NAME).document(),
          message.toJson());
      transaction.update(_conversationsRef.document(conversationId), {
        ConversationEntity.LAST_MSG_TIMESTAMP_FIELD_NAME: message.timestamp,
        ConversationEntity.LAST_MSG_SENDER_ID_FIELD_NAME: message.senderId,
        ConversationEntity.LAST_MSG_TEXT_FIELD_NAME: message.text,
        ConversationEntity.LAST_MSG_SEEN_FIELD_NAME: false
      });
    });
  }

  Future<void> transactionUpdateProfileImageData(
      String userId, String userProfileImageName, Transaction transaction) async {
    QuerySnapshot querySnapshot =
        await _conversationsRef.where(ConversationEntity.PARTICIPANTS_FIELD_NAME, arrayContains: userId).getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      await transaction.update(documentSnapshot.reference, {
        ConversationEntity.PARTICIPANTS_DATA_FIELD_NAME + "." + userId + "." +
            ParticipantEntity.PROFILE_IMAGE_NAME_FIELD_NAME: userProfileImageName
      });
    }
  }

  Future<void> transactionUpdateUserData(String userId, String name, String surname, Transaction transaction) async {
    QuerySnapshot querySnapshot =
        await _conversationsRef.where(ConversationEntity.PARTICIPANTS_FIELD_NAME, arrayContains: userId).getDocuments();
    for (DocumentSnapshot documentSnapshot in querySnapshot.documents) {
      await transaction.update(documentSnapshot.reference, {
        ConversationEntity.PARTICIPANTS_DATA_FIELD_NAME + "." + userId + "." + ParticipantEntity.NAME_FIELD_NAME: name,
        ConversationEntity.PARTICIPANTS_DATA_FIELD_NAME + "." + userId + "." + ParticipantEntity.SURNAME_FIELD_NAME:
            name
      });
    }
  }

  Future<void> markConversationLastMsgAsSeen(String conversationId) async {
    await _database.runTransaction(await (Transaction transaction) async {
      await transaction
          .update(_conversationsRef.document(conversationId), {ConversationEntity.LAST_MSG_SEEN_FIELD_NAME: true});
    });
  }

  Future<ConversationEntity> getConversation(String conversationId) async {
    DocumentSnapshot conversationSnapshot = await _conversationsRef.document(conversationId).get();
    if (!conversationSnapshot.exists) {
      return null;
    }
    ConversationEntity conversation = ConversationEntity.fromSnapshot(conversationSnapshot);
    conversation.id = conversationId;
    return conversation;
  }
}
