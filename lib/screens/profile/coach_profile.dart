import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:provider/provider.dart';

class CoachProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CoachProfileState();

  static Stack buildCoachProfileFloatingActionButtons(BuildContext context) {
    AppStateManager appStateManager =
        Provider.of<AppStateManager>(context, listen: false);

    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.lerp(Alignment.topRight,
              Alignment.centerRight, 0.19),
          child: FloatingActionButton(
              onPressed:
              Provider.of<AppStateManager>(context, listen: false).previousState,
              backgroundColor: ThemeGlobalColor().mainColor,
              child: Icon(Icons.arrow_back))
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: SpeedDial(
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
                  child: Icon(Icons.message, color: Colors.white),
                  backgroundColor: ThemeGlobalColor().secondaryColor,
                  label: Translations.of(context).text("message"),
                  labelStyle:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                  labelBackgroundColor: ThemeGlobalColor().secondaryColor,
                  onTap: () async {
                    MessagingService messagingService = MessagingService.instance;
                    UserService userService = UserService.instance;
                    ConversationEntity conversation = await messagingService
                        .getConversation(userService.selectedCoach.uid);
                    if (conversation != null) {
                      messagingService.setSelectedConversation(conversation);
                    }
                    appStateManager.changeAppState(AppState.CHAT);
                  }),
              SpeedDialChild(
                child: Icon(Icons.add_circle_outline, color: Colors.white),
                backgroundColor: ThemeGlobalColor().secondaryColor,
                label: Translations.of(context).text("book_consultation_hours"),
                labelStyle:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                labelBackgroundColor: ThemeGlobalColor().secondaryColor,
              )
            ],
          )
        ),
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
    storageService.coachBackgroundImageListeners.remove(this);
    storageService.coachProfileImageListeners.remove(this);
    if (_appStateManager.appState != AppState.CHAT) {
      storageService.disposeCoachImages();
      userService.cancelSelectedCoachSubscription();
    }
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
