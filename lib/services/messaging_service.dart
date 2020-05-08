import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/conversation_entity.dart';
import 'package:project_teachers/entities/message_entity.dart';
import 'package:project_teachers/repositories/messaging_repository.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/services/user_service.dart';

class MessagingService {
  MessagingService._privateConstructor();

  static MessagingService _instance;

  static MessagingService get instance {
    if (_instance == null) {
      _instance = MessagingService._privateConstructor();
      _instance._messagingRepository = MessagingRepository.instance;
      _instance._userService = UserService.instance;
      _instance._storageService = StorageService.instance;
    }
    return _instance;
  }

  ConversationEntity _selectedConversation;

  ConversationEntity get selectedConversation => _selectedConversation;

  List<ConversationEntity> _conversations;

  List<ConversationEntity> get conversations => _conversations;

  bool _hasMoreConversations = true;

  bool get hasMoreConversations => _hasMoreConversations;
  int _conversationsLimit = 20;
  int _conversationsOffset = 0;

  List<MessageEntity> _selectedConversationMessages;

  List<MessageEntity> get selectedConversationMessages =>
      _selectedConversationMessages;

  bool _hasMoreMessages = true;

  bool get hasMoreMessages => _hasMoreMessages;
  int _messagesLimit = 20;
  int _messagesOffset = 0;

  List<ConversationPageListener> _conversationPageListeners =
  List<ConversationPageListener>();

  List<ConversationPageListener> get conversationPageListeners =>
      _conversationPageListeners;

  List<ConversationListener> _conversationListeners =
  List<ConversationListener>();

  List<ConversationListener> get conversationListeners =>
      _conversationListeners;

  List<DocumentReference> _conversationsReferences;

  MessagingRepository _messagingRepository;
  UserService _userService;
  StorageService _storageService;

  void setSelectedConversation(ConversationEntity conversation) {
    _selectedConversation = conversation;
  }

  void _onConversationListChange(QuerySnapshot event) {
    _conversations = List<ConversationEntity>();
    _conversationsReferences = List<DocumentReference>();
    if (event.documents.length < _conversationsOffset) {
      _hasMoreConversations = false;
    } else {
      _hasMoreConversations = true;
    }
    event.documents.forEach((element) {
      ConversationEntity conversation =
      ConversationEntity.fromJson(element.data);
      conversation.id = element.documentID;
      _conversationsReferences.add(element.reference);
      _conversations.add(conversation);
      for (String userId in conversation.participants) {
        if (userId != _userService.currentUser.uid) {
          conversation.otherParticipantId = userId;
          conversation.otherParticipantData =
          conversation.participantsData[userId];
          conversation.otherParticipantData.id = userId;
          break;
        }
      }
      conversation.currentUserData =
      conversation.participantsData[_userService.currentUser.uid];
      conversation.currentUserData.id = _userService.currentUser.uid;
    });

    _storageService
        .updateCoachListProfileImagesWithConversationList(_conversations);
  }

  void loginUser() {
    updateConversationList();
  }

  void logoutUser() {
    resetConversationList();
    _messagingRepository.cancelConversationListSubscription();
  }

  Future<void> updateConversationList() async {
    _conversationsOffset += _conversationsLimit;
    _messagingRepository.subscribeUserConversations(
        _userService.currentUser.uid,
        _conversationsOffset,
        _onConversationListChange);
  }

  void _onConversationChange(QuerySnapshot event) {
    _selectedConversationMessages = List<MessageEntity>();
    if (event.documents.length < _messagesOffset) {
      _hasMoreMessages = false;
    } else {
      _hasMoreMessages = true;
    }
    event.documents.forEach((element) {
      MessageEntity message = MessageEntity.fromJson(element.data);
      message.id = element.documentID;
      _selectedConversationMessages.add(message);
    });
    _conversationListeners.forEach((element) {
      element.onConversationChange();
    });
  }

  Future<void> updateMessagesList() async {
    _messagesOffset += _messagesLimit;
    _messagingRepository.subscribeConversation(
        _selectedConversation, _messagesOffset, _onConversationChange);
  }

  Future<void> updateProfileImageData(String userId,
      String userProfileImageName) async {
    for (int i = 0; i < _conversations.length; i++) {
      await _messagingRepository.updateProfileImageData(
          userId, userProfileImageName, _conversationsReferences[i]);
    }
  }

  Future<void> updateUserData(String userId, String name,
      String surname) async {
    for (int i = 0; i < _conversations.length; i++) {
      await _messagingRepository.updateUserData(
          userId, name, surname, _conversationsReferences[i]);
    }
  }

  void resetConversationList() {
    _conversationsOffset = 0;
    if (_conversations != null) {
      _conversations.clear();
    }
    _hasMoreConversations = true;
    _messagingRepository.cancelConversationListSubscription();
  }

  void resetMessagesList() {
    _messagesOffset = 0;
    if (_selectedConversationMessages != null) {
      _selectedConversation = null;
      _selectedConversationMessages.clear();
    }
    _hasMoreMessages = true;
    _messagingRepository.cancelConversationSubscription();
  }

  void sendMessage(ConversationEntity conversation, String text,
      String senderId) {
    _messagingRepository.sendConversationMessage(
        conversation, MessageEntity(text, senderId, Timestamp.now()));
  }
}

abstract class ConversationPageListener {
  void onConversationListChange();
}

abstract class ConversationListener {
  void onConversationChange();
}
