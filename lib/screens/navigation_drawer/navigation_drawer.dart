import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/managers/auth_status_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/utils/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer>
    implements UserListener, UserProfileImageListener {
  String _userName = "";
  String _userEmail = "";
  UserService _userService;
  BaseAuth _auth;
  AppStateManager _appStateManager;
  AuthStatusManager _authStatusManager;
  StorageService _storageService;
  Widget _profileImage;

  @override
  void initState() {
    super.initState();
    _userService = UserService.instance;
    _auth = Auth.instance;
    _storageService = StorageService.instance;
    _userService.userListeners.add(this);
    _storageService.userProfileImageListeners.add(this);
    onUserDataChange();
    _profileImage = CircleAvatar(
      backgroundColor: Colors.white,
      child: _userName != ""
          ? Text(
              _userName[0].toUpperCase(),
              style: TextStyle(fontSize: 40.0),
            )
          : null,
    );
    onUserProfileImageChange();
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      _authStatusManager =
          Provider.of<AuthStatusManager>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text(_userEmail),
            accountName: Text(_userName),
            currentAccountPicture: _profileImage,
            decoration: BoxDecoration(
              color: ThemeGlobalColor().secondaryColor,
            ),
          ),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text(Translations.of(context).text("timeline")),
            onTap: () {
              Navigator.of(context).pop();
              if (_appStateManager.appState != AppState.TIMELINE) {
                _appStateManager.changeAppState(AppState.TIMELINE);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(Translations.of(context).text("profile")),
            onTap: () {
              Navigator.of(context).pop();
              if (_appStateManager.appState != AppState.PROFILE_PAGE) {
                _appStateManager.changeAppState(AppState.PROFILE_PAGE);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text(Translations.of(context).text("coach")),
            onTap: () {
              Navigator.of(context).pop();
              if (_appStateManager.appState != AppState.COACH) {
                _appStateManager.changeAppState(AppState.COACH);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.access_alarms),
            title: Text(Translations.of(context).text("events")),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.event_available),
            title: Text(Translations.of(context).text("calendar")),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(Translations.of(context).text("other_experts")),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(Icons.arrow_back),
            title: Text(Translations.of(context).text("logout")),
            onTap: () {
              Navigator.of(context).pop();
              _auth.signOut();
              _userService.logoutUser();
              _authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
              _appStateManager.changeAppState(AppState.LOGIN);
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TranslationManagerWidget()
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  onUserDataChange() {
    setState(() {
      UserEntity user = _userService.currentUser;
      if (user != null) {
        _userEmail = user.email;
        _userName = user.name + " " + user.surname;
      } else {
        _userEmail = "";
        _userName = "";
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userService.userListeners.remove(this);
    _storageService.userProfileImageListeners.remove(this);
  }

  @override
  void onUserProfileImageChange() {
    setState(() {
      if (_storageService.userProfileImage != null) {
        _profileImage = ClipOval(child: _storageService.userProfileImage);
      }
    });
  }
}
