import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/screens/edit_profile/initial_form.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/auth_status_manager.dart';
import 'package:project_teachers/services/index.dart';
import 'package:project_teachers/screens/index.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/services/valid_email_address_service.dart';
import 'package:provider/provider.dart';

import 'home.dart';



class Splashscreen extends StatefulWidget {
  static const String routeName = "/splash";

  @override
  State<StatefulWidget> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  UserService _userService;
  ValidEmailAddressService _validEmailAddressService;
  BaseAuth _auth;
  AuthStatusManager _authStatusManager;
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _userService = UserService.instance;
    _validEmailAddressService = ValidEmailAddressService.instance;
    _auth = Auth.instance;
    Future.delayed(Duration.zero, () {
      _authStatusManager  = Provider.of<AuthStatusManager>(context,listen: false);
      _appStateManager = Provider.of<AppStateManager>(context,listen: false);
      _determineLoginState(_auth.currentUser);
    });
  }


  Future<void> _determineLoginState(FirebaseUser user) async {
    if (user != null) {
      if (user.isEmailVerified) {
        bool isInitialized = await _validEmailAddressService
            .checkIfAddressIsInitialized(user.email);
        if (isInitialized) {
          _userService.setCurrentUser(user.uid);
          _authStatusManager.changeAuthState(AuthStatus.LOGGED_IN);
          _appStateManager.changeAppState(AppState.COACH);
        } else {
          _authStatusManager.changeAuthState(AuthStatus.INITIAL_FORM);
          _appStateManager.changeAppState(AppState.INITIAL_FORM);
        }
      } else {
        _authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
        _appStateManager.changeAppState(AppState.LOGIN);
      }
    } else {
      _authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
      _appStateManager.changeAppState(AppState.LOGIN);
    }
  }

  void _loginCallback() {
    _determineLoginState(_auth.currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStatusManager> (
      builder: (context, manager, child) {
        switch (manager.authStatus) {
          case AuthStatus.NOT_DETERMINED:
            return _buildWaitingScreen();
         case AuthStatus.NOT_LOGGED_IN:
            return WillPopScope(
                onWillPop: () async => false,
                child: Login(loginCallback: _loginCallback));
          case AuthStatus.LOGGED_IN:
            return WillPopScope(
                  onWillPop: () async => false,
                  child: Home());
          case AuthStatus.INITIAL_FORM:
            return WillPopScope(onWillPop: () async => false, child: InitialForm());
          default:
            return _buildWaitingScreen();
        }
      },
    );
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
