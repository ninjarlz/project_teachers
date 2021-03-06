import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/expert_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfileState();

  static SpeedDial buildSpeedDial(BuildContext context) {
    StorageService storageService = StorageService.instance;
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
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
          label: Translations.of(context).text("edit_profile"),
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
    userType = userService.currentUser.userType;
    userService.userListeners.add(this);
    storageService.userProfileImageListeners.add(this);
    storageService.userBackgroundImageListeners.add(this);
    onUserProfileImageChange();
    onUserBackgroundImageChange();
    onUserDataChange();
  }

  @override
  onUserDataChange() {
    setState(() {
      ExpertEntity expert = userService.currentExpert;
      if (expert != null) {
        userName = expert.name + " " + expert.surname;
        city = expert.city;
        school = expert.school;
        profession = expert.profession;
        if (userType == UserType.COACH) {
          CoachEntity coach = userService.currentCoach;
          coachType = coach.coachType;
          maxAvailabilityPerWeek = coach.maxAvailabilityPerWeek;
          remainingAvailabilityInWeek = coach.remainingAvailabilityInWeek;
        }
        bio = expert.bio;
        if (expert.specializations != null &&
            expert.specializations.isNotEmpty) {
          competencies = expert.specializations;
        }
        if (expert.schoolSubjects != null && expert.schoolSubjects.isNotEmpty) {
          subjects = expert.schoolSubjects;
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

  @override
  Widget buildProfile() {
    switch (userType) {
      case UserType.COACH:
        return Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            buildProfileImage(),
            Text(userName, style: ThemeGlobalText().titleText),
            SizedBox(height: 5),
            Text(city, style: ThemeGlobalText().smallText),
            SizedBox(height: 5),
            Text(
                profession +
                    " | " +
                    userType.label +
                    " - " +
                    Translations.of(context).text(coachType.label),
                style: ThemeGlobalText().text),
            SizedBox(height: 5),
            Text(school, style: ThemeGlobalText().text),
            SizedBox(height: 5),
            Text(
                (maxAvailabilityPerWeek != null
                        ? maxAvailabilityPerWeek.toString()
                        : "0") +
                    " " +
                    Translations.of(context).text("hrs_per_week") +
                    " | " +
                    (remainingAvailabilityInWeek != null
                        ? remainingAvailabilityInWeek.toString()
                        : "0") +
                    " " +
                    Translations.of(context).text("hrs_remaining_in_this_week"),
                style: ThemeGlobalText().text),
            SizedBox(height: 10),
            buildProfileSubjects(),
            SizedBox(height: 10),
            buildProfileCompetencies(),
            SizedBox(height: 10),
            buildProfileBio(),
            SizedBox(height: 100),
          ],
        );
      default:
        return Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            buildProfileImage(),
            Text(userName, style: ThemeGlobalText().titleText),
            SizedBox(height: 5),
            Text(city, style: ThemeGlobalText().smallText),
            SizedBox(height: 5),
            Text(profession + " | " + userType.label,
                style: ThemeGlobalText().text),
            SizedBox(height: 5),
            Text(school, style: ThemeGlobalText().text),
            SizedBox(height: 10),
            buildProfileSubjects(),
            SizedBox(height: 10),
            buildProfileCompetencies(),
            SizedBox(height: 10),
            buildProfileBio(),
            SizedBox(height: 100),
          ],
        );
    }
  }
}
