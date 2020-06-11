import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/screens/timeline/base_post.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/timeline/tag_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
import 'package:project_teachers/utils/translations/translation_mapper.dart';
import 'package:project_teachers/widgets/animation/animation_circular_progress.dart';
import 'package:project_teachers/widgets/input/type_ahead_input_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class PostQuestion extends StatefulWidget {
  static FloatingActionButton postQuestionFloatingActionButton(
      BuildContext context) {
    return FloatingActionButton(
        onPressed:
            Provider.of<AppStateManager>(context, listen: false).previousState,
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.arrow_back));
  }

  @override
  State<StatefulWidget> createState() => _PostQuestionState();
}

class _PostQuestionState extends BasePostState {
  List<String> _tags = List<String>();
  SchoolSubject _pickedSubject;
  TextEditingController _tagsCtrl = TextEditingController();
  GlobalKey<FormState> _tagFormKey = GlobalKey<FormState>();
  TagService _tagService;

  @override
  void initState() {
    super.initState();
    _tagService = TagService.instance;
    _pickedSubject = SchoolSubject.values[1];
  }

  @override
  bool validateAndSave() {
    final form = contentFormKey.currentState;
    if (form.validate()) {
      form.save();
      if (_tags.length == 0) {
        setState(() {
          errorMessage = Translations.of(this.context).text("error_no_tag");
        });
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(child: SafeArea(
      child: Stack(
        children: <Widget>[
          showForm(),
          AnimationCircularProgressWidget(status: isLoading)
        ],
      ),
    ));
  }

  @override
  Future<void> onSubmit() async {
    List<String> fileNames = fileList
        .map((file) => Uuid().generateV4() + basename(file.path))
        .toList();
    String questionId = timelineService.generatePostId();
    await storageService.uploadQuestionImages(
        imageList, List<File>.from(fileList), fileNames, questionId);
    await timelineService.sendQuestion(
        questionId, content.text, _pickedSubject, _tags, fileNames);
    appStateManager.previousState();
  }

  Widget _buildSubjectsForm() {
    return Padding(
        padding: EdgeInsets.only(top: 5),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(Translations.of(this.context).text("subject"),
              style: ThemeGlobalText().titleText),
          RadioButtonGroup(
            onSelected: _onSubjectValueChanged,
            labels: TranslationMapper.translateList(
                SchoolSubjectExtension.editableLabels, this.context),
            picked: Translations.of(this.context).text(_pickedSubject.label),
            activeColor: ThemeGlobalColor().mainColorDark,
            labelStyle: ThemeGlobalText().text,
          )
        ]));
  }

  void _onSubjectValueChanged(String value) {
    setState(() {
      _pickedSubject = SchoolSubjectExtension.getValue(
          Translations.of(this.context).key(value));
    });
  }

  Widget _buildTagsForm() {
    return Form(
        key: _tagFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("#" + _tags[index],
                              style: ThemeGlobalText().tag),
                          IconButton(
                              icon: Icon(Icons.clear,
                                  color: ThemeGlobalColor().boxMsgColor),
                              onPressed: () {
                                setState(() {
                                  _tags.remove(_tags[index]);
                                  errorMessage = "";
                                });
                              })
                        ]);
                  },
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _tags.length,
                  shrinkWrap: true),
            ),
            TypeAheadInputWithIconWidget(
              ctrl: _tagsCtrl,
              error: Translations.of(this.context).text("error_tag_empty"),
              hint: Translations.of(this.context).text("add_tag"),
              icon: Icons.label,
              onFieldSubmitted: (String value) {
                addTag(value);
              },
              type: TextInputType.text,
              suggestionsCallback: (String value) async {
                if (value == null || value == "") {
                  return List<String>();
                }
                return await _tagService.getTagsSuggestionsStrings(value);
              },
              onSuggestionSelected: addTagFromSuggestion,
            ),
          ],
        ));
  }

  bool validateAndSaveTagsForm() {
    final form = _tagFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void addTag(String tag) {
    if (validateAndSaveTagsForm()) {
      setState(() {
        String formattedTag = tag.replaceAll("#", "").replaceAll(" ", "_");
        if (_tags.contains(formattedTag)) {
          errorMessage =
              Translations.of(this.context).text("error_tag_already_present");
        } else if (_tags.length == 10) {
          errorMessage =
              Translations.of(this.context).text("error_tag_up_to_10");
        } else {
          _tags.add(formattedTag);
          errorMessage = "";
        }
        _tagsCtrl.clear();
        _tagFormKey.currentState.reset();
        FocusScope.of(this.context).unfocus();
      });
    }
  }

  void addTagFromSuggestion(String suggestion) {
    int whiteSpaceIndex = suggestion.indexOf(" ");
    String tag = suggestion.substring(0, whiteSpaceIndex);
    addTag(tag);
  }

  @override
  Widget showForm() {
    return Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(this.context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildArticle(),
              buildContentForm(),
              buildImagesForm(),
              _buildTagsForm(),
              _buildSubjectsForm(),
              buildErrorMsg(),
              buildPostButton()
            ],
          ),
        ));
  }
}
