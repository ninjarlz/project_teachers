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
    fillParticipantsConversationData(_selectedConversation);
  }

  void _onConversationListChange(QuerySnapshot event) {
    _conversations = List<ConversationEntity>();
    _hasUnreadMessages = false;
    if (event.documents.length < _conversationsOffset) {
      _hasMoreConversations = false;
    } else {
      _hasMoreConversations = true;
    }
    event.documents.forEach((element) {
      ConversationEntity conversation =
          ConversationEntity.fromJson(element.data);
      if (conversation.lastMsgSenderId != _userService.currentUser.uid &&
          !conversation.lastMsgSeen) {
        _hasUnreadMessages = true;
      }
      conversation.id = element.documentID;
      _conversations.add(conversation);
      fillParticipantsConversationData(conversation);
    });
    _storageService
        .updateUserListProfileImagesWithConversationList(_conversations);
    _conversationPageListeners.forEach((element) {
      element.onConversationListChange();
    });
  }

  void fillParticipantsConversationData(ConversationEntity conversation) {
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
      element.onConversationMessagesChange();
    });
  }

  void _onConversationChange(DocumentSnapshot event) {
    _selectedConversation = ConversationEntity.fromJson(event.data);
    _selectedConversation.id = event.documentID;
    fillParticipantsConversationData(_selectedConversation);
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

  Future<void> transactionUpdateProfileImageData(
      String userId, String userProfileImageName, Transaction transaction) async {
    await _messagingRepository.transactionUpdateProfileImageData(
        userId, userProfileImageName, transaction);
  }

  Future<void> transactionUpdateUserData(
      String userId, String name, String surname, Transaction transaction) async {
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

  Future<void> sendMessage(String text) async {
    if (_selectedConversation == null) {
      _selectedConversation = ConversationEntity([
        _userService.currentUser.uid,
        _userService.selectedCoach.uid
      ], {
        _userService.currentUser.uid: ParticipantEntity(
            _userService.currentUser.profileImageName,
            _userService.currentUser.name,
            _userService.currentUser.surname),
        _userService.selectedCoach.uid: ParticipantEntity(
            _userService.selectedCoach.profileImageName,
            _userService.selectedCoach.name,
            _userService.selectedCoach.surname)
      }, null, null, null, false);
      _selectedConversation.otherParticipantId = _userService.selectedCoach.uid;
      _selectedConversation.otherParticipantData = _selectedConversation
          .participantsData[_userService.selectedCoach.uid];
      _selectedConversation.currentUserData =
          _selectedConversation.participantsData[_userService.currentUser.uid];
      _selectedConversation.id = ConversationEntity.getConversationId(
          _userService.currentUser.uid, _userService.selectedCoach.uid);
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
