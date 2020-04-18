import 'package:flutter/material.dart';

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN, INITIAL_FORM }

class AuthStatusManager extends ChangeNotifier {
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  AuthStatus get authStatus => _authStatus;

  void changeAuthState(AuthStatus authState) {
    _authStatus = authState;
    notifyListeners();
  }
}