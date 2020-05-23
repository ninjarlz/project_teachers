import 'package:flutter/material.dart';

enum AppState {
  TIMELINE,
  POST_QUESTION,
  POST_ANSWER,
  QUESTION_ANSWERS,
  USER_TIMELINE,
  FILTER_QUESTIONS,
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
  CHAT,
  CONNECTION_LOST
}


class AppStateManager extends ChangeNotifier {
  AppState _appState = AppState.LOGIN;
  AppState get appState => _appState;
  AppState _prevState = AppState.LOGIN;
  AppState get prevState => _prevState;
  AppState _userViewPrevState;

  void changeAppState(AppState appState) {
    if (appState == AppState.COACH) {
      _userViewPrevState = appState;
    }
    _prevState = _appState;
    _appState = appState;
    notifyListeners();
  }

  void previousState() {
    if (_appState == AppState.COACH_PROFILE_PAGE) {
      changeAppState(_userViewPrevState);
    } else {
      changeAppState(prevState);
    }
  }


}