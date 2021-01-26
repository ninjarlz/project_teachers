import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/expert_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/locale/locale_keys.dart';
import 'package:project_teachers/screens/profile/base_profile.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';

class SelectedUserProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelectedUserProfileState();

  static Future<void> _startChat(AppStateManager appStateManager) async {
    MessagingService messagingService =
        MessagingService.instance;
    UserService userService = UserService.instance;
    ConversationEntity conversation = await messagingService
        .getConversation(userService.selectedUser.uid);
    if (conversation != null) {
      messagingService.setSelectedConversation(conversation);
    }
    appStateManager.changeAppState(AppState.CHAT);
  }

  static Stack buildSelectedUserProfileFloatingActionButtons(
      BuildContext context) {
    AppStateManager appStateManager =
        Provider.of<AppStateManager>(context, listen: false);

    return Stack(
      children: <Widget>[
        Align(
            alignment:
                Alignment.lerp(Alignment.topRight, Alignment.centerRight, 0.19),
            child: FloatingActionButton(
                onPressed: Provider.of<AppStateManager>(context, listen: false)
                    .previousState,
                backgroundColor: ThemeGlobalColor().mainColor,
                child: Icon(Icons.arrow_back))),
        Align(
            alignment: Alignment.bottomRight,
            child: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              visible: true,
              curve: Curves.bounceIn,
              backgroundColor: ThemeGlobalColor().secondaryColor,
              children: [
                SpeedDialChild(
                    child: Icon(Icons.message, color: Colors.white),
                    backgroundColor: ThemeGlobalColor().secondaryColor,
                    label: Translations.of(context).text(LocaleKeys.MESSAGE_KEY),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                    labelBackgroundColor: ThemeGlobalColor().secondaryColor,
                    onTap: () => _startChat(appStateManager)),
                SpeedDialChild(
                  child: Icon(Icons.add_circle_outline, color: Colors.white),
                  backgroundColor: ThemeGlobalColor().secondaryColor,
                  label:
                      Translations.of(context).text("book_consultation_hours"),
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.white),
                  labelBackgroundColor: ThemeGlobalColor().secondaryColor,
                )
              ],
            )),
      ],
    );
  }
}

class _SelectedUserProfileState extends BaseProfileState<SelectedUserProfile>
    implements
        SelectedUserListener,
        SelectedUserProfileImageListener,
        SelectedUserBackgroundImageListener {
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    userService.selectedUserListeners.add(this);
    userType = userService.selectedUser.userType;
    onUserDataChange();
    storageService.selectedUserBackgroundImageListeners.add(this);
    storageService.selectedUserProfileImageListeners.add(this);
    onSelectedUserBackgroundImageChange();
    onSelectedUserProfileImageChange();
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  @override
  void onUserDataChange() {
    ExpertEntity expert = userService.selectedExpert;
    if (expert != null) {
      userName = expert.name + " " + expert.surname;
      city = expert.city;
      school = expert.school;
      profession = expert.profession;
      if (userType == UserType.COACH) {
        CoachEntity coach = userService.selectedCoach;
        coachType = coach.coachType;
        maxAvailabilityPerWeek = coach.maxAvailabilityPerWeek;
        remainingAvailabilityInWeek = coach.remainingAvailabilityInWeek;
      }
      bio = expert.bio;
      if (expert.specializations != null && expert.specializations.isNotEmpty) {
        competencies = expert.specializations;
      }
      if (expert.schoolSubjects != null && expert.schoolSubjects.isNotEmpty) {
        subjects = expert.schoolSubjects;
      }
    } else {
      _appStateManager.changeAppState(AppState.USER_LIST);
    }
  }

  @override
  void dispose() {
    super.dispose();
    userService.selectedUserListeners.remove(this);
    storageService.selectedUserBackgroundImageListeners.remove(this);
    storageService.selectedUserProfileImageListeners.remove(this);
    if (_appStateManager.appState != AppState.CHAT) {
      storageService.disposeSelectedUserImages();
      userService.cancelSelectedUserSubscription();
    }
  }

  @override
  void onSelectedUserBackgroundImageChange() {
    if (storageService.selectedUserBackgroundImage != null) {
      setState(() {
        backgroundImage = storageService.selectedUserBackgroundImage.item2;
      });
    }
  }

  @override
  void onSelectedUserProfileImageChange() {
    if (storageService.selectedUserProfileImage != null) {
      setState(() {
        profileImage = storageService.selectedUserProfileImage.item2;
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
            Text(profession +
                " | " +
                userType.label, style: ThemeGlobalText().text),
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
