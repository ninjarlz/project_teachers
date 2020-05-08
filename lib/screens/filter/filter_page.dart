import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/coach_filtering_serivce.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/button/button_secondary.dart';
import 'package:project_teachers/widgets/input/places_input_with_icon.dart';
import 'package:project_teachers/widgets/slider/slider_widget.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  CoachFilteringService _filteringService;
  AppStateManager _appStateManager;
  String _pickedCoachTypeTranslation;
  List<String> _pickedSubjectsTranslation;
  List<String> _pickedSpecializationsTranslation;
  List<String> _coachTypeRadioLabels = List<String>();
  TextEditingController _schoolCtrl = TextEditingController();
  String _schoolId;
  int _maxAvailability = 0;
  int _remainingAvailability = 0;
  UserService _userService;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _filteringService = CoachFilteringService.instance;
    _userService = UserService.instance;
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      setState(() {
        _pickedSpecializationsTranslation = TranslationMapper.translateList(
            SpecializationExtension.getLabelsFromList(
                _filteringService.activeSpecializations),
            context);
        _pickedSubjectsTranslation = TranslationMapper.translateList(
            SchoolSubjectExtension.getLabelsFromList(
                _filteringService.activeSchoolSubjects),
            context);
        if (_filteringService.activeCoachType == null) {
          _pickedCoachTypeTranslation = Translations.of(context).text("all");
        } else {
          _pickedCoachTypeTranslation = Translations.of(context)
              .text(_filteringService.activeCoachType.label);
        }
        if (_filteringService.schoolId != null) {
          _schoolId = _filteringService.schoolId;
          _schoolCtrl.text = _filteringService.schoolName;
        }
        if (_filteringService.activeMaxAvailability == null) {
          _maxAvailability = 0;
        } else {
          _maxAvailability = _filteringService.activeMaxAvailability;
        }
        if (_filteringService.activeRemainingAvailability == null) {
          _remainingAvailability = 0;
        } else {
          _remainingAvailability =
              _filteringService.activeRemainingAvailability;
        }
        _coachTypeRadioLabels.add(Translations.of(context).text("all"));
        _coachTypeRadioLabels.addAll(TranslationMapper.translateList(
            CoachTypeExtension.labels, context));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return showFilters();
  }

  Widget showFilters() {
    return Container(
        margin: EdgeInsets.only(top: 10),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("subjects"),
                    style: ThemeGlobalText().titleText),
              ),
              CheckboxGroup(
                onSelected: _onSubjectsValuesChanged,
                labels: TranslationMapper.translateList(
                    SchoolSubjectExtension.labels, context),
                checked: _pickedSubjectsTranslation,
                activeColor: ThemeGlobalColor().mainColorDark,
                labelStyle: ThemeGlobalText().text,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("specializations"),
                    style: ThemeGlobalText().titleText),
              ),
              CheckboxGroup(
                onSelected: _onSpecializationsValuesChanged,
                labels: TranslationMapper.translateList(
                    SpecializationExtension.labels, context),
                checked: _pickedSpecializationsTranslation,
                activeColor: ThemeGlobalColor().mainColorDark,
                labelStyle: ThemeGlobalText().text,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("coach_type"),
                    style: ThemeGlobalText().titleText),
              ),
              RadioButtonGroup(
                labels: _coachTypeRadioLabels,
                onSelected: _onCoachTypeValueChanged,
                labelStyle: ThemeGlobalText().text,
                picked: _pickedCoachTypeTranslation,
                activeColor: ThemeGlobalColor().mainColorDark,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("register_school"),
                    style: ThemeGlobalText().titleText),
              ),
              Padding(
                  padding: EdgeInsets.all(15),
                  child: PlacesInputWithIconWidget(
                      ctrl: _schoolCtrl,
                      hint: Translations.of(context).text("register_school"),
                      icon: Icons.school,
                      error: Translations.of(context).text("error_school"),
                      placesTypes: ["school", "university"],
                      language: Translations.of(context).text("language"),
                      onPlacePicked: _onPlacePicked)),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("max_availability"),
                    style: ThemeGlobalText().titleText),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("hours_per_week"),
                    style: ThemeGlobalText().smallText),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: SliderWidget(
                    initValue: _maxAvailability,
                    min: 0,
                    max: 8,
                    onChanged: _onMaxAvailabilityValueChanged),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                    Translations.of(context).text("remaining_availability"),
                    style: ThemeGlobalText().titleText),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("hours_this_week"),
                    style: ThemeGlobalText().smallText),
              ),
              Padding(
                padding: EdgeInsets.all(15),
                child: _maxAvailability != 0
                    ? SliderWidget(
                        initValue: _remainingAvailability,
                        min: 0,
                        max: _maxAvailability,
                        onChanged: _onRemainingAvailabilityValueChanged)
                    : Text("-", style: ThemeGlobalText().titleText),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: ButtonPrimaryWidget(
                    text: Translations.of(context).text("apply"),
                    submit: applyFilters),
              ),
              ButtonSecondaryWidget(
                  text: Translations.of(context).text("global_back"),
                  submit: onBack),
            ],
          ),
        )));
  }

  void onBack() {
    _appStateManager.changeAppState(AppState.COACH);
  }

  void applyFilters() {
    if (_validateAndSave()) {
      _filteringService.searchFilter = null;
      _filteringService.activeSchoolSubjects =
          SchoolSubjectExtension.getValuesFromLabels(
              TranslationMapper.labelsFromTranslation(
                  _pickedSubjectsTranslation, context));
      _filteringService.activeSpecializations =
          SpecializationExtension.getValuesFromLabels(
              TranslationMapper.labelsFromTranslation(
                  _pickedSpecializationsTranslation, context));
      if (_pickedCoachTypeTranslation != Translations.of(context).text("all")) {
        _filteringService.activeCoachType = CoachTypeExtension.getValue(
            Translations.of(context).key(_pickedCoachTypeTranslation));
      } else {
        _filteringService.activeCoachType = null;
      }
      if (_maxAvailability == 0) {
        _filteringService.activeMaxAvailability = null;
      } else {
        _filteringService.activeMaxAvailability = _maxAvailability;
      }
      if (_remainingAvailability == 0) {
        _filteringService.activeRemainingAvailability = null;
      } else {
        _filteringService.activeRemainingAvailability = _remainingAvailability;
      }
      if (_schoolId != null) {
        _filteringService.schoolId = _schoolId;
        _filteringService.schoolName = _schoolCtrl.text;
      } else {
        _filteringService.schoolId = null;
        _filteringService.schoolName = null;
      }
      _userService.resetCoachList();
      _userService.updateCoachList();
      _appStateManager.changeAppState(AppState.COACH);
    }
  }

  void _onCoachTypeValueChanged(String newValue) {
    setState(() {
      _pickedCoachTypeTranslation = newValue;
    });
  }

  void _onSpecializationsValuesChanged(List<String> selected) {
    setState(() {
      _pickedSpecializationsTranslation = selected;
    });
  }

  void _onSubjectsValuesChanged(List<String> selected) {
    setState(() {
      _pickedSubjectsTranslation = selected;
    });
  }

  void _onMaxAvailabilityValueChanged(int maxAvailability) {
    setState(() {
      _maxAvailability = maxAvailability;
      _remainingAvailability = 0;
    });
  }

  void _onRemainingAvailabilityValueChanged(int remainingAvailability) {
    setState(() {
      _remainingAvailability = remainingAvailability;
    });
  }

  void _onPlacePicked(String placeId) {
    if (placeId == null) {
      _schoolCtrl.text = "";
    }
    _schoolId = placeId;
  }

  bool _validateAndSave() {
    if (_schoolCtrl.text == null || _schoolCtrl.text == "") {
      return true;
    }
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
