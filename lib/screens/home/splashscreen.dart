import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/screens/register_and_login/initial_form.dart';
import 'package:project_teachers/services/index.dart';
import 'package:project_teachers/screens/index.dart';

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN, INITIAL_FORM }

enum AppState {
  TIMELINE,
  PROFILE_PAGE,
  COACH,
  EVENTS,
  CALENDAR,
  OTHER_EXPERTS,
  LOGIN,
  INITIAL_FORM
}

// ignore: must_be_immutable
class Splashscreen extends StatefulWidget {
  static const String routeName = "/splash";

  Splashscreen._privateConstructor();

  static Splashscreen _instance;

  static Splashscreen instance() {
    if (_instance == null) {
      _instance = Splashscreen._privateConstructor();
    }
    return _instance;
  }

  AppState currentAppState = AppState.LOGIN;

  @override
  State<StatefulWidget> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  String _userId;
  FirebaseUser _user;
  UserRepository _userRepository;
  ValidEmailAddressRepository _validEmailAddressRepository;
  BaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _validEmailAddressRepository = ValidEmailAddressRepository.instance;
    NavigationDrawer.instance.setLogoutCallback(logoutCallback);
    _auth = Auth.instance;
    _auth.getCurrentUser().then(_determineLoginState);
  }


  Future<void> _determineLoginState(FirebaseUser user) async {
    if (user != null) {
      if (user.isEmailVerified) {
        _userId = user?.uid;
        _user = user;
        bool isInitialized = await _validEmailAddressRepository
            .checkIfAddressIsInitialized(user.email);
        setState(() {
          if (isInitialized != null) {
            _userRepository.setCurrentUser(user.uid);
            _authStatus = AuthStatus.LOGGED_IN;
            widget.currentAppState = AppState.TIMELINE;
          } else {
            _authStatus = AuthStatus.INITIAL_FORM;
            widget.currentAppState = AppState.INITIAL_FORM;
          }
        });
      } else {
        setState(() {
          _authStatus = AuthStatus.NOT_LOGGED_IN;
          widget.currentAppState = AppState.LOGIN;
        });
      }
    } else {
      setState(() {
        _authStatus = AuthStatus.NOT_LOGGED_IN;
        widget.currentAppState = AppState.LOGIN;
      });
    }
  }

  void loginCallback() {
    _auth.getCurrentUser().then(_determineLoginState);
  }

  void logoutCallback() {
    setState(() {
      if (_authStatus == AuthStatus.LOGGED_IN) {
        _userRepository.logoutUser();
      }
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = null;
    });
  }

  void initializedCallback() {
    setState(() {
      _authStatus = AuthStatus.LOGGED_IN;
      widget.currentAppState = AppState.TIMELINE;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return WillPopScope(
            onWillPop: () async => false,
            child: Login(
              auth: _auth,
              loginCallback: loginCallback,
            ));
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId != null && _userId.length > 0) {
          return WillPopScope(
              onWillPop: () async => false,
              child: Home(
                title: "Home",
                userId: _userId,
                auth: _auth,
                logoutCallback: logoutCallback,
              ));
        } else
          return _buildWaitingScreen();
        break;
      case AuthStatus.INITIAL_FORM:
        return WillPopScope(onWillPop: () async => false, child: InitialForm(initializedCallback, logoutCallback, _user));
        break;
      default:
        return _buildWaitingScreen();
    }
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
