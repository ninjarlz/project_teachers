import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:provider/provider.dart';
import '../../widgets/index.dart';

abstract class BasePostState<T extends StatefulWidget> extends State<T>
    implements UserListener, UserProfileImageListener {
  @protected
  bool isLoading;
  @protected
  GlobalKey<FormState> contentFormKey = GlobalKey<FormState>();
  @protected
  String errorMessage;
  @protected
  TextEditingController content = TextEditingController();
  @protected
  List<Image> imageList = List<Image>();
  @protected
  List<dynamic> fileList = List<dynamic>();
  @protected
  BaseAuth auth;
  @protected
  UserService userService;
  @protected
  StorageService storageService;
  @protected
  TimelineService timelineService;
  @protected
  AppStateManager appStateManager;

  @override
  void initState() {
    super.initState();
    auth = Auth.instance;
    userService = UserService.instance;
    storageService = StorageService.instance;
    timelineService = TimelineService.instance;
    userService.userListeners.add(this);
    storageService.userProfileImageListeners.add(this);
    Future.delayed(Duration.zero, () {
      appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  @protected
  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @protected
  bool validateAndSave();

  @protected
  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        errorMessage = "";
        isLoading = true;
      });
      try {
        if (auth.currentUser != null) {
          onSubmit();
        } else {
          setState(() {
            isLoading = false;
            errorMessage = Translations.of(context).text("error_unknown");
            contentFormKey.currentState.reset();
            FocusScope.of(context).unfocus();
          });
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          isLoading = false;
          errorMessage = e.message;
          contentFormKey.currentState.reset();
          FocusScope.of(context).unfocus();
        });
      }
    }
  }

  @protected
  Widget buildArticle() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: ArticleUserWidget(
          userId: userService.currentUser.uid,
          userName: userService.currentUser.name +
              " " +
              userService.currentUser.surname,
        ));
  }

  @protected
  Widget buildContentForm() {
    return Form(
        key: contentFormKey,
        child: InputWithIconWidget(
            ctrl: content,
            hint: Translations.of(context).text("content"),
            icon: Icons.edit,
            type: TextInputType.multiline,
            error: Translations.of(context).text("error_content_empty")));
  }

  @protected
  Widget buildImagesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListView.builder(
            itemBuilder: (context, index) {
              return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Stack(children: <Widget>[
                    imageList[index],
                    Align(
                        child: IconButton(
                          icon: Icon(Icons.clear, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              imageList.removeAt(index);
                              fileList.removeAt(index);
                            });
                          },
                        ),
                        alignment: Alignment.topRight)
                  ]));
            },
            physics: NeverScrollableScrollPhysics(),
            itemCount: imageList.length,
            shrinkWrap: true),
        ButtonPrimaryWidget(
            text: Translations.of(context).text("add_photo"), submit: addPhoto)
      ],
    );
  }

  Future<void> addPhoto() async {
    if (imageList.length == 3) {
      Fluttertoast.showToast(
          msg: Translations.of(context).text("error_images_up_to_3"));
      return;
    }
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 900,
        imageQuality: 80);
    if (image != null) {
      setState(() {
        imageList.add(Image.file(image));
        fileList.add(image);
      });
    }
  }

  @protected
  Widget buildPostButton() {
    return Padding(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ButtonPrimaryWidget(
                  text: Translations.of(context).text("post"),
                  submit: validateAndSubmit),
              ButtonSecondaryWidget(
                  text: Translations.of(context).text("global_back"),
                  submit: () {
                    AppStateManager appStateManager =
                        Provider.of<AppStateManager>(context, listen: false);
                    appStateManager.changeAppState(appStateManager.prevState);
                  }),
            ]),
        padding: EdgeInsets.symmetric(vertical: 20));
  }

  @protected
  Widget buildErrorMsg() {
    return Visibility(
        visible: errorMessage != null && errorMessage != "",
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Center(child: TextErrorWidget(text: errorMessage)),
        ));
  }

  @protected
  Future<void> onSubmit();

  @protected
  Widget showForm();

  @override
  void dispose() {
    super.dispose();
    userService.userListeners.remove(this);
    storageService.userProfileImageListeners.remove(this);
  }

  @override
  void onUserDataChange() {
    setState(() {});
  }

  @override
  void onUserProfileImageChange() {
    setState(() {});
  }
}
