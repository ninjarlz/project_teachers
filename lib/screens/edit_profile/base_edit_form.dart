import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/auth.dart';
import 'package:project_teachers/services/auth_status_manager.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/services/valid_email_address_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/constants/constants.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/button/button_secondary.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/widgets/input/input_with_icon.dart';
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
  TextEditingController city = TextEditingController();
  @protected
  TextEditingController profession = TextEditingController();
  @protected
  TextEditingController bio = TextEditingController();
  @protected
  String pickedCoachTypeTranslation;
  @protected
  List<String> pickedSubjectsTranslation;
  @protected
  List<String> pickedSpecializationsTranslation;
  @protected
  AuthStatusManager authStatusManager;
  @protected
  AppStateManager appStateManager;
  @protected
  String imagePath;
  @protected
  String submitLabel;
  @protected
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: Constants.API_KEY);

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
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                height: imagePath != null ? 150 : 0,
                margin: EdgeInsets.all(10),
                child: imagePath != null ? Image.asset(imagePath) : null),
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
                language: Translations.of(context).text("language")),
            InputWithIconWidget(
                ctrl: profession,
                hint: Translations.of(context).text("register_profession"),
                icon: Icons.work,
                type: TextInputType.text,
                error: Translations.of(context).text("error_profession_empty"),
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
              labels: TranslationMapper.translateList(SchoolSubjectExtension.labels, context),
              checked: pickedSubjectsTranslation,
              activeColor: ThemeGlobalColor().secondaryColorDark,
              labelStyle: ThemeGlobalText().text,
            ),
            Text(Translations.of(context).text("specializations"),
                style: ThemeGlobalText().titleText),
            CheckboxGroup(
              onSelected: onSpecializationsValuesChanged,
              labels: TranslationMapper.translateList(SpecializationExtension.labels, context),
              checked: pickedSpecializationsTranslation,
              activeColor: ThemeGlobalColor().secondaryColorDark,
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
              activeColor: ThemeGlobalColor().secondaryColorDark,
            ),
            Text(Translations.of(context).text("max_availability_hours_per_week"),
                style: ThemeGlobalText().titleText),
            Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: SliderWidget(min: 0, max: 8),),
            ),
            ButtonPrimaryWidget(
                text: Translations.of(context).text(submitLabel),
                submit: validateAndSubmit),
            ButtonSecondaryWidget(
                text: Translations.of(context).text("global_back"),
                submit: onBack),
          ],
        ),
      ),
    );
  }

  @protected
  Widget showExpertForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                height: imagePath != null ? 150 : 0,
                margin: EdgeInsets.all(10),
                child: imagePath != null ? Image.asset(imagePath) : null),
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
                language: Translations.of(context).text("language")),
            InputWithIconWidget(
                ctrl: profession,
                hint: Translations.of(context).text("register_profession"),
                icon: Icons.work,
                type: TextInputType.text,
                error: Translations.of(context).text("error_profession_empty"),
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
              labels: TranslationMapper.translateList(SchoolSubjectExtension.labels, context),
              checked: pickedSubjectsTranslation,
              activeColor: ThemeGlobalColor().secondaryColorDark,
              labelStyle: ThemeGlobalText().text,
            ),
            Text(Translations.of(context).text("specializations"),
                style: ThemeGlobalText().titleText),
            CheckboxGroup(
              onSelected: onSpecializationsValuesChanged,
              labels: TranslationMapper.translateList(SpecializationExtension.labels, context),
              checked: pickedSpecializationsTranslation,
              activeColor: ThemeGlobalColor().secondaryColorDark,
              labelStyle: ThemeGlobalText().text,
            ),
            ButtonPrimaryWidget(
                text: Translations.of(context).text(submitLabel),
                submit: validateAndSubmit),
            ButtonSecondaryWidget(
                text: Translations.of(context).text("global_back"),
                submit: onBack),
          ],
        ),
      ),
    );
  }

  void onCoachTypeValueChanged(String newValue) {
    setState(() {
      pickedCoachTypeTranslation = newValue;
    });
  }

  void onSpecializationsValuesChanged(List<String> selected) {
    setState(() {
      pickedSpecializationsTranslation = selected;
    });
  }

  void onSubjectsValuesChanged(List<String> selected) {
    setState(() {
      pickedSubjectsTranslation = selected;
    });
  }
}
