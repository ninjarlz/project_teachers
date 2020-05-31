import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/screens/chat/chat.dart';
import 'package:project_teachers/screens/coach/coach.dart';
import 'package:project_teachers/screens/connection_lost/connection_lost.dart';
import 'package:project_teachers/screens/contacts/contacts.dart';
import 'package:project_teachers/screens/edit_profile/edit_profile.dart';
import 'package:project_teachers/screens/filter/question_filter_page.dart';
import 'package:project_teachers/screens/filter/user_filter_page.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/screens/profile/coach_profile.dart';
import 'package:project_teachers/screens/profile/user_profile.dart';
import 'package:project_teachers/screens/timeline/post_question.dart';
import 'package:project_teachers/screens/timeline/timeline.dart';
import 'package:project_teachers/screens/timeline/user_questions.dart';
import 'package:project_teachers/services/connection/connection_service.dart';
import 'package:project_teachers/services/filtering/question_filtering_service.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

enum NavBarType { USERS, TIMELINE }

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home>
    implements
        ConversationPageListener,
        CoachListener,
        CoachProfileImageListener,
        UserListProfileImagesListener {
  MessagingService _messagingService;
  StorageService _storageService;
  UserService _userService;
  ConnectionService _connectionService;
  StreamSubscription _connectionChangeStream;

  @override
  void initState() {
    super.initState();
    _messagingService = MessagingService.instance;
    _storageService = StorageService.instance;
    _userService = UserService.instance;
    _connectionService = ConnectionService.instance;
    _connectionChangeStream =
        _connectionService.connectionChange.listen(connectionChanged);
    _messagingService.conversationPageListeners.add(this);
    _storageService.coachProfileImageListeners.add(this);
    _storageService.userListProfileImageListeners.add(this);
    _userService.coachListeners.add(this);
    Future.delayed(Duration.zero, () async {
      connectionChanged(await _connectionService.checkConnection());
    });
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppStateManager>(context).appState;
    Widget body = null;
    Widget appBar = null;
    Widget floatingButton = null;
    bool extendBodyBehindAppBar = false;
    int navBarIndex = 0;
    NavBarType navBarType = null;
    FloatingActionButtonLocation floatingActionButtonLocation = null;

    switch (appState) {
      case AppState.TIMELINE:
        body = Timeline();
        appBar = AppBar(
            title: Text(Translations.of(context).text("timeline"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        floatingButton = Timeline.timelineFloatingActionButton(context);
        navBarIndex = 0;
        navBarType = NavBarType.TIMELINE;
        break;

      case AppState.FILTER_QUESTIONS:
        body = QuestionFilterPage();
        appBar = AppBar(
            title: Text(Translations.of(context).text("filter_questions"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = 1;
        navBarType = NavBarType.TIMELINE;
        break;

      case AppState.USER_TIMELINE:
        body = UserQuestions();
        appBar = AppBar(
            title: Text(Translations.of(context).text("my_posts"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        floatingButton = UserQuestions.timelineFloatingActionButton(context);
        navBarIndex = 2;
        navBarType = NavBarType.TIMELINE;
        break;

      case AppState.POST_QUESTION:
        body = PostQuestion();
        appBar = AppBar(
            title: Text(Translations.of(context).text("post_question"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        floatingButton = PostQuestion.postQuestionFloatingActionButton(context);
        floatingActionButtonLocation = FloatingActionButtonLocation.endTop;
        navBarIndex = -1;
        break;

      case AppState.PROFILE_PAGE:
        body = UserProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("profile"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent);
        floatingButton = UserProfile.buildSpeedDial(context);
        extendBodyBehindAppBar = true;
        navBarIndex = -1;
        break;

      case AppState.COACH:
        body = Coach();
        appBar = AppBar(
            title: Text(Translations.of(context).text("coach"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = 0;
        navBarType = NavBarType.USERS;
        break;

      case AppState.COACH_PROFILE_PAGE:
        body = CoachProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("coach"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent);
        floatingButton =
            CoachProfile.buildCoachProfileFloatingActionButtons(context);
        extendBodyBehindAppBar = true;
        navBarIndex = -1;
        break;

      case AppState.EDIT_PROFILE:
        body = EditProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("edit_profile"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = -1;
        floatingButton = EditProfile.editProfileFloatingActionButton(context);
        floatingActionButtonLocation = FloatingActionButtonLocation.endTop;
        break;

      case AppState.FILTER_COACH:
        body = UserFilterPage();
        appBar = AppBar(
            title: Text(Translations.of(context).text("filter_coaches"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = 1;
        navBarType = NavBarType.USERS;
        break;

      case AppState.CONTACTS:
        body = Contacts();
        appBar = AppBar(
            title: Text(Translations.of(context).text("my_contacts"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = 2;
        navBarType = NavBarType.USERS;
        break;

      case AppState.CHAT:
        ConversationEntity conversation =
            _messagingService.selectedConversation;
        String otherUserId = conversation != null
            ? conversation.otherParticipantId
            : _userService.selectedCoach.uid;
        Map<String, Tuple2<String, Image>> images = _storageService.userImages;
        body = Chat();
        appBar = AppBar(
            title: Row(children: <Widget>[
              Material(
                  elevation: 4.0,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                      width: 45,
                      height: 45,
                      child: images.containsKey(otherUserId)
                          ? images[otherUserId].item2
                          : Image.asset(
                              "assets/img/default_profile_2.png",
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ))),
              Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Text(
                      conversation != null
                          ? conversation.otherParticipantData.name +
                              " " +
                              conversation.otherParticipantData.surname
                          : _userService.selectedCoach.name +
                              " " +
                              _userService.selectedCoach.surname,
                      style: TextStyle(color: Colors.white)))
            ]),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        floatingButton = Chat.chatFloatingActionButton(context);
        floatingActionButtonLocation = FloatingActionButtonLocation.endTop;
        navBarIndex = -1;
        break;

      default:
        body = _buildWaitingScreen();
        navBarIndex = 0;
    }

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      backgroundColor: ThemeGlobalColor().backgroundColor,
      body: body,
      floatingActionButton: floatingButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: _buildNavBar(navBarIndex, context, navBarType),
      drawer: NavigationDrawer(),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  void _goToScreenUsers(int index, BuildContext context) {
    switch (index) {
      case 1:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.FILTER_COACH);
        break;
      case 2:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.CONTACTS);
        break;
      default:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.COACH);
        break;
    }
  }

  void _goToScreenTimeline(int index, BuildContext context) {
    switch (index) {
      case 1:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.FILTER_QUESTIONS);
        break;
      case 2:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.USER_TIMELINE);
        break;
      default:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.TIMELINE);
    }
  }

  Widget _buildNavBar(
      int navBarIndex, BuildContext context, NavBarType navBarType) {
    if (navBarIndex == -1) return null;
    switch (navBarType) {
      case NavBarType.TIMELINE:
        return BottomNavigationBar(
          onTap: (index) {
            _goToScreenTimeline(index, context);
          },
          currentIndex: navBarIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.question_answer),
                title: Text(Translations.of(context).text("posts"))),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_list),
                title: Text(Translations.of(context).text("filter"))),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_pin),
                title: Text(Translations.of(context).text("my_posts"))),
          ],
        );
      default:
        return BottomNavigationBar(
          onTap: (index) {
            _goToScreenUsers(index, context);
          },
          currentIndex: navBarIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.supervised_user_circle),
                title: Text(Translations.of(context).text("suggestions"))),
            BottomNavigationBarItem(
                icon: Icon(Icons.filter_list),
                title: Text(Translations.of(context).text("filter"))),
            BottomNavigationBarItem(
                icon: _messagingService.hasUnreadMessages
                    ? Icon(Icons.sms_failed, color: Colors.red)
                    : Icon(Icons.message),
                title: Text(Translations.of(context).text("my_contacts"))),
          ],
        );
    }
  }

  void connectionChanged(dynamic hasConnection) {
    if (!hasConnection) {
      Navigator.of(context).pushNamed(ConnectionLost.routeName);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messagingService.conversationPageListeners.remove(this);
    _userService.coachListeners.remove(this);
    _storageService.userListProfileImageListeners.remove(this);
    _storageService.coachProfileImageListeners.remove(this);
    _connectionChangeStream.cancel();
  }

  @override
  void onConversationListChange() {
    AppState appState =
        Provider.of<AppStateManager>(context, listen: false).appState;
    if (appState == AppState.CHAT ||
        appState == AppState.COACH ||
        appState == AppState.FILTER_COACH) {
      setState(() {});
    }
  }

  @override
  void onCoachDataChange() {
    if (Provider.of<AppStateManager>(context, listen: false).appState ==
        AppState.CHAT) {
      setState(() {});
    }
  }

  @override
  void onCoachProfileImageChange() {
    if (Provider.of<AppStateManager>(context, listen: false).appState ==
            AppState.CHAT &&
        _messagingService.selectedConversation == null) {
      setState(() {});
    }
  }

  @override
  void onUserListProfileImagesChange(List<String> updatedCoachesIds) {
    if (Provider.of<AppStateManager>(context, listen: false).appState ==
            AppState.CHAT &&
        _messagingService.selectedConversation != null &&
        updatedCoachesIds.contains(
            _messagingService.selectedConversation.otherParticipantId)) {
      setState(() {});
    }
  }
}
