import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/entities/messaging/message_entity.dart';
import 'package:project_teachers/entities/participant_entity.dart';
import 'package:project_teachers/repositories/messaging/messaging_repository.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';

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

  bool _hasMoreMessages = false;

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

  bool _hasUnreadMessages = false;

  bool get hasUnreadMessages => _hasUnreadMessages;

  MessagingRepository _messagingRepository;
  UserService _userService;
  StorageService _storageService;

  void setSelectedConversation(ConversationEntity conversation) {
    _selectedConversation = conversation;
    _fillParticipantsConversationData(_selectedConversation);
  }

  void _onConversationListChange(QuerySnapshot event) {
    _conversations = List<ConversationEntity>();
    _hasUnreadMessages = false;
    _hasMoreConversations = event.documents.length >= _conversationsOffset;
    event.documents.forEach((element) {
      ConversationEntity conversation =
          ConversationEntity.fromJson(element.data);
      _hasUnreadMessages =
          conversation.lastMsgSenderId != _userService.currentUser.uid &&
              !conversation.lastMsgSeen;
      conversation.id = element.documentID;
      _conversations.add(conversation);
      _fillParticipantsConversationData(conversation);
    });
    _storageService
        .updateUserListProfileImagesWithConversationList(_conversations);
    _conversationPageListeners.forEach((element) {
      element.onConversationListChange();
    });
  }

  void _fillParticipantsConversationData(ConversationEntity conversation) {
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
  }

  void loginUser() {
    updateConversationList();
  }

  void logoutUser() {
    resetConversationList();
    resetMessagesList();
  }

  Future<void> updateConversationList() async {
    _conversationsOffset += _conversationsLimit;
    _messagingRepository.subscribeUserConversations(
        _userService.currentUser.uid,
        _conversationsOffset,
        _onConversationListChange);
  }

  void _onConversationMessagesChange(QuerySnapshot event) {
    _selectedConversationMessages = List<MessageEntity>();
    _hasMoreMessages = event.documents.length >= _messagesOffset;
    event.documents.forEach((element) {
      MessageEntity message = MessageEntity.fromJson(element.data);
      message.id = element.documentID;
      _selectedConversationMessages.add(message);
    });
    _conversationListeners.forEach((element) {
      element.onConversationMessagesChange();
    });
  }

  void _onConversationChange(DocumentSnapshot event) {
    _selectedConversation = ConversationEntity.fromJson(event.data);
    _selectedConversation.id = event.documentID;
    _fillParticipantsConversationData(_selectedConversation);
    if (selectedConversation.lastMsgSenderId != _userService.currentUser.uid &&
        !selectedConversation.lastMsgSeen) {
      markConversationLastMsgAsSeen(selectedConversation.id);
    }
    _conversationListeners.forEach((element) {
      element.onConversationChange();
    });
  }

  Future<void> updateMessagesList() async {
    _messagesOffset += _messagesLimit;
    _messagingRepository.subscribeConversation(_selectedConversation,
        _messagesOffset, _onConversationMessagesChange, _onConversationChange);
  }

  Future<void> transactionUpdateProfileImageData(String userId,
      String userProfileImageName, Transaction transaction) async {
    await _messagingRepository.transactionUpdateProfileImageData(
        userId, userProfileImageName, transaction);
  }

  Future<void> transactionUpdateUserData(String userId, String name,
      String surname, Transaction transaction) async {
    await _messagingRepository.transactionUpdateUserData(
        userId, name, surname, transaction);
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
    _hasMoreMessages = false;
    _messagingRepository.cancelConversationSubscription();
  }

  ConversationEntity _createNewConversation() {
    ConversationEntity newConversationEntity = ConversationEntity([
      _userService.currentUser.uid,
      _userService.selectedUser.uid
    ], {
      _userService.currentUser.uid: ParticipantEntity(
          _userService.currentUser.profileImageName,
          _userService.currentUser.name,
          _userService.currentUser.surname),
      _userService.selectedUser.uid: ParticipantEntity(
          _userService.selectedUser.profileImageName,
          _userService.selectedUser.name,
          _userService.selectedUser.surname)
    }, null, null, null, false);
    newConversationEntity.otherParticipantId = _userService.selectedUser.uid;
    newConversationEntity.otherParticipantData = newConversationEntity
        .participantsData[_userService.selectedUser.uid];
    newConversationEntity.currentUserData =
    newConversationEntity.participantsData[_userService.currentUser.uid];
    newConversationEntity.id = ConversationEntity.getConversationId(
        _userService.currentUser.uid, _userService.selectedUser.uid);
    return newConversationEntity;
  }

  Future<void> sendMessage(String text) async {
    if (_selectedConversation == null) {
      _selectedConversation = _createNewConversation();
      await _messagingRepository.updateConversation(_selectedConversation);
      await _messagingRepository.sendConversationMessage(_selectedConversation,
          MessageEntity(text, _userService.currentUser.uid, Timestamp.now()));
      updateMessagesList();
    } else {
      _selectedConversation.lastMsgSeen = false;
      await _messagingRepository.sendConversationMessage(_selectedConversation,
          MessageEntity(text, _userService.currentUser.uid, Timestamp.now()));
    }
  }

  Future<void> markConversationLastMsgAsSeen(String conversationId) async {
    await _messagingRepository.markConversationLastMsgAsSeen(conversationId);
  }

  Future<ConversationEntity> getConversation(String otherParticipantId) async {
    return await _messagingRepository.getConversation(
        ConversationEntity.getConversationId(
            _userService.currentUser.uid, otherParticipantId));
  }
}

abstract class ConversationPageListener {
  void onConversationListChange();
}

abstract class ConversationListener {
  void onConversationMessagesChange();

  void onConversationChange();
}
