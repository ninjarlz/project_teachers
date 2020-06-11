import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/filtering/question_filtering_service.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/timeline/tag_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/input/type_ahead_input_with_icon.dart';
import 'package:provider/provider.dart';

class QuestionFilterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuestionFilterPageState();
}

class _QuestionFilterPageState extends State<QuestionFilterPage> {
  QuestionFilteringService _filteringService;
  TagService _tagService;
  TimelineService _timelineService;
  AppStateManager _appStateManager;
  List<String> _sortByRadioLabels = [
    "date",
    "number_of_reactions",
    "number_of_answers"
  ];
  String _pickedSortByLabel;
  List<SchoolSubject> _subjects = List<SchoolSubject>();
  SchoolSubject _pickedSubject;
  TextEditingController _tagCtrl = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _filteringService = QuestionFilteringService.instance;
    _tagService = TagService.instance;
    _timelineService = TimelineService.instance;
    if (_filteringService.selectedTag != null &&
        _filteringService.selectedTag != "") {
      _tagCtrl.text = _filteringService.selectedTag;
    }
    if (_filteringService.orderingField ==
        _filteringService.orderingValues[0]) {
      _pickedSortByLabel = _sortByRadioLabels[0];
    } else if (_filteringService.orderingField ==
        _filteringService.orderingValues[1]) {
      _pickedSortByLabel = _sortByRadioLabels[1];
    } else {
      _pickedSortByLabel = _sortByRadioLabels[2];
    }
    _subjects = SchoolSubject.values;

    if (_filteringService.selectedSubject == null) {
      _pickedSubject = null;
    } else {
      _pickedSubject = _filteringService.selectedSubject;
    }
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return showFilters();
  }

  Widget showFilters() {
    return Scrollbar(
        child: Container(
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
                    child: Text(Translations.of(context).text("sort_by"),
                        style: ThemeGlobalText().titleText),
                  ),
                  RadioButtonGroup(
                    labels: TranslationMapper.translateList(
                        _sortByRadioLabels, context),
                    onSelected: _onSortByValueChanged,
                    labelStyle: ThemeGlobalText().text,
                    picked: Translations.of(context).text(_pickedSortByLabel),
                    activeColor: ThemeGlobalColor().mainColorDark,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(Translations.of(context).text("tag"),
                        style: ThemeGlobalText().titleText),
                  ),
                  Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(children: [
                        Expanded(
                          child: TypeAheadInputWithIconWidget(
                              ctrl: _tagCtrl,
                              hint: Translations.of(this.context).text("tag"),
                              icon: Icons.label,
                              type: TextInputType.text,
                              suggestionsCallback: (String value) async {
                                if (value == null || value == "") {
                                  return List<String>();
                                }
                                return await _tagService
                                    .getTagsSuggestionsStrings(value);
                              },
                              onSuggestionSelected: (String value) {
                                int whiteSpaceIndex = value.indexOf(" ");
                                String tag =
                                    value.substring(0, whiteSpaceIndex);
                                _tagCtrl.text = tag;
                              }),
                        ),
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _tagCtrl.clear();
                            });
                          },
                        )
                      ], mainAxisAlignment: MainAxisAlignment.spaceAround)),
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 5),
                    child: Text(Translations.of(context).text("subject"),
                        style: ThemeGlobalText().titleText),
                  ),
                  RadioButtonGroup(
                    onSelected: _onSubjectValueChanged,
                    labels: [Translations.of(context).text("all")] +
                        TranslationMapper.translateList(
                            SchoolSubjectExtension.getLabelsFromList(_subjects),
                            context),
                    picked: _pickedSubject == null
                        ? Translations.of(context).text("all")
                        : Translations.of(context).text(_pickedSubject.label),
                    activeColor: ThemeGlobalColor().mainColorDark,
                    labelStyle: ThemeGlobalText().text,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: ButtonPrimaryWidget(
                        text: Translations.of(context).text("apply"),
                        submit: applyFilters),
                  ),
                ],
              ),
            ))));
  }

  void _onSortByValueChanged(String value) {
    setState(() {
      _pickedSortByLabel = Translations.of(context).key(value);
    });
  }

  void _onSubjectValueChanged(String value) {
    setState(() {
      if (value == Translations.of(context).text("all")) {
        _pickedSubject = null;
      } else {
        _pickedSubject = SchoolSubjectExtension.getValue(
            Translations.of(context).key(value));
      }
    });
  }

  void applyFilters() {
    if (_validateAndSave()) {
      if (_pickedSortByLabel == _sortByRadioLabels[0]) {
        _filteringService.orderingField = _filteringService.orderingValues[0];
      } else if (_pickedSortByLabel == _sortByRadioLabels[1]) {
        _filteringService.orderingField = _filteringService.orderingValues[1];
      } else {
        _filteringService.orderingField = _filteringService.orderingValues[2];
      }
      _filteringService.selectedSubject = _pickedSubject;
      if (_tagCtrl.text != null && _tagCtrl.text != "") {
        _filteringService.selectedTag = _tagCtrl.text;
      } else {
        _filteringService.selectedTag = null;
      }
      _timelineService.resetQuestionList();
      _timelineService.updateQuestionList();
      _appStateManager.changeAppState(AppState.TIMELINE);
    }
  }

  bool _validateAndSave() {
    if (_tagCtrl.text == null || _tagCtrl.text == "") {
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
