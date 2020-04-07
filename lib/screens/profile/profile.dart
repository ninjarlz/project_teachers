import 'package:flutter/material.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/index.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileWidget();
  }
}

class ProfileWidget extends State<Profile> {
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
      child: Image.asset(
        "assets/img/default_profile.png",
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      ),
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
          TextIconWidget(icon: Icons.school, text: "De Haagse Hogeschool"),
          TextIconWidget(icon: Icons.location_city, text: "Den Haag"),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      children: <Widget>[
        _buildProfileImage(),
        Text("Firstname Lastname", style: ThemeGlobalText().titleText),
        SizedBox(height: 15),
        _buildProfileButtons(),
        SizedBox(height: 15),
        _buildProfileInfos(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
