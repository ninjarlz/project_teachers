import 'package:flutter/material.dart';
import 'package:project_teachers/entities/conversation_entity.dart';
import 'package:project_teachers/screens/chat/chat.dart';
import 'package:project_teachers/screens/coach/coach.dart';
import 'package:project_teachers/screens/contacts/contacts.dart';
import 'package:project_teachers/screens/edit_profile/edit_profile.dart';
import 'package:project_teachers/screens/filter/filter_page.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/screens/profile/coach_profile.dart';
import 'package:project_teachers/screens/profile/user_profile.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/messaging_service.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppStateManager>(context).appState;
    Widget body = null;
    Widget appBar = null;
    Widget floatingButton = null;
    bool extendBodyBehindAppBar = false;
    int navBarIndex = 0;

    switch (appState) {
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
        break;

      case AppState.COACH_PROFILE_PAGE:
        body = CoachProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("coach"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent);
        floatingButton = CoachProfile.buildSpeedDial(context);
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
        break;

      case AppState.FILTER_COACH:
        body = FilterPage();
        appBar = AppBar(
            title: Text(Translations.of(context).text("filter_coaches"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = 1;
        break;

      case AppState.CONTACTS:
        body = Contacts();
        appBar = AppBar(
            title: Text(Translations.of(context).text("my_contacts"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        navBarIndex = 2;
        break;

      case AppState.CHAT:
        ConversationEntity conversation =
            MessagingService.instance.selectedConversation;
        Map<String, Tuple2<String, Image>> images =
            StorageService.instance.coachImages;
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
                      child: images.containsKey(conversation.otherParticipantId)
                          ? images[conversation.otherParticipantId].item2
                          : Image.asset(
                              "assets/img/default_profile_2.png",
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ))),
              Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Text(
                      conversation.otherParticipantData.name +
                          " " +
                          conversation.otherParticipantData.surname,
                      style: TextStyle(color: Colors.white)))
            ]),
            backgroundColor: ThemeGlobalColor().secondaryColor);
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
      bottomNavigationBar: _buildNavBar(navBarIndex, context),
      drawer: NavigationDrawer(),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  void _goToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        Provider.of<AppStateManager>(context, listen: false)
            .changeAppState(AppState.COACH);
        break;
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
    }
  }

  Widget _buildNavBar(int navBarIndex, BuildContext context) {
    if (navBarIndex == -1) return null;
    return BottomNavigationBar(
      onTap: (index) {
        _goToScreen(index, context);
      },
      currentIndex: navBarIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            title: Text("Suggestions")),
        BottomNavigationBarItem(
            icon: Icon(Icons.filter_list), title: Text("Filter")),
        BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text(Translations.of(context).text("my_contacts"))),
      ],
    );
  }
}
