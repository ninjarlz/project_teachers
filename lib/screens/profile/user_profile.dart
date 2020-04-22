import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/expert_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfileState();

  static SpeedDial buildSpeedDial(BuildContext context) {
    StorageService storageService = StorageService.instance;
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
              storageService.uploadProfileImage();
            }),
        SpeedDialChild(
            child: Icon(Icons.image, color: Colors.white),
            backgroundColor: ThemeGlobalColor().secondaryColor,
            label: Translations.of(context).text("background_picture"),
            labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            labelBackgroundColor: ThemeGlobalColor().secondaryColor,
            onTap: () {
              storageService.uploadBackgroundImage();
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
    userService.userListeners.add(this);
    storageService.userProfileImageListeners.add(this);
    storageService.userBackgroundImageListeners.add(this);
    onUserProfileImageChange();
    onUserBackgroundImageChange();
    Future.delayed(Duration.zero, () {
      onUserDataChange();
    });
  }

  @override
  onUserDataChange() {
    setState(() {
      ExpertEntity expert = userService.currentExpert;
      if (expert != null) {
        userName = expert.name + " " + expert.surname;
        city = expert.city;
        school = expert.school;
        if (expert.schoolSubjects != null && expert.schoolSubjects.isNotEmpty) {
          school += " - ";
          for (int i = 0; i < expert.schoolSubjects.length - 1; i++) {
            school +=
                Translations.of(context).text(expert.schoolSubjects[i].label) +
                    ", ";
          }
          school += Translations.of(context).text(
              expert.schoolSubjects[expert.schoolSubjects.length - 1].label);
        }
        profession = expert.profession + " | " + expert.userType.label;
        if (expert.userType == UserType.COACH) {
          profession += " - " +
              Translations.of(context)
                  .text(userService.currentCoach.coachType.label);
        }
        bio = expert.bio;
        if (expert.specializations != null &&
            expert.specializations.isNotEmpty) {
          competencies = TranslationMapper.translateList(
              SpecializationExtension.getShortcutsFromList(
                  expert.specializations),
              context);
        }
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
    userService.userListeners.remove(this);
    storageService.userProfileImageListeners.remove(this);
    storageService.userBackgroundImageListeners.remove(this);
  }

  @override
  void onUserBackgroundImageChange() {
    if (storageService.userBackgroundImage != null) {
      setState(() {
        backgroundImage = storageService.userBackgroundImage;
      });
    }
  }

  @override
  void onUserProfileImageChange() {
    if (storageService.userProfileImage != null) {
      setState(() {
        profileImage = storageService.userProfileImage;
      });
    }
  }
}
