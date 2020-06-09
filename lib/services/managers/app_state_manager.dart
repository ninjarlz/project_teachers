import 'package:flutter/material.dart';

enum AppState {
  TIMELINE,
  POST_QUESTION,
  POST_ANSWER,
  QUESTION_ANSWERS,
  USER_TIMELINE,
  FILTER_QUESTIONS,
  PROFILE_PAGE,
  USER_LIST,
  SELECTED_USER_PROFILE_PAGE,
  SETTINGS,
  ACCOUNT_DELETE_SURE,
  CALENDAR,
  OTHER_EXPERTS,
  LOGIN,
  INITIAL_FORM,
  EDIT_PROFILE,
  FILTER_USERS,
  CONTACTS,
  CHAT,
  CONNECTION_LOST,
  EDIT_QUESTION,
  EDIT_ANSWER
}

class AppStateManager extends ChangeNotifier {
  AppState _appState = AppState.LOGIN;

  AppState get appState => _appState;
  AppState _prevState = AppState.LOGIN;

  AppState get prevState => _prevState;
  AppState _userViewPrevState;
  AppState _answersViewPrevState;

  void changeAppState(AppState appState) {
    if (appState == AppState.USER_LIST) {
      _userViewPrevState = appState;
    } else if (appState == AppState.USER_TIMELINE) {
      _answersViewPrevState = appState;
    } else if (appState == AppState.TIMELINE) {
      _answersViewPrevState = appState;
    }
    if (_appState != AppState.CONNECTION_LOST) {
      _prevState = _appState;
    }
    _appState = appState;
    notifyListeners();
  }

  void previousState() {
    if (_appState == AppState.SELECTED_USER_PROFILE_PAGE) {
      changeAppState(_userViewPrevState);
    } else if (_appState == AppState.QUESTION_ANSWERS) {
      changeAppState(_answersViewPrevState);
    } else {
      changeAppState(prevState);
    }
  }
}
