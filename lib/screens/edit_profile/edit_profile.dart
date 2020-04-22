import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/index.dart';
import 'base_edit_form.dart';

class EditProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfileState();
}

class _EditProfileState extends BaseEditFormState<EditProfile> {
  @override
  void initState() {
    super.initState();
    submitLabel = "global_save";
    UserEntity currUser = userService.currentUser;
    userType = currUser.userType;
    name.text = currUser.name;
    surname.text = currUser.surname;
    city.text = currUser.city;
    school.text = currUser.school;
    profession.text = currUser.profession;
    bio.text = currUser.bio;
    Future.delayed(Duration.zero, () {
      setState(() {
        if (userType == UserType.COACH) {
          pickedCoachTypeTranslation = Translations.of(context)
              .text(userService.currentCoach.coachType.label);
        }
        if (userService.currentExpert.specializations != null) {
          pickedSpecializationsTranslation = TranslationMapper.translateList(
              SpecializationExtension.getLabelsFromList(
                  userService.currentExpert.specializations),
              context);
        }
        if (userService.currentExpert.schoolSubjects != null) {
          pickedSubjectsTranslation = TranslationMapper.translateList(
              SchoolSubjectExtension.getLabelsFromList(
                  userService.currentExpert.schoolSubjects),
              context);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (userService.currentUser.userType) {
      case UserType.COACH:
        return  SafeArea(
            child: Stack(
              children: <Widget>[
                showCoachForm(),
                AnimationCircularProgressWidget(status: isLoading)
              ],
            ),
          );
      default:
        return SafeArea(
            child: Stack(
              children: <Widget>[
                showExpertForm(),
                AnimationCircularProgressWidget(status: isLoading)
              ],
            ),
          );
    }
  }

  @override
  void onBack() {
    appStateManager.changeAppState(AppState.PROFILE_PAGE);
  }

  @override
  Future<void> onSubmit() async {
    switch (userType) {
      case UserType.EXPERT:
        await userService.updateCurrentExpertData(
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
        await userService.updateCurrentCoachData(
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
    appStateManager.changeAppState(AppState.PROFILE_PAGE);
  }
}
