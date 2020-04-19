import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/storage_repository.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfileState();

  static SpeedDial buildSpeedDial(BuildContext context) {
    StorageRepository storageRepository = StorageRepository.instance;
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: ThemeGlobalColor().secondaryColor,
      children: [
        SpeedDialChild(
          child: Icon(Icons.edit),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          onTap: () {
            Provider.of<AppStateManager>(context, listen: false)
                .changeAppState(AppState.EDIT_PROFILE);
          },
          label: Translations.of(context).text("edit"),
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        ),
        SpeedDialChild(
            child: Icon(Icons.person, color: Colors.white),
            backgroundColor: ThemeGlobalColor().secondaryColor,
            label: Translations.of(context).text("profile_picture"),
            labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            labelBackgroundColor: ThemeGlobalColor().secondaryColor,
            onTap: () {
              storageRepository.uploadProfileImage();
            }),
        SpeedDialChild(
            child: Icon(Icons.image, color: Colors.white),
            backgroundColor: ThemeGlobalColor().secondaryColor,
            label: Translations.of(context).text("background_picture"),
            labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            labelBackgroundColor: ThemeGlobalColor().secondaryColor,
            onTap: () {
              storageRepository.uploadBackgroundImage();
            })
      ],
    );
  }
}

class _UserProfileState extends BaseProfileState<UserProfile>
    implements
        UserListener,
        UserProfileImageListener,
        UserBackgroundImageListener {
  @override
  void initState() {
    super.initState();
    userRepository.userListeners.add(this);
    storageRepository.userProfileImageListeners.add(this);
    storageRepository.userBackgroundImageListeners.add(this);
    onUserDataChange();
    onUserProfileImageChange();
    onUserBackgroundImageChange();
  }

  @override
  onUserDataChange() {
    setState(() {
      UserEntity user = userRepository.currentUser;
      if (user != null) {
        userName = user.name + " " + user.surname;
        city = user.city;
        school = user.school + " | " + user.userType.label;
        profession = user.profession;
        bio = user.bio;
      } else {
        userName = "";
        city = "";
        school = "";
        profession = "";
        bio = "";
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    userRepository.userListeners.remove(this);
    storageRepository.userProfileImageListeners.remove(this);
    storageRepository.userBackgroundImageListeners.remove(this);
  }

  @override
  void onUserBackgroundImageChange() {
    if (storageRepository.userBackgroundImage != null) {
      setState(() {
        backgroundImage = storageRepository.userBackgroundImage;
      });
    }
  }

  @override
  void onUserProfileImageChange() {
    if (storageRepository.userProfileImage != null) {
      setState(() {
        profileImage = storageRepository.userProfileImage;
      });
    }
  }
}
