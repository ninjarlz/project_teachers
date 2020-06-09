import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/widgets/input/places_input_with_icon.dart';
import 'package:project_teachers/widgets/slider/slider_widget.dart';
import 'package:provider/provider.dart';
import 'base_edit_form.dart';

class EditProfile extends StatefulWidget {
  static FloatingActionButton editProfileFloatingActionButton(
      BuildContext context) {
    return FloatingActionButton(
        onPressed:
            Provider.of<AppStateManager>(context, listen: false).previousState,
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.arrow_back));
  }

  @override
  State<StatefulWidget> createState() => _EditProfileState();
}

class _EditProfileState extends BaseEditFormState<EditProfile> {
  int _remainingAvailability = 0;

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
          CoachEntity currentCoach = userService.currentCoach;
          pickedCoachTypeTranslation =
              Translations.of(context).text(currentCoach.coachType.label);
          if (currentCoach.maxAvailabilityPerWeek != null) {
            maxAvailability = currentCoach.maxAvailabilityPerWeek;
          }
          if (currentCoach.remainingAvailabilityInWeek != null) {
            _remainingAvailability = currentCoach.remainingAvailabilityInWeek;
          }
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
        return SafeArea(
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
    appStateManager.previousState();
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
            schoolId,
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
            schoolId,
            profession.text,
            bio.text,
            SchoolSubjectExtension.getValuesFromLabels(
                TranslationMapper.labelsFromTranslation(
                    pickedSubjectsTranslation, context)),
            SpecializationExtension.getValuesFromLabels(
                TranslationMapper.labelsFromTranslation(
                    pickedSpecializationsTranslation, context)),
            CoachTypeExtension.getValue(
                Translations.of(context).key(pickedCoachTypeTranslation)),
            maxAvailability != 0 ? maxAvailability : 0,
            _remainingAvailability != 0 ? _remainingAvailability : null);
        break;
    }
    appStateManager.changeAppState(AppState.PROFILE_PAGE);
  }

  // TEMPORARILY
  @protected
  @override
  Widget showCoachForm() {
    return Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                    height: imagePath != null ? 150 : 0,
                    margin: EdgeInsets.all(10),
                    child: imagePath != null
                        ? Image.asset(imagePath)
                        : Container()),
                InputWithIconWidget(
                    ctrl: name,
                    hint: Translations.of(context).text("register_firstname"),
                    icon: Icons.person,
                    type: TextInputType.text,
                    error:
                        Translations.of(context).text("error_firstname_empty"),
                    maxLines: 1),
                InputWithIconWidget(
                    ctrl: surname,
                    hint: Translations.of(context).text("register_lastname"),
                    icon: Icons.person,
                    type: TextInputType.text,
                    error:
                        Translations.of(context).text("error_lastname_empty"),
                    maxLines: 1),
                InputWithIconWidget(
                    ctrl: city,
                    hint: Translations.of(context).text("register_city"),
                    icon: Icons.location_city,
                    type: TextInputType.text,
                    error: Translations.of(context).text("error_city_empty"),
                    maxLines: 1),
                PlacesInputWithIconWidget(
                    ctrl: school,
                    hint: Translations.of(context).text("register_school"),
                    icon: Icons.school,
                    error: Translations.of(context).text("error_school"),
                    placesTypes: ["school", "university"],
                    language: Translations.of(context).text("language"),
                    onPlacePicked: onPlacePicked),
                InputWithIconWidget(
                    ctrl: profession,
                    hint: Translations.of(context).text("register_profession"),
                    icon: Icons.work,
                    type: TextInputType.text,
                    error:
                        Translations.of(context).text("error_profession_empty"),
                    maxLines: 1),
                InputWithIconWidget(
                    ctrl: bio,
                    hint: Translations.of(context).text("register_bio"),
                    icon: Icons.edit,
                    type: TextInputType.multiline,
                    error: Translations.of(context).text("error_bio_empty")),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: TextErrorWidget(text: errorMessage)),
                ),
                Text(Translations.of(context).text("subjects"),
                    style: ThemeGlobalText().titleText),
                CheckboxGroup(
                  onSelected: onSubjectsValuesChanged,
                  labels: TranslationMapper.translateList(
                      SchoolSubjectExtension.editableLabels, context),
                  checked: pickedSubjectsTranslation,
                  activeColor: ThemeGlobalColor().mainColorDark,
                  labelStyle: ThemeGlobalText().text,
                ),
                Text(Translations.of(context).text("specializations"),
                    style: ThemeGlobalText().titleText),
                CheckboxGroup(
                  onSelected: onSpecializationsValuesChanged,
                  labels: TranslationMapper.translateList(
                      SpecializationExtension.labels, context),
                  checked: pickedSpecializationsTranslation,
                  activeColor: ThemeGlobalColor().mainColorDark,
                  labelStyle: ThemeGlobalText().text,
                ),
                Text(Translations.of(context).text("coach_type"),
                    style: ThemeGlobalText().titleText),
                RadioButtonGroup(
                  labels: TranslationMapper.translateList(
                      CoachTypeExtension.labels, context),
                  onSelected: onCoachTypeValueChanged,
                  labelStyle: ThemeGlobalText().text,
                  picked: pickedCoachTypeTranslation,
                  activeColor: ThemeGlobalColor().mainColorDark,
                ),
                Text(Translations.of(context).text("max_availability"),
                    style: ThemeGlobalText().titleText),
                Text(Translations.of(context).text("hours_per_week"),
                    style: ThemeGlobalText().smallText),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: SliderWidget(
                        initValue: maxAvailability,
                        min: 0,
                        max: 8,
                        onChanged: onMaxAvailabilityValueChanged)),
                Text(Translations.of(context).text("remaining_availability"),
                    style: ThemeGlobalText().titleText),
                Text(Translations.of(context).text("hours_this_week"),
                    style: ThemeGlobalText().smallText),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: maxAvailability != 0
                        ? SliderWidget(
                            initValue: _remainingAvailability,
                            min: 0,
                            max: maxAvailability,
                            onChanged: onRemainingAvailabilityValueChanged)
                        : Text("-", style: ThemeGlobalText().titleText)),
                Visibility(
                    visible: errorMessage != null && errorMessage != "",
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(child: TextErrorWidget(text: errorMessage)),
                    )),
                ButtonPrimaryWidget(
                    text: Translations.of(context).text(submitLabel),
                    submit: validateAndSubmit),
                ButtonSecondaryWidget(
                    text: Translations.of(context).text("global_back"),
                    submit: onBack),
              ],
            ),
          ),
        ));
  }

  @override
  void onMaxAvailabilityValueChanged(int maxAvailability) {
    setState(() {
      this.maxAvailability = maxAvailability;
      _remainingAvailability = maxAvailability;
    });
  }

  void onRemainingAvailabilityValueChanged(int remainingAvailability) {
    setState(() {
      _remainingAvailability = remainingAvailability;
    });
  }
}
