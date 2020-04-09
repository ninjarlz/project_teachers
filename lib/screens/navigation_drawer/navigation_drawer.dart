import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/home/splashscreen.dart';
import 'package:project_teachers/screens/profile/profile.dart';
import 'package:project_teachers/services/auth.dart';
import 'package:project_teachers/themes/global.dart';


class NavigationDrawer extends StatefulWidget {

  NavigationDrawer._privateConstructor();

  VoidCallback _logoutCallback;

  void setLogoutCallback(VoidCallback logoutCallback) {
    _logoutCallback = logoutCallback;
  }

  static NavigationDrawer _instance;

  static NavigationDrawer get instance {
    if (_instance == null) {
      _instance = NavigationDrawer._privateConstructor();
    }
    return _instance;
  }

  @override
  State<StatefulWidget> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> implements UserListener {

  String _userName = "";
  String _userEmail = "";
  UserRepository _userRepository;
  Auth _auth;
  Splashscreen _splashscreen;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _auth = Auth.instance;
    _splashscreen = Splashscreen.instance();
    _userRepository.userListeners.add(this);
    _initialUpdate();
  }

  Future<void> _initialUpdate() async {
    Future.delayed(Duration(milliseconds: 200));
    onUserDataChange();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
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
              if (_splashscreen.currentAppState != AppState.TIMELINE) {
                _splashscreen.currentAppState = AppState.TIMELINE;
                Navigator.of(context).pushNamed(Splashscreen.routeName);
              }
            },
          ),
          ListTile(
            title: Text('Profile page'),
            onTap: () {
              Navigator.of(context).pop();
              if (_splashscreen.currentAppState != AppState.PROFILE_PAGE) {
                Navigator.of(context).pushNamed(Profile.routeName);
                _splashscreen.currentAppState = AppState.PROFILE_PAGE;
              }
            },
          ),
          ListTile(
            title: Text('Coach'),
            onTap: () {
              Navigator.of(context).pop();
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
              if (widget._logoutCallback != null) {
                Navigator.of(context).pop();
                _auth.signOut();
                _splashscreen.currentAppState = AppState.LOGIN;
                widget._logoutCallback();
                if (_splashscreen.currentAppState != AppState.TIMELINE) {
                  Navigator.of(context).pushNamed(Splashscreen.routeName);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  onUserDataChange() {
    setState(() {
      User user = _userRepository.currentUser;
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
