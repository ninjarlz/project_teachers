import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/screens/coach/coach.dart';
import 'package:project_teachers/screens/edit_profile/edit_profile.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/screens/profile/coach_profile.dart';
import 'package:project_teachers/screens/profile/user_profile.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppStateManager>(context).appState;
    Widget body = null;
    Widget appBar = null;
    Widget floatingButton = null;
    bool extendBodyBehindAppBar = false;

    switch (appState) {

      case AppState.PROFILE_PAGE:
        body = UserProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("profile"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent);
        floatingButton = UserProfile.buildSpeedDial(context);
        extendBodyBehindAppBar = true;
        break;

      case AppState.COACH:
        body = Coach();
        appBar = AppBar(
            title: Text(Translations.of(context).text("coach"), style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        break;

      case AppState.COACH_PROFILE_PAGE:
        body = CoachProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("coach"), style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent);
        floatingButton = CoachProfile.buildSpeedDial(context);
        extendBodyBehindAppBar = true;
        break;

      case AppState.EDIT_PROFILE:
        body = EditProfile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("edit_profile"), style: TextStyle(color: Colors.white)),
            backgroundColor: ThemeGlobalColor().secondaryColor);
        break;

      default:
        body = _buildWaitingScreen();
    }

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      backgroundColor: ThemeGlobalColor().backgroundColor,
      body: body,
      floatingActionButton: floatingButton,
      drawer: NavigationDrawer(),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  
}
