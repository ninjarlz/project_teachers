import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project_teachers/screens/timeline/base_post.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
import 'package:project_teachers/widgets/animation/animation_circular_progress.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

class EditAnswer extends StatefulWidget {
  static FloatingActionButton editAnswerFloatingActionButton(
      BuildContext context) {
    return FloatingActionButton(
        onPressed:
            Provider.of<AppStateManager>(context, listen: false).previousState,
        backgroundColor: ThemeGlobalColor().mainColor,
        child: Icon(Icons.arrow_back));
  }

  @override
  State<StatefulWidget> createState() => _EditAnswerState();
}

class _EditAnswerState extends BasePostState {
  @override
  void initState() {
    super.initState();
    if (storageService.answerImages
        .containsKey(timelineService.editedAnswer.id)) {
      for (Tuple2<String, Image> tuple
          in storageService.answerImages[timelineService.editedAnswer.id]) {
        imageList.add(tuple.item2);
        fileList.add(tuple.item1);
      }
    }
    content.text = timelineService.editedAnswer.content;
  }

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
    for (String fileName in timelineService.editedAnswer.photoNames) {
      if (!oldFileNames.contains(fileName)) {
        fileNamesToDelete.add(fileName);
      }
    }
    await storageService.deleteAnswerImages(
        fileNamesToDelete, timelineService.editedAnswer.id);
    List<String> fileNames = List<String>.from(fileList.map((value) {
      if (value is File) {
        return Uuid().generateV4() + basename(value.path);
      } else {
        return value;
      }
    }));
    await storageService.uploadAnswerImages(
        imageList, fileList, fileNames, timelineService.editedAnswer.id);
    await timelineService.updateAnswer(timelineService.selectedQuestion.id,
        timelineService.editedAnswer.id, content.text, fileNames);
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

  @override
  void dispose() {
    super.dispose();
    timelineService.editedAnswer = null;
  }
}
