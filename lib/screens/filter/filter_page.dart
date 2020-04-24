import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/filtering_serivce.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/button/button_secondary.dart';
import 'package:project_teachers/widgets/slider/slider_widget.dart';
import 'package:provider/provider.dart';

class FilterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  FilteringService _filteringService;
  AppStateManager _appStateManager;
  String _pickedCoachTypeTranslation;
  List<String> _pickedSubjectsTranslation;
  List<String> _pickedSpecializationsTranslation;
  List<String> _coachTypeRadioLabels = List<String>();
  UserService _userService;

  @override
  void initState() {
    super.initState();
    _filteringService = FilteringService.instance;
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
      padding: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text(Translations.of(context).text("subjects"),
              style: ThemeGlobalText().titleText),
          CheckboxGroup(
            onSelected: onSubjectsValuesChanged,
            labels: TranslationMapper.translateList(
                SchoolSubjectExtension.labels, context),
            checked: _pickedSubjectsTranslation,
            activeColor: ThemeGlobalColor().secondaryColorDark,
            labelStyle: ThemeGlobalText().text,
          ),
          Text(Translations.of(context).text("specializations"),
              style: ThemeGlobalText().titleText),
          CheckboxGroup(
            onSelected: onSpecializationsValuesChanged,
            labels: TranslationMapper.translateList(
                SpecializationExtension.labels, context),
            checked: _pickedSpecializationsTranslation,
            activeColor: ThemeGlobalColor().secondaryColorDark,
            labelStyle: ThemeGlobalText().text,
          ),
          Text(Translations.of(context).text("coach_type"),
              style: ThemeGlobalText().titleText),
          RadioButtonGroup(
            labels: _coachTypeRadioLabels,
            onSelected: onCoachTypeValueChanged,
            labelStyle: ThemeGlobalText().text,
            picked: _pickedCoachTypeTranslation,
            activeColor: ThemeGlobalColor().secondaryColorDark,
          ),
          Text(Translations.of(context).text("max_availability_hours_per_week"),
              style: ThemeGlobalText().titleText),
          Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: SliderWidget(min: 0, max: 8),),
          ),
          Text(Translations.of(context).text("remaining_availability_hours_in_this_week"),
              style: ThemeGlobalText().titleText),
          Padding(
            padding: EdgeInsets.all(8),
            child: Center(child: SliderWidget(min: 0, max: 8),),
          ),
          ButtonPrimaryWidget(
              text: Translations.of(context).text("apply"),
              submit: applyFilters),
          ButtonSecondaryWidget(
              text: Translations.of(context).text("global_back"),
              submit: onBack),
        ],
      ),
    );
  }

  void onBack() {
    _appStateManager.changeAppState(AppState.COACH);
  }

  void applyFilters() {
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
    _userService.resetCoachList();
    _appStateManager.changeAppState(AppState.COACH);
  }

  void onCoachTypeValueChanged(String newValue) {
    setState(() {
      _pickedCoachTypeTranslation = newValue;
    });
  }

  void onSpecializationsValuesChanged(List<String> selected) {
    setState(() {
      _pickedSpecializationsTranslation = selected;
    });
  }

  void onSubjectsValuesChanged(List<String> selected) {
    setState(() {
      _pickedSubjectsTranslation = selected;
    });
  }
}
