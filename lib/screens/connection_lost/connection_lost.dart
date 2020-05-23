import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/connection/connection_service.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/managers/auth_status_manager.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:provider/provider.dart';

class ConnectionLost extends StatefulWidget {
  static const String routeName = "/connectionLost";

  @override
  State<StatefulWidget> createState() => _ConnectionLostState();
}

class _ConnectionLostState extends State<ConnectionLost> {
  ConnectionService _connectionService;
  StreamSubscription _connectionChangeStream;
  BaseAuth _auth;
  UserService _userService;
  AuthStatusManager _authStatusManager;
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _connectionService = ConnectionService.instance;
    _auth = Auth.instance;
    _userService = UserService.instance;
    _connectionChangeStream =
        _connectionService.connectionChange.listen(connectionChanged);
    Future.delayed(Duration.zero, () {
      _authStatusManager =
          Provider.of<AuthStatusManager>(context, listen: false);
      _appStateManager =
          Provider.of<AppStateManager>(context, listen: false);
    });
  }

  void connectionChanged(dynamic hasConnection) {
    if (hasConnection) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(Translations.of(context).text("connection_lost"),
                    style: TextStyle(color: Colors.white)),
                backgroundColor: ThemeGlobalColor().secondaryColor),
            body: Container(
                padding: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Image.asset("assets/img/connection-lost.png")),
                      Align(
                          alignment: Alignment.center,
                          child: Text(
                              Translations.of(context)
                                  .text("waiting_for_connection"),
                              style: ThemeGlobalText().titleText)),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: ButtonPrimaryWidget(
                              text: Translations.of(context).text("logout"),
                              submit: logout))
                    ]))));
  }

  void logout() {
    _auth.signOut();
    _userService.logoutUser();
    _authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
    _appStateManager.changeAppState(AppState.LOGIN);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _connectionChangeStream.cancel();
  }
}
