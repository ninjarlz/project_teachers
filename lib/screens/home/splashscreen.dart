import 'package:flutter/material.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/services/index.dart';
import 'package:project_teachers/screens/index.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN
}

class Splashscreen extends StatefulWidget {

  final BaseAuth auth;

  Splashscreen({this.auth});

  @override
  State<StatefulWidget> createState() => _SplashscreenState();

}


class _SplashscreenState extends State<Splashscreen> {
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  String _userId;
  UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _userRepository.setCurrentUser(user.uid, user.email);
          _authStatus = AuthStatus.LOGGED_IN;
        } else {
          _authStatus = AuthStatus.NOT_LOGGED_IN;
        }
        //_authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
        _userRepository.setCurrentUser(user.uid, user.email);
        _authStatus = AuthStatus.LOGGED_IN;
      });
    });
  }

  void logoutCallback() {
    setState(() {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userRepository.logoutUser();
      _userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return Login(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId != null && _userId.length > 0) {
          return Home(
            title: "Home",
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else
          return _buildWaitingScreen();
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