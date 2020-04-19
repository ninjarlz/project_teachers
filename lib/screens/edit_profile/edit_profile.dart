import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/widgets/index.dart';



import 'base_edit_form.dart';

class EditProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfileState();
}

class _EditProfileState extends BaseEditFormState<EditProfile> {

  @override
  void initState() {
    super.initState();
    submitLabel = "global_save";
    UserEntity currUser = userRepository.currentUser;
    name.text = currUser.name;
    surname.text = currUser.surname;
    city.text = currUser.city;
    school.text = currUser.school;
    profession.text = currUser.profession;
    bio.text = currUser.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            showForm(),
            AnimationCircularProgressWidget(status: isLoading)
          ],
        ),
      ),
    );
  }

  @override
  void onBack() {
    appStateManager.changeAppState(AppState.PROFILE_PAGE);
  }

  @override
  Future<void> onSubmit() async {
    await userRepository.updateUserFromData(
        auth.currentUser.uid,
        auth.currentUser.email,
        name.text,
        surname.text,
        city.text,
        school.text,
        profession.text,
        bio.text,
        userRepository.currentUser.userType);
    appStateManager.changeAppState(AppState.PROFILE_PAGE);
  }
}