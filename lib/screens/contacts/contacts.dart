import 'package:flutter/material.dart';
import 'package:project_teachers/entities/conversation_entity.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/messaging_service.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Contacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts>
    implements CoachListProfileImagesListener, ConversationPageListener {
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
    _storageService.coachListProfileImageListeners.add(this);
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
          child: _storageService.coachImages
                  .containsKey(conversation.otherParticipantId)
              ? _storageService
                  .coachImages[conversation.otherParticipantId].item2
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
            ? Text(
                "\u2022 " +
                    DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(conversation
                            .lastMsgTimestamp.millisecondsSinceEpoch)) +
                    " - " +
                    conversation.lastMsgText,
                style: ThemeGlobalText().boldSmallText,
              )
            : Text(
                DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(conversation
                            .lastMsgTimestamp.millisecondsSinceEpoch)) +
                    " - " +
                    (conversation.lastMsgSenderId ==
                            _userService.currentUser.uid
                        ? Translations.of(context).text("you") +
                            ": " +
                            conversation.lastMsgText
                        : conversation.lastMsgText),
                style: ThemeGlobalText().smallText,
              ),
        onTap: () {
          _messagingService.setSelectedConversation(conversation);
          _appStateManager.changeAppState(AppState.CHAT);
        });
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
    _storageService.coachListProfileImageListeners.remove(this);
  }

  @override
  void onCoachListProfileImagesChange() {
    setState(() {});
  }

  @override
  void onConversationListChange() {
    setState(() {
      _isLoading = false;
    });
  }
}
