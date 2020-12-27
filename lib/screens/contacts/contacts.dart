import 'package:flutter/material.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Contacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts>
    implements UserListProfileImagesListener, ConversationPageListener {
  MessagingService _messagingService;
  UserService _userService;
  StorageService _storageService;
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService.instance;
    _messagingService = MessagingService.instance;
    _userService = UserService.instance;
    _storageService.userListProfileImageListeners.add(this);
    _messagingService.conversationPageListeners.add(this);
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreConversations();
      }
    });
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  Widget _buildRow(int index) {
    ConversationEntity conversation = _messagingService.conversations[index];
    String fullName =
        "${conversation.otherParticipantData.name} ${conversation.otherParticipantData.surname}";
    return ListTile(
        leading: Material(
          child: _storageService.userImages
                  .containsKey(conversation.otherParticipantId)
              ? _storageService
                  .userImages[conversation.otherParticipantId].item2
              : Image.asset(
                  "assets/img/default_profile_2.png",
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
        ),
        contentPadding: EdgeInsets.all(5),
        title: Text(fullName),
        subtitle: !conversation.lastMsgSeen &&
                conversation.lastMsgSenderId != _userService.currentUser.uid
            ? _buildUnseenConversation(conversation)
            : _buildSeenConversation(conversation),
        onTap: () {
          _messagingService.setSelectedConversation(conversation);
          _appStateManager.changeAppState(AppState.CHAT);
        });
  }

  Widget _buildUnseenConversation(ConversationEntity conversation) {
    return Text(
      "\u2022 " +
          DateFormat('dd MMM kk:mm',
              Translations.of(context).text("lang"))
              .format(DateTime.fromMillisecondsSinceEpoch(conversation
              .lastMsgTimestamp.millisecondsSinceEpoch)) +
          " - " +
          conversation.lastMsgText,
      style: ThemeGlobalText().boldSmallText,
    );
  }

  Widget _buildSeenConversation(ConversationEntity conversation) {
    return Text(
      DateFormat('dd MMM kk:mm',
          Translations.of(context).text("lang"))
          .format(DateTime.fromMillisecondsSinceEpoch(conversation
          .lastMsgTimestamp.millisecondsSinceEpoch)) +
          " - " +
          (conversation.lastMsgSenderId ==
              _userService.currentUser.uid
              ? Translations.of(context).text("you") +
              ": " +
              conversation.lastMsgText
              : conversation.lastMsgText),
      style: ThemeGlobalText().smallText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        children: [
          Expanded(
            child: _messagingService.conversations == null ||
                    _messagingService.conversations.length == 0
                ? Center(
                    child: Text(
                        Translations.of(context).text("no_results") + "..."),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messagingService.conversations.length,
                    itemBuilder: (context, index) {
                      return _buildRow(index);
                    },
                  ),
          ),
          _isLoading
              ? Text(
                  Translations.of(context).text("loading") + "...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Future<void> _loadMoreConversations() async {
    if (!_messagingService.hasMoreConversations || _isLoading) {
      return;
    }
    _messagingService.updateConversationList();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messagingService.conversationPageListeners.remove(this);
    _storageService.userListProfileImageListeners.remove(this);
  }

  @override
  void onUserListProfileImagesChange(List<String> updatedUsersIds) {
    List<String> usersIds = _messagingService.conversations
        .map((e) => e.otherParticipantId)
        .toList();
    String id = usersIds.firstWhere(
        (element) => updatedUsersIds.contains(element),
        orElse: () => null);
    if (id != null) {
      setState(() {});
    }
  }

  @override
  void onConversationListChange() {
    setState(() {
      _isLoading = false;
    });
  }
}
