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
  List<String> _sortByRadioLabels = List<String>();
  String _pickedSortByLabel;
  List<String> _subjectsTranslations = List<String>();
  String _pickedSubjectTranslation;
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
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      setState(() {
        _sortByRadioLabels.add(Translations.of(context).text("date"));
        _sortByRadioLabels
            .add(Translations.of(context).text("number_of_reactions"));
        _sortByRadioLabels
            .add(Translations.of(context).text("number_of_answers"));
        if (_filteringService.orderingField ==
            _filteringService.orderingValues[0]) {
          _pickedSortByLabel = _sortByRadioLabels[0];
        } else if (_filteringService.orderingField ==
            _filteringService.orderingValues[1]) {
          _pickedSortByLabel = _sortByRadioLabels[1];
        } else {
          _pickedSortByLabel = _sortByRadioLabels[2];
        }
        _subjectsTranslations = TranslationMapper.translateList(
            SchoolSubjectExtension.labels, this.context);
        _subjectsTranslations.insert(0, Translations.of(context).text("all"));
        if (_filteringService.selectedSubject == null) {
          _pickedSubjectTranslation = _subjectsTranslations[0];
        } else {
          _pickedSubjectTranslation = Translations.of(context)
              .text(_filteringService.selectedSubject.label);
        }
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
                child: Text(Translations.of(context).text("sort_by"),
                    style: ThemeGlobalText().titleText),
              ),
              RadioButtonGroup(
                labels: _sortByRadioLabels,
                onSelected: _onSortByValueChanged,
                labelStyle: ThemeGlobalText().text,
                picked: _pickedSortByLabel,
                activeColor: ThemeGlobalColor().mainColorDark,
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(Translations.of(context).text("subject"),
                    style: ThemeGlobalText().titleText),
              ),
              RadioButtonGroup(
                onSelected: _onSubjectValueChanged,
                labels: _subjectsTranslations,
                picked: _pickedSubjectTranslation,
                activeColor: ThemeGlobalColor().mainColorDark,
                labelStyle: ThemeGlobalText().text,
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
                            String tag = value.substring(0, whiteSpaceIndex);
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

  void _onSortByValueChanged(String value) {
    setState(() {
      _pickedSortByLabel = value;
    });
  }

  void _onSubjectValueChanged(String value) {
    setState(() {
      _pickedSubjectTranslation = value;
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
      if (_pickedSubjectTranslation == _subjectsTranslations[0]) {
        _filteringService.selectedSubject = null;
      } else {
        _filteringService.selectedSubject = SchoolSubjectExtension.getValue(
            Translations.of(context).key(_pickedSubjectTranslation));
      }
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
