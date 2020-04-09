import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/services/index.dart';
import 'package:project_teachers/themes/global.dart';

class Home extends StatefulWidget {

  Home({Key key, this.title, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final String title;

  @override
  State<StatefulWidget> createState() => _HomeState();

}

class _HomeState extends State<Home> implements UserListListener {

  UserRepository _userRepository;
  String _usersInfo = "";

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _userRepository.userListListeners.add(this);
    _initialUpdate();
  }

  Future<void> _initialUpdate() async {
    Future.delayed(Duration(milliseconds: 200));
    onUsersListChange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: TextStyle(color: Colors.white)), backgroundColor: ThemeGlobalColor().secondaryColor),
      body: Center(child: Text(_usersInfo)),
      drawer: NavigationDrawer.instance
    );
  }


  @override
  onUsersListChange() {
    setState(() {
      _usersInfo = "";
      _userRepository.usersMap.forEach((key, user) {
        _usersInfo += user.email + " " + (user.userType != null ? user.userType.label : "") + "\n";
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userRepository.userListListeners.remove(this);
  }

}