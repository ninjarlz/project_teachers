import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/managers/auth_status_manager.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/services/validation/valid_email_address_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/button/button_secondary.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/widgets/input/places_input_with_icon.dart';
import 'package:project_teachers/widgets/slider/slider_widget.dart';
import 'package:project_teachers/widgets/text/text_error.dart';
import 'package:provider/provider.dart';

abstract class BaseEditFormState<T extends StatefulWidget> extends State<T> {
  @protected
  UserService userService;
  @protected
  ValidEmailAddressService validEmailAddressService;
  @protected
  BaseAuth auth;
  @protected
  UserType userType;
  @protected
  bool isLoading;
  @protected
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @protected
  String errorMessage;
  @protected
  TextEditingController name = TextEditingController();
  @protected
  TextEditingController surname = TextEditingController();
  @protected
  TextEditingController school = TextEditingController();
  @protected
  String schoolId;
  @protected
  TextEditingController city = TextEditingController();
  @protected
  TextEditingController profession = TextEditingController();
  @protected
  TextEditingController bio = TextEditingController();
  @protected
  CoachType pickedCoachType;
  @protected
  List<SchoolSubject> pickedSubjects = List<SchoolSubject>();
  @protected
  List<Specialization> pickedSpecializations = List<Specialization>();
  @protected
  int maxAvailability = 0;
  @protected
  AuthStatusManager authStatusManager;
  @protected
  AppStateManager appStateManager;
  @protected
  String imagePath;
  @protected
  String submitLabel;

  @override
  void initState() {
    super.initState();
    userService = UserService.instance;
    validEmailAddressService = ValidEmailAddressService.instance;
    auth = Auth.instance;
    Future.delayed(Duration.zero, () {
      authStatusManager =
          Provider.of<AuthStatusManager>(context, listen: false);
      appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  @protected
  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @protected
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @protected
  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        errorMessage = "";
        isLoading = true;
      });
      try {
        if (auth.currentUser != null) {
          onSubmit();
        } else {
          setState(() {
            isLoading = false;
            errorMessage = Translations.of(context).text("error_unknown");
            formKey.currentState.reset();
            FocusScope.of(context).unfocus();
          });
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          isLoading = false;
          errorMessage = e.message;
          formKey.currentState.reset();
          FocusScope.of(context).unfocus();
        });
      }
    }
  }

  @protected
  Future<void> onSubmit();

  @protected
  void onBack();

  @protected
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
                  child:
                      imagePath != null ? Image.asset(imagePath) : Container()),
              InputWithIconWidget(
                  ctrl: name,
                  hint: Translations.of(context).text("register_firstname"),
                  icon: Icons.person,
                  type: TextInputType.text,
                  error: Translations.of(context).text("error_firstname_empty"),
                  maxLines: 1),
              InputWithIconWidget(
                  ctrl: surname,
                  hint: Translations.of(context).text("register_lastname"),
                  icon: Icons.person,
                  type: TextInputType.text,
                  error: Translations.of(context).text("error_lastname_empty"),
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
                checked: TranslationMapper.translateList(
                    SchoolSubjectExtension.getLabelsFromList(pickedSubjects),
                    context),
                activeColor: ThemeGlobalColor().mainColorDark,
                labelStyle: ThemeGlobalText().text,
              ),
              Text(Translations.of(context).text("specializations"),
                  style: ThemeGlobalText().titleText),
              CheckboxGroup(
                onSelected: onSpecializationsValuesChanged,
                labels: TranslationMapper.translateList(
                    SpecializationExtension.labels, context),
                checked: TranslationMapper.translateList(
                    SpecializationExtension.getLabelsFromList(
                        pickedSpecializations),
                    context),
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
                picked: Translations.of(context).text(pickedCoachType.label),
                activeColor: ThemeGlobalColor().mainColorDark,
              ),
              Text(Translations.of(context).text("max_availability"),
                  style: ThemeGlobalText().titleText),
              Text(Translations.of(context).text("hours_per_week"),
                  style: ThemeGlobalText().smallText),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: SliderWidget(
                      initValue: maxAvailability != null ? maxAvailability : 0,
                      min: 0,
                      max: 8,
                      onChanged: onMaxAvailabilityValueChanged)),
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
        )));
  }

  @protected
  Widget showExpertForm() {
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
                  child:
                      imagePath != null ? Image.asset(imagePath) : Container()),
              InputWithIconWidget(
                  ctrl: name,
                  hint: Translations.of(context).text("register_firstname"),
                  icon: Icons.person,
                  type: TextInputType.text,
                  error: Translations.of(context).text("error_firstname_empty"),
                  maxLines: 1),
              InputWithIconWidget(
                  ctrl: surname,
                  hint: Translations.of(context).text("register_lastname"),
                  icon: Icons.person,
                  type: TextInputType.text,
                  error: Translations.of(context).text("error_lastname_empty"),
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
                checked: TranslationMapper.translateList(
                    SchoolSubjectExtension.getLabelsFromList(pickedSubjects),
                    context),
                activeColor: ThemeGlobalColor().mainColorDark,
                labelStyle: ThemeGlobalText().text,
              ),
              Text(Translations.of(context).text("specializations"),
                  style: ThemeGlobalText().titleText),
              CheckboxGroup(
                onSelected: onSpecializationsValuesChanged,
                labels: TranslationMapper.translateList(
                    SpecializationExtension.labels, context),
                checked: TranslationMapper.translateList(
                    SpecializationExtension.getLabelsFromList(
                        pickedSpecializations),
                    context),
                activeColor: ThemeGlobalColor().mainColorDark,
                labelStyle: ThemeGlobalText().text,
              ),
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
        )));
  }

  @protected
  void onCoachTypeValueChanged(String newValue) {
    setState(() {
      pickedCoachType =
          CoachTypeExtension.getValue(Translations.of(context).key(newValue));
    });
  }

  @protected
  void onSpecializationsValuesChanged(List<String> selected) {
    setState(() {
      pickedSpecializations = SpecializationExtension.getValuesFromLabels(
          TranslationMapper.labelsFromTranslation(selected, context));
    });
  }

  @protected
  void onSubjectsValuesChanged(List<String> selected) {
    setState(() {
      pickedSubjects = SchoolSubjectExtension.getValuesFromLabels(
          TranslationMapper.labelsFromTranslation(selected, context));
    });
  }

  @protected
  void onMaxAvailabilityValueChanged(int maxAvailability) {
    setState(() {
      this.maxAvailability = maxAvailability;
    });
  }

  @protected
  void onPlacePicked(String placeId) {
    if (placeId != null) {
      schoolId = placeId;
    }
  }
}
