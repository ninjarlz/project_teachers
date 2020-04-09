import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/navigation_drawer/navigation_drawer.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/translations/translations.dart';

class Profile extends StatefulWidget {
  static const String routeName = "/profile";

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
  String _profilePicture = "";
  String _backgroundPicture = "";
  List<String> _competencies = ["Compentency 1", "Compentency 2", "Compentency 3", "Compentency 4", "Compentency 5"]; // TODO: change to user competencies
  String _profession = "Docent Engels op het Haags"; // TODO: change to user profession
  String _bio = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."; // TODO: change to user bio
  String _city = "";
  String _school = "";

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _userRepository.userListeners.add(this);
    _initialUpdate();
  }

  @override
  onUserDataChange() {
    setState(() {
      User user = _userRepository.currentUser;
      if (user != null) {
        _userName = user.name + " " + user.surname;
        _city = user.city;
        _school = user.school;
      } else {
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

  Future<void> _initialUpdate() async {
    Future.delayed(Duration(milliseconds: 200));
    onUserDataChange();
  }

  Widget _buildBackgroundImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Image.asset( // TODO: change to user background if not null
        "assets/img/default_background.jpg",
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.width / 2,
      margin: EdgeInsets.only(bottom: 10),
      child: Material(
        child: Image.asset( // TODO: change to user picture if not null
          "assets/img/default_profile.png",
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        elevation: 4.0,
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  Widget _buildProfileBio() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(_bio, style: ThemeGlobalText().text, textAlign: TextAlign.center),
    );
  }

  Widget _buildProfileCompetencyRow() {
    List<Widget> _rowElements = List<Widget>();
    int _count = 0;
    _competencies.forEach((competency) {
      if (_count++ < 3) _rowElements.add(PillProfileWidget(text: competency));
    });
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: _rowElements);
  }

  Widget _buildProfileCompetencies() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: (_competencies.length / 3).ceil(),
        itemBuilder: (context, index) {
          return _buildProfileCompetencyRow();
        });
  }

  Widget _buildProfile() {
    return Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height / 3),
        _buildProfileImage(),
        Text(_userName, style: ThemeGlobalText().titleText),
        SizedBox(height: 5),
        Text(_city, style: ThemeGlobalText().smallText),
        SizedBox(height: 5),
        Text(_profession, style: ThemeGlobalText().text),
        SizedBox(height: 5),
        Text(_school, style: ThemeGlobalText().text),
        SizedBox(height: 10),
        _buildProfileCompetencies(),
        SizedBox(height: 10),
        _buildProfileBio(),
        SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: Text(Translations.of(context).text("profile"), style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent),
        backgroundColor: ThemeGlobalColor().backgroundColor,
        body: SingleChildScrollView(
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              _buildBackgroundImage(),
              _buildProfile(),
            ],
          ),
        ),
        drawer: NavigationDrawer.instance,
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          backgroundColor: ThemeGlobalColor().secondaryColor,
          child: Icon(Icons.message),
        ),
      ),
    );
  }
}
