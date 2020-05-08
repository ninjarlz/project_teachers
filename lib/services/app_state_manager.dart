import 'package:flutter/material.dart';

enum AppState {
  TIMELINE,
  PROFILE_PAGE,
  COACH,
  COACH_PROFILE_PAGE,
  EVENTS,
  CALENDAR,
  OTHER_EXPERTS,
  LOGIN,
  INITIAL_FORM,
  EDIT_PROFILE,
  FILTER_COACH,
  CONTACTS,
  CHAT
}


class AppStateManager extends ChangeNotifier {
  AppState _appState = AppState.LOGIN;
  AppState get appState => _appState;

  void changeAppState(AppState appState) {
    _appState = appState;
    notifyListeners();
  }


}