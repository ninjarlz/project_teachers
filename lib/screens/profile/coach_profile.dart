import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/model/app_state_manager.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/screens/profile/profile.dart';
import 'package:project_teachers/themes/global.dart';
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
            Provider.of<AppStateManager>(context, listen: false).changeAppState(AppState.COACH);
          },
          label: 'Back',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.message, color: Colors.white),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          label: 'Message',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        )
      ],
    );
  }
}

class _CoachProfileState extends ProfileState<CoachProfile> implements CoachListener {


  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    userRepository.coachListeners.add(this);
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      onCoachDataChange();
    });
  }

  @override
  void onCoachDataChange() {
    UserEntity coach = userRepository.currentCoach;
    if (coach != null) {
      setState(() {
        userName = coach.name + " " + coach.surname;
        city = coach.city;
        school = coach.school;
        profession = coach.profession;
      });
    } else {
      _appStateManager.changeAppState(AppState.COACH);
    }
  }

  @override
  void dispose() {
    super.dispose();
    userRepository.coachListeners.remove(this);
  }
}