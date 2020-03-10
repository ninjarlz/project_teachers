import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/services/index.dart';

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

class _HomeState extends State<Home> implements UserListListener, UserListener {

  String _usersInfo = "";
  String _userEmail = "";
  UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _userRepository.userListeners.add(this);
    _userRepository.userListListeners.add(this);
    initialUpdate();
  }

  Future<void> initialUpdate() async {
    Future.delayed(Duration(milliseconds: 200));
    onUserDataChange();
    onUsersListChange(_userRepository.userList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: Text(_usersInfo)),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(_userEmail),
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
              ),
            ),
            ListTile(
              title: Text('Opt 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Opt 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Log out'),
              onTap: () {
                Navigator.pop(context);
                widget.auth.signOut();
                widget.logoutCallback();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  onUserDataChange() {
    setState(() {
      _userEmail = _userRepository.currentUser?.email;
    });
  }

  @override
  onUsersListChange(List<User> users) {
    setState(() {
      _usersInfo = "";
      users.forEach((user) {
        _usersInfo += user.email + " " + user.name + "\n";
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userRepository.userListListeners.remove(this);
    _userRepository.userListeners.remove(this);
  }

}