import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_teachers/screens/timeline/base_post.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
import 'package:project_teachers/widgets/animation/animation_circular_progress.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class PostAnswer extends StatefulWidget {
  static FloatingActionButton postAnswerFloatingActionButton(
      BuildContext context) {
    return FloatingActionButton(
        onPressed:
            Provider.of<AppStateManager>(context, listen: false).previousState,
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.arrow_back));
  }

  @override
  State<StatefulWidget> createState() => _PostAnswerState();
}

class _PostAnswerState extends BasePostState {

  @override
  bool validateAndSave() {
    final form = contentFormKey.currentState;
    if (form.validate()) {
      form.save();
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
    String answerId = timelineService.generatePostId();
    await storageService.uploadAnswerImages(
        imageList, List<File>.from(fileList), fileNames, answerId);
    await timelineService.sendQuestionAnswer(
        answerId,
        content.text,
        fileNames);
    appStateManager.previousState();
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
              buildErrorMsg(),
              buildPostButton()
            ],
          ),
        ));
  }
}
