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
import 'package:tuple/tuple.dart';

class EditQuestion extends StatefulWidget {
  static FloatingActionButton editQuestionFloatingActionButton(
      BuildContext context) {
    return FloatingActionButton(
        onPressed:
            Provider.of<AppStateManager>(context, listen: false).previousState,
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.arrow_back));
  }

  @override
  State<StatefulWidget> createState() => _EditQuestionState();
}

class _EditQuestionState extends BasePostState {
  List<String> _tags = List<String>();
  List<String> _subjectsTranslations = List<String>();
  String _pickedSubjectTranslation;
  TextEditingController _tagsCtrl = TextEditingController();
  GlobalKey<FormState> _tagFormKey = GlobalKey<FormState>();
  TagService _tagService;

  @override
  void initState() {
    super.initState();
    _tagService = TagService.instance;
    if (storageService.questionImages
        .containsKey(timelineService.editedQuestion.id)) {
      for (Tuple2<String, Image> tuple
          in storageService.questionImages[timelineService.editedQuestion.id]) {
        imageList.add(tuple.item2);
        fileList.add(tuple.item1);
      }
    }
    content.text = timelineService.editedQuestion.content;
    _tags.addAll(timelineService.editedQuestion.tags);
    Future.delayed(Duration.zero, () {
      setState(() {
        _subjectsTranslations = TranslationMapper.translateList(
            SchoolSubjectExtension.labels, this.context);
        _pickedSubjectTranslation = Translations.of(this.context)
            .text(timelineService.editedQuestion.schoolSubject.label);
      });
    });
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
    return SafeArea(
      child: Stack(
        children: <Widget>[
          showForm(),
          AnimationCircularProgressWidget(status: isLoading)
        ],
      ),
    );
  }

  @override
  Future<void> onSubmit() async {
    List<String> oldFileNames = List<String>();
    for (dynamic value in fileList) {
      if (value is String) {
        oldFileNames.add(value);
      }
    }
    List<String> fileNamesToDelete = List<String>();
    for (String fileName in timelineService.editedQuestion.photoNames) {
      if (!oldFileNames.contains(fileName)) {
        fileNamesToDelete.add(fileName);
      }
    }
    await storageService.deleteQuestionImages(
        fileNamesToDelete, timelineService.editedQuestion.id);
    List<String> fileNames = List<String>.from(fileList.map((value) {
      if (value is File) {
        return Uuid().generateV4() + basename(value.path);
      } else {
        return value;
      }
    }));

    List<String> tagsToRemove = List<String>();
    for (String tag in timelineService.editedQuestion.tags) {
      if (!_tags.contains(tag)) {
        tagsToRemove.add(tag);
      }
    }
    List<String> tagsToPost = List<String>();
    for (String tag in _tags) {
      if (!timelineService.editedQuestion.tags.contains(tag)) {
        tagsToPost.add(tag);
      }
    }

    await storageService.uploadQuestionImages(
        imageList, fileList, fileNames, timelineService.editedQuestion.id);
    await timelineService.updateQuestion(
        timelineService.editedQuestion.id,
        content.text,
        _tags,
        SchoolSubjectExtension.getValue(
            Translations.of(this.context).key(_pickedSubjectTranslation)),
        fileNames,
        tagsToPost,
        tagsToRemove);
    appStateManager.previousState();
  }

  Widget _buildSubjectsForm() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(Translations.of(this.context).text("subject"),
          style: ThemeGlobalText().titleText),
      RadioButtonGroup(
        onSelected: _onSubjectValueChanged,
        labels: _subjectsTranslations,
        picked: _pickedSubjectTranslation,
        activeColor: ThemeGlobalColor().mainColorDark,
        labelStyle: ThemeGlobalText().text,
      )
    ]);
  }

  void _onSubjectValueChanged(String value) {
    setState(() {
      _pickedSubjectTranslation = value;
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
              _buildSubjectsForm(),
              _buildTagsForm(),
              buildErrorMsg(),
              buildPostButton()
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    timelineService.editedQuestion = null;
  }
}
