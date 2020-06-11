import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/filtering/user_filtering_serivce.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/input/places_input_with_icon.dart';
import 'package:project_teachers/widgets/slider/slider_widget.dart';
import 'package:provider/provider.dart';

class UserFilterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserFilterPageState();
}

class _UserFilterPageState extends State<UserFilterPage> {
  UserFilteringService _filteringService;
  AppStateManager _appStateManager;
  UserType _pickedUserType;
  CoachType _pickedCoachType;
  List<SchoolSubject> _pickedSubjects;
  List<Specialization> _pickedSpecializations;
  TextEditingController _schoolCtrl = TextEditingController();
  String _schoolId;
  int _maxAvailability = 0;
  int _remainingAvailability = 0;
  UserService _userService;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isExtendedForCoaches = false;

  @override
  void initState() {
    super.initState();
    _filteringService = UserFilteringService.instance;
    _userService = UserService.instance;
    if (_filteringService.activeUserType == null) {
      _isExtendedForCoaches = false;
    } else {
      _pickedUserType = _filteringService.activeUserType;
      _isExtendedForCoaches =
          _filteringService.activeUserType == UserType.COACH;
      if (_isExtendedForCoaches) {
        if (_filteringService.activeCoachType != null) {
          _pickedCoachType = _filteringService.activeCoachType;
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
      }
    }
    _pickedSpecializations = _filteringService.activeSpecializations;
    _pickedSubjects =
        _filteringService.activeSchoolSubjects;
    if (_filteringService.schoolId != null) {
      _schoolId = _filteringService.schoolId;
      _schoolCtrl.text = _filteringService.schoolName;
    }
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(child: showFilters());
  }

  Widget _buildUserTypeRadioButtons() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(Translations.of(context).text("user_type"),
            style: ThemeGlobalText().titleText),
      ),
      RadioButtonGroup(
        labels: [Translations.of(context).text("all")] +
            TranslationMapper.translateList(UserTypeExtension.labels, context),
        onSelected: _onUserTypeValueChanged,
        labelStyle: ThemeGlobalText().text,
        picked: _pickedUserType != null
            ? Translations.of(context).text(_pickedUserType.label)
            : Translations.of(context).text("all"),
        activeColor: ThemeGlobalColor().mainColorDark,
      ),
    ]);
  }

  Widget _buildCommonFilterPart() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(Translations.of(context).text("subjects"),
            style: ThemeGlobalText().titleText),
      ),
      CheckboxGroup(
        onSelected: _onSubjectsValuesChanged,
        labels: TranslationMapper.translateList(
            SchoolSubjectExtension.editableLabels, context),
        checked: TranslationMapper.translateList(SchoolSubjectExtension.getLabelsFromList(_pickedSubjects), context),
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
        checked: TranslationMapper.translateList(SpecializationExtension.getLabelsFromList(_pickedSpecializations), context),
        activeColor: ThemeGlobalColor().mainColorDark,
        labelStyle: ThemeGlobalText().text,
      ),
      Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(Translations.of(context).text("register_school"),
            style: ThemeGlobalText().titleText),
      ),
      Padding(
          padding: EdgeInsets.all(15),
          child: Row(children: [
            Expanded(
                child: PlacesInputWithIconWidget(
                    ctrl: _schoolCtrl,
                    hint: Translations.of(context).text("register_school"),
                    icon: Icons.school,
                    error: Translations.of(context).text("error_school"),
                    placesTypes: ["school", "university"],
                    language: Translations.of(context).text("language"),
                    onPlacePicked: _onPlacePicked)),
            IconButton(
              icon: Icon(Icons.clear, color: Colors.red),
              onPressed: () {
                setState(() {
                  _schoolCtrl.clear();
                  _schoolId = null;
                });
              },
            )
          ], mainAxisAlignment: MainAxisAlignment.spaceAround))
    ]);
  }

  Widget _buildCoachFilterPart() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: EdgeInsets.only(left: 20),
        child: Text(Translations.of(context).text("coach_type"),
            style: ThemeGlobalText().titleText),
      ),
      RadioButtonGroup(
        labels: [Translations.of(context).text("all")] +
            TranslationMapper.translateList(CoachTypeExtension.labels, context),
        onSelected: _onCoachTypeValueChanged,
        labelStyle: ThemeGlobalText().text,
        picked: _pickedCoachType != null
            ? Translations.of(context).text(_pickedCoachType.label)
            : Translations.of(context).text("all"),
        activeColor: ThemeGlobalColor().mainColorDark,
      ),
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
        child: Text(Translations.of(context).text("remaining_availability"),
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
    ]);
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
              _buildUserTypeRadioButtons(),
              _buildCommonFilterPart(),
              _isExtendedForCoaches ? _buildCoachFilterPart() : Container(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: ButtonPrimaryWidget(
                    text: Translations.of(context).text("apply"),
                    submit: applyFilters),
              ),
            ],
          ),
        )));
  }

  void applyFilters() {
    if (_validateAndSave()) {
      _filteringService.searchFilter = null;
      _filteringService.activeSchoolSubjects = _pickedSubjects;
      _filteringService.activeSpecializations = _pickedSpecializations;
      if (_schoolId != null) {
        _filteringService.schoolId = _schoolId;
        _filteringService.schoolName = _schoolCtrl.text;
      } else {
        _filteringService.schoolId = null;
        _filteringService.schoolName = null;
      }
      _filteringService.activeUserType = _pickedUserType;
      if (_pickedUserType != null) {
        if (_filteringService.activeUserType == UserType.COACH) {
          _filteringService.activeCoachType = _pickedCoachType;
          if (_maxAvailability == 0) {
            _filteringService.activeMaxAvailability = null;
          } else {
            _filteringService.activeMaxAvailability = _maxAvailability;
          }
          if (_remainingAvailability == 0) {
            _filteringService.activeRemainingAvailability = null;
          } else {
            _filteringService.activeRemainingAvailability =
                _remainingAvailability;
          }
        }
      }
      _userService.resetUserList();
      _userService.updateUserList();
      _appStateManager.changeAppState(AppState.USER_LIST);
    }
  }

  void _onCoachTypeValueChanged(String newValue) {
    setState(() {
      if (newValue == Translations.of(context).text("all")) {
      _pickedCoachType = null;
    } else {
      _pickedCoachType = CoachTypeExtension.getValue(Translations.of(context).key(newValue));}
    });
  }

  void _onUserTypeValueChanged(String newValue) {
    setState(() {
      if (newValue == Translations.of(context).text("all")) {
        _pickedUserType = null;
        _isExtendedForCoaches = false;
      } else {
        _pickedUserType = UserTypeExtension.getValue(Translations.of(context).key(newValue));
        _isExtendedForCoaches = _pickedUserType == UserType.COACH;
      }
    });
  }

  void _onSpecializationsValuesChanged(List<String> selected) {
    setState(() {
      _pickedSpecializations = SpecializationExtension.getValuesFromLabels(TranslationMapper.labelsFromTranslation(selected, context));
    });
  }

  void _onSubjectsValuesChanged(List<String> selected) {
    setState(() {
      _pickedSubjects = SchoolSubjectExtension.getValuesFromLabels(TranslationMapper.labelsFromTranslation(selected, context));
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
