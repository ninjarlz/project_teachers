import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/index.dart';

class Profile extends StatefulWidget {
  static const String routeName = "/profile";

  static const String TITLE = "Profile";

  Profile._privateConstructor();

  static Profile _instance;

  static Profile instance() {
    if (_instance == null) {
      _instance = Profile._privateConstructor();
    }
    return _instance;
  }

  @override
  State<StatefulWidget> createState() {
    return ProfileWidget();
  }
}

class ProfileWidget extends State<Profile> implements UserListener {
  UserRepository _userRepository;
  String _userName = "";
  String _email = "";
  String _city = "";
  String _school = "";

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _userRepository.userListeners.add(this);
    _initialUpdate();
  }

  Future<void> _initialUpdate() async {
    Future.delayed(Duration(milliseconds: 200));
    onUserDataChange();
  }

  Widget _buildBackgroundImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Image.asset(
        "assets/img/default_background.jpg",
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.width / 2.5,
      margin: EdgeInsets.only(bottom: 20),
      child: CircleAvatar(
        backgroundColor: ThemeGlobalColor().mainColor,
        child: _userName != ""
            ? Text(
                _userName[0].toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              )
            : null,
      ),
//    Image.asset(
//        "assets/img/default_profile.png",
//        fit: BoxFit.cover,
//        alignment: Alignment.bottomCenter,
//      ),
    );
  }

  Widget _buildProfileButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ButtonCircledIconWidget(icon: Icons.message, submit: null),
        ButtonCircledIconWidget(icon: Icons.call, submit: null),
        ButtonCircledIconWidget(icon: Icons.remove_red_eye, submit: null)
      ],
    );
  }

  Widget _buildProfileInfos() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      decoration: ThemeProfile().profileContainer,
      child: Column(
        children: <Widget>[
          TextIconWidget(icon: Icons.email, text: _email),
          TextIconWidget(icon: Icons.school, text: _school),
          TextIconWidget(icon: Icons.location_city, text: _city),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      children: <Widget>[
        _buildProfileImage(),
        Text(_userName, style: ThemeGlobalText().titleText),
        SizedBox(height: 15),
        _buildProfileButtons(),
        SizedBox(height: 15),
        _buildProfileInfos(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(title: Text(Profile.TITLE, style: TextStyle(color: Colors.white)), backgroundColor: ThemeGlobalColor().secondaryColor),
            backgroundColor: ThemeGlobalColor().backgroundColor,
            body: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                _buildBackgroundImage(),
                Positioned(
                  top: MediaQuery.of(context).size.width / 1.5,
                  width: MediaQuery.of(context).size.width,
                  child: _buildProfile(),
                ),
              ],
            ),
            drawer: NavigationDrawer.instance));
  }

  @override
  onUserDataChange() {
    setState(() {
      User user = _userRepository.currentUser;
      if (user != null) {
        _email = user.email;
        _userName = user.name + " " + user.surname;
        _city = user.city;
        _school = user.school;
      } else {
        _email = "";
        _userName = "";
        _city = "";
        _school = "";
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userRepository.userListeners.remove(this);
  }
}
