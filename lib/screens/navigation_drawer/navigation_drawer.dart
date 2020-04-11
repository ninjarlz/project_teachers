import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/model/app_state_manager.dart';
import 'package:project_teachers/model/auth_status_manager.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/home/splashscreen.dart';
import 'package:project_teachers/screens/profile/profile.dart';
import 'package:project_teachers/services/auth.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:provider/provider.dart';


class NavigationDrawer extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> implements UserListener {

  String _userName = "";
  String _userEmail = "";
  UserRepository _userRepository;
  BaseAuth _auth;
  AppStateManager _appStateManager;
  AuthStatusManager _authStatusManager;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _auth = Auth.instance;
    _userRepository.userListeners.add(this);
    onUserDataChange();
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      _authStatusManager = Provider.of<AuthStatusManager>(context, listen: false);
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
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: _userName != "" ? Text(
                _userName[0].toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ) : null,
            ),
            decoration: BoxDecoration(
              color: ThemeGlobalColor().secondaryColor,
            ),
          ),
          ListTile(
            title: Text('Timeline'),
            onTap: () {
              Navigator.of(context).pop();
              },
          ),
          ListTile(
            title: Text('Profile page'),
            onTap: () {
              Navigator.of(context).pop();
              if (_appStateManager.appState != AppState.PROFILE_PAGE) {
                _appStateManager.changeAppState(AppState.PROFILE_PAGE);
              }
            },
          ),
          ListTile(
            title: Text('Coach'),
            onTap: () {
              Navigator.of(context).pop();
              if (_appStateManager.appState != AppState.COACH) {
                _appStateManager.changeAppState(AppState.COACH);
              }
            },
          ),
          ListTile(
            title: Text('Events'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Calendar'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Other Experts'),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text('Log out'),
            onTap: () {
              Navigator.of(context).pop();
              _auth.signOut();
              _userRepository.logoutUser();
              _authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
              _appStateManager.changeAppState(AppState.LOGIN);
              },
          ),
        ],
      ),
    );
  }

  @override
  onUserDataChange() {
    setState(() {
      UserEntity user = _userRepository.currentUser;
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
    _userRepository.userListeners.remove(this);
  }

}
