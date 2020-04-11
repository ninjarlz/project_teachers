import 'package:flutter/material.dart';
import 'package:project_teachers/model/app_state_manager.dart';
import 'package:project_teachers/screens/coach/coach.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/screens/profile/profile.dart';
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
        body = Profile();
        appBar = AppBar(
            title: Text(Translations.of(context).text("profile"),
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent);
        floatingButton = FloatingActionButton(
          onPressed: null,
          backgroundColor: ThemeGlobalColor().secondaryColor,
          child: Icon(Icons.message),
        );
        extendBodyBehindAppBar = true;
        break;

      case AppState.COACH:
        body = Coach();
        appBar = AppBar(
            title: Text(Coach.TITLE, style: TextStyle(color: Colors.white)),
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
