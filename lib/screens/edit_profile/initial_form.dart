import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/managers/auth_status_manager.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/animation/animation_circular_progress.dart';
import 'base_edit_form.dart';

enum EditFormStateEnum { USER_TYPE_DETERMINED, USER_TYPE_NOT_DETERMINED }

class InitialForm extends StatefulWidget {
  static const String TITLE = "Initial data form";

  @override
  State<StatefulWidget> createState() => _InitialFormState();
}

class _InitialFormState extends BaseEditFormState<InitialForm> {
  EditFormStateEnum _initialFormState =
      EditFormStateEnum.USER_TYPE_NOT_DETERMINED;

  @override
  void initState() {
    super.initState();
    submitLabel = "register_create";
    imagePath = "assets/img/icon_new.png";
    if (auth.currentUser != null) {
      validEmailAddressService
          .getUserType(auth.currentUser.email)
          .then((userType) {
        setState(() {
          this.userType = userType;
          _initialFormState = EditFormStateEnum.USER_TYPE_DETERMINED;
          if (userType == UserType.COACH) {
            pickedCoachType = CoachType.values[0];
          }
        });
      });
    }
  }

  @protected
  @override
  Future<void> onSubmit() async {
    String email = auth.currentUser.email;
    switch (userType) {
      case UserType.EXPERT:
        await userService.setInitializedCurrentExpert(
            auth.currentUser.uid,
            auth.currentUser.email,
            name.text,
            surname.text,
            city.text,
            school.text,
            schoolId,
            profession.text,
            bio.text,
            pickedSubjects,
            pickedSpecializations);
        break;

      case UserType.COACH:
        await userService.setInitializedCurrentCoach(
            auth.currentUser.uid,
            auth.currentUser.email,
            name.text,
            surname.text,
            city.text,
            school.text,
            schoolId,
            profession.text,
            bio.text,
            pickedSubjects,
            pickedSpecializations,
            pickedCoachType,
            maxAvailability);
        break;
    }
    await validEmailAddressService.markAddressAsInitialized(email);
    authStatusManager.changeAuthState(AuthStatus.LOGGED_IN);
    appStateManager.changeAppState(AppState.USER_LIST);
  }

  @protected
  @override
  void onBack() {
    appStateManager.changeAppState(AppState.LOGIN);
    userService.logoutUser();
    authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
  }

  @override
  Widget build(BuildContext context) {
    switch (_initialFormState) {
      case EditFormStateEnum.USER_TYPE_NOT_DETERMINED:
        return buildWaitingScreen();
      case EditFormStateEnum.USER_TYPE_DETERMINED:
        switch (userType) {
          case UserType.COACH:
            return Scaffold(
                body: Scrollbar(
                    child: SafeArea(
              child: Stack(
                children: <Widget>[
                  showCoachForm(),
                  AnimationCircularProgressWidget(status: isLoading)
                ],
              ),
            )));

          default:
            return Scaffold(
                backgroundColor: ThemeGlobalColor().backgroundColor,
                body: Scrollbar(
                    child: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      showExpertForm(),
                      AnimationCircularProgressWidget(status: isLoading)
                    ],
                  ),
                )));
        }
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
