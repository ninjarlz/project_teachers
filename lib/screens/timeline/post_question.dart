import 'package:flutter/material.dart';
import 'package:project_teachers/screens/timeline/base_post.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/timeline/tag_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
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
  TextEditingController _tagsCtrl = TextEditingController();
  GlobalKey<FormState> _tagFormKey = GlobalKey<FormState>();
  TagService _tagService;

  @override
  void initState() {
    super.initState();
    _tagService = TagService.instance;
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
    List<String> fileNames = fileList
        .map((file) => Uuid().generateV4() + basename(file.path))
        .toList();
    String questionId =
        await timelineService.sendQuestion(content.text, _tags, fileNames);
    await storageService.uploadQuestionImages(
        imageList, fileList, fileNames, questionId);
    appStateManager.previousState();
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
        if (_tags.contains(tag)) {
          errorMessage =
              Translations.of(this.context).text("error_tag_already_present");
        } else if (_tags.length == 10) {
          errorMessage =
              Translations.of(this.context).text("error_tag_up_to_10");
        } else {
          _tags.add(tag);
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
              buildErrorMsg(),
              buildPostButton()
            ],
          ),
        ));
  }
}