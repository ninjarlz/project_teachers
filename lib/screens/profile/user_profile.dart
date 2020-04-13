import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/profile/profile.dart';

class UserProfile extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _UserProfileState();
}

class _UserProfileState extends ProfileState<UserProfile> implements UserListener {


  @override
  void initState() {
    super.initState();
    userRepository.userListeners.add(this);
    onUserDataChange();
  }

  @override
  onUserDataChange() {
    setState(() {
      UserEntity user = userRepository.currentUser;
      if (user != null) {
        userName = user.name + " " + user.surname;
        city = user.city;
        school = user.school;
        profession = user.profession;
      } else {
        userName = "";
        city = "";
        school = "";
        profession = "";
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    userRepository.userListeners.remove(this);
  }
}
