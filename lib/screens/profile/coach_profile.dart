import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/coach_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:provider/provider.dart';

class CoachProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CoachProfileState();

  static SpeedDial buildSpeedDial(BuildContext context) {
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
          child: Icon(Icons.arrow_back),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          onTap: () {
            Provider.of<AppStateManager>(context, listen: false)
                .changeAppState(AppState.COACH);
          },
          label: Translations.of(context).text("global_back"),
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.message, color: Colors.white),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          label: Translations.of(context).text("message"),
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.add_circle_outline, color: Colors.white),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          label: Translations.of(context).text("book_consultation_hours"),
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        )
      ],
    );
  }
}

class _CoachProfileState extends BaseProfileState<CoachProfile>
    implements
        CoachListener,
        CoachProfileImageListener,
        CoachBackgroundImageListener {
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    userService.coachListeners.add(this);
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      onCoachDataChange();
      storageService.coachBackgroundImageListeners.add(this);
      storageService.coachProfileImageListeners.add(this);
      onCoachBackgroundImageChange();
      onCoachProfileImageChange();
    });
  }

  @override
  void onCoachDataChange() {
    CoachEntity coach = userService.selectedCoach;
    if (coach != null) {
      setState(() {
        userName = coach.name + " " + coach.surname;
        city = coach.city;
        school = coach.school;
        if (coach.schoolSubjects != null && coach.schoolSubjects.isNotEmpty) {
          school += " - ";
          for (int i = 0; i < coach.schoolSubjects.length - 1; i++) {
            school +=
                Translations.of(context).text(coach.schoolSubjects[i].label) +
                    ", ";
          }
          school += Translations.of(context).text(
              coach.schoolSubjects[coach.schoolSubjects.length - 1].label);
        }
        profession = coach.profession +
            " | Coach - " +
            Translations.of(context).text(coach.coachType.label);
        availability = (coach.maxAvailabilityPerWeek != null
                ? coach.maxAvailabilityPerWeek.toString()
                : "0 ") +
            " hrs per week | " +
            (coach.remainingAvailabilityInWeek != null
                ? coach.remainingAvailabilityInWeek.toString()
                : "0 ") +
            " hrs remaining in this week";
        bio = coach.bio;
        if (coach.specializations != null && coach.specializations.isNotEmpty) {
          competencies = TranslationMapper.translateList(
              SpecializationExtension.getShortcutsFromList(
                  coach.specializations),
              context);
        }
      });
    } else {
      _appStateManager.changeAppState(AppState.COACH);
    }
  }

  @override
  void dispose() {
    super.dispose();
    userService.coachListeners.remove(this);
    storageService.disposeCoachImages();
    userService.cancelSelectedCoachSubscription();
  }

  @override
  void onCoachBackgroundImageChange() {
    if (storageService.selectedCoachBackgroundImage != null) {
      setState(() {
        backgroundImage = storageService.selectedCoachBackgroundImage.item2;
      });
    }
  }

  @override
  void onCoachProfileImageChange() {
    if (storageService.selectedCoachProfileImage != null) {
      setState(() {
        profileImage = storageService.selectedCoachProfileImage.item2;
      });
    }
  }

  @override
  Widget buildProfile() {
    return Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height / 3),
        buildProfileImage(),
        Text(userName, style: ThemeGlobalText().titleText),
        SizedBox(height: 5),
        Text(city, style: ThemeGlobalText().smallText),
        SizedBox(height: 5),
        Text(profession, style: ThemeGlobalText().text),
        SizedBox(height: 5),
        Text(school, style: ThemeGlobalText().text),
        SizedBox(height: 5),
        Text(availability, style: ThemeGlobalText().text),
        SizedBox(height: 10),
        buildProfileCompetencies(),
        SizedBox(height: 10),
        buildProfileBio(),
        SizedBox(height: 100),
      ],
    );
  }
}
