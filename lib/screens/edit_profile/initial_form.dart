import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/auth_status_manager.dart';
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
      validEmailAddressRepository
          .getUserType(auth.currentUser.email)
          .then((userType) {
        setState(() {
          this.userType = userType;
          _initialFormState = EditFormStateEnum.USER_TYPE_DETERMINED;
          if (userType == UserType.COACH) {
            pickedCoachTypeTranslation =
                Translations.of(context).text(CoachTypeExtension.labels[0]);
          }
        });
      });
    }
  }

  @protected
  @override
  Future<void> onSubmit() async {
    String email = auth.currentUser.email;
    await validEmailAddressRepository.markAddressAsInitialized(email);
    switch (userType) {
      case UserType.EXPERT:
        await userRepository.setInitializedCurrentExpert(
            auth.currentUser.uid,
            auth.currentUser.email,
            name.text,
            surname.text,
            city.text,
            school.text,
            profession.text,
            bio.text,
            SchoolSubjectExtension.getValuesFromLabels(
                TranslationMapper.labelsFromTranslation(
                    pickedSubjectsTranslation, context)),
            SpecializationExtension.getValuesFromLabels(
                TranslationMapper.labelsFromTranslation(
                    pickedSpecializationsTranslation, context)));
        break;

      case UserType.COACH:
        await userRepository.setInitializedCurrentCoach(
            auth.currentUser.uid,
            auth.currentUser.email,
            name.text,
            surname.text,
            city.text,
            school.text,
            profession.text,
            bio.text,
            SchoolSubjectExtension.getValuesFromLabels(
                TranslationMapper.labelsFromTranslation(
                    pickedSubjectsTranslation, context)),
            SpecializationExtension.getValuesFromLabels(
                TranslationMapper.labelsFromTranslation(
                    pickedSpecializationsTranslation, context)),
            CoachTypeExtension.getValue(
                Translations.of(context).key(pickedCoachTypeTranslation)));
        break;
    }
    authStatusManager.changeAuthState(AuthStatus.LOGGED_IN);
    appStateManager.changeAppState(AppState.COACH);
  }

  @protected
  @override
  void onBack() {
    appStateManager.changeAppState(AppState.LOGIN);
    userRepository.logoutUser();
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
            return Scaffold(body: SafeArea(
              child: Stack(
                children: <Widget>[
                  showCoachForm(),
                  AnimationCircularProgressWidget(status: isLoading)
                ],
              ),
            ));

          default:
            return Scaffold(body: SafeArea(
              child: Stack(
                children: <Widget>[
                  showExpertForm(),
                  AnimationCircularProgressWidget(status: isLoading)
                ],
              ),
            ));
        }
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
