import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/model/app_state_manager.dart';
import 'package:project_teachers/model/auth_status_manager.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/animation/animation_circular_progress.dart';
import 'base_edit_form.dart';

enum EditFormStateEnum { USER_TYPE_DETERMINED, USER_TYPE_NOT_DETERMINED }

class InitialForm extends StatefulWidget {
  static const String TITLE = "Initial data form";

  @override
  State<StatefulWidget> createState() => _InitialFormState();
}

class _InitialFormState extends BaseEditFormState<InitialForm> {
  EditFormStateEnum _initialFormState =
      EditFormStateEnum.USER_TYPE_NOT_DETERMINED;

  @override
  void initState() {
    super.initState();
    submitLabel = "register_create";
    imagePath = "assets/img/icon_new.png";
    if (auth.currentUser != null) {
      validEmailAddressRepository
          .getUserType(auth.currentUser.email)
          .then((userType) {
        setState(() {
          userType = userType;
          _initialFormState = EditFormStateEnum.USER_TYPE_DETERMINED;
        });
      });
    }
  }

  @protected
  @override
  Future<void> onSubmit() async {
    String email = auth.currentUser.email;
    await validEmailAddressRepository.markAddressAsInitialized(email);
    await userRepository.setInitializedCurrentUser(auth.currentUser.uid, email,
        name.text, surname.text, city.text, school.text, profession.text);
    authStatusManager.changeAuthState(AuthStatus.LOGGED_IN);
    appStateManager.changeAppState(AppState.COACH);
  }

  @protected
  @override
  void onBack() {
    appStateManager.changeAppState(AppState.LOGIN);
    userRepository.logoutUser();
    authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
  }

  @override
  Widget build(BuildContext context) {
    switch (_initialFormState) {
      case EditFormStateEnum.USER_TYPE_NOT_DETERMINED:
        return buildWaitingScreen();
      case EditFormStateEnum.USER_TYPE_DETERMINED:
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: <Widget>[
                showForm(),
                AnimationCircularProgressWidget(status: isLoading)
              ],
            ),
          ),
        );
      default:
        return buildWaitingScreen();
    }
  }
}
