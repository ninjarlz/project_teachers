import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/coach_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/storage_sevice.dart';
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
    userRepository.coachListeners.add(this);
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
    CoachEntity coach = userRepository.selectedCoach;
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
        bio = coach.bio;
        if (coach.specializations != null && coach.specializations.isNotEmpty) {
          competencies = TranslationMapper.translateList(
              SpecializationExtension.getShortcutsFromList(coach.specializations),
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
    userRepository.coachListeners.remove(this);
    storageService.disposeCoachImages();
  }

  @override
  void onCoachBackgroundImageChange() {
    if (storageService.coachBackgroundImage != null) {
      setState(() {
        backgroundImage = storageService.coachBackgroundImage;
      });
    }
  }

  @override
  void onCoachProfileImageChange() {
    if (storageService.coachProfileImage != null) {
      setState(() {
        profileImage = storageService.coachProfileImage;
      });
    }
  }
}
