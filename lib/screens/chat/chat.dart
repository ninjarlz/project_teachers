import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_teachers/entities/message_entity.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/messaging_service.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChatState();
}

class _ChatState extends State<Chat>
    implements CoachListProfileImagesListener, ConversationListener {
  MessagingService _messagingService;
  UserService _userService;
  StorageService _storageService;
  TextEditingController _textEditingController = TextEditingController();
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
    _messagingService.conversationListeners.add(this);
    _messagingService.updateMessagesList();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreMessages();
      }
    });
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        children: [
          _isLoading
              ? Text(
                  Translations.of(context).text("loading") + "...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container(),
          Expanded(
            child: _messagingService.selectedConversationMessages == null ||
                    _messagingService.selectedConversationMessages.length == 0
                ? Center()
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount:
                        _messagingService.selectedConversationMessages.length,
                    itemBuilder: (context, index) {
                      return _buildItem(index);
                    },
                  ),
          ),
          _buildInput()
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              child: TextField(
                style: ThemeGlobalText().inputText,
                controller: _textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: Translations.of(context).text("type_your_message") +
                      "...",
                  hintStyle: ThemeGlobalText().hintText,
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
                color: ThemeGlobalColor().mainColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: ThemeGlobalColor().mainColor, width: 0.5)),
          color: Colors.white),
    );
  }

  Future<void> _loadMoreMessages() async {
    if (!_messagingService.hasMoreMessages || _isLoading) {
      return;
    }
    _messagingService.updateMessagesList();
    setState(() {
      _isLoading = true;
    });
  }

  void _sendMessage() {
    if (_textEditingController.text.trim() != "") {
      _messagingService.sendMessage(_messagingService.selectedConversation,
          _textEditingController.text.trim(), _userService.currentUser.uid);
      _textEditingController.text = "";
    } else {
      Fluttertoast.showToast(
          msg: Translations.of(context).text("nothing_to_send"));
    }
  }

  Widget _buildItem(int index) {
    MessageEntity message =
        _messagingService.selectedConversationMessages[index];
    if (message.senderId == _userService.currentUser.uid) {
      // Right (my message)
      return Row(
        children: <Widget>[
          Container(
            child: Text(
              message.text,
              style: ThemeGlobalText().whiteText,
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(
                color: ThemeGlobalColor().secondaryColor,
                borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        elevation: 4.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            width: 45,
                            height: 45,
                            child: _storageService.coachImages
                                    .containsKey(message.senderId)
                                ? _storageService
                                    .coachImages[message.senderId].item2
                                : Image.asset(
                                    "assets/img/default_profile_2.png",
                                    fit: BoxFit.cover,
                                    alignment: Alignment.bottomCenter,
                                  )))
                    : Container(width: 45.0),
                Container(
                  child: Text(
                    message.text,
                    style: ThemeGlobalText().text,
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: ThemeGlobalColor().boxMsgColor,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              message.timestamp.millisecondsSinceEpoch)),
                      style: ThemeGlobalText().smallText,
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            _messagingService.selectedConversationMessages != null &&
            _messagingService
                    .selectedConversationMessages[index - 1].senderId ==
                _userService.currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _messagingService.selectedConversationMessages != null &&
            _messagingService
                    .selectedConversationMessages[index - 1].senderId !=
                _userService.currentUser.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messagingService.conversationListeners.remove(this);
    _storageService.coachListProfileImageListeners.remove(this);
    _messagingService.resetMessagesList();
  }

  @override
  void onCoachListProfileImagesChange() {
    setState(() {
      _isLoading = false; //TODO check if setState itself rebuild widget
    });
  }

  @override
  void onConversationChange() {
    setState(() {
      _isLoading = false;
    });
  }
}
