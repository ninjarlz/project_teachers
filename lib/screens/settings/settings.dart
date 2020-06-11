import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/managers/auth_status_manager.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/animation/animation_circular_progress.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/input/input_with_icon.dart';
import 'package:project_teachers/widgets/text/text_error.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isLoading = false;
  String _resetPasswordErrorMessage;
  String _deleteAccountErrorMessage;
  BaseAuth _auth;
  UserService _userService;
  AppStateManager _appStateManager;
  AuthStatusManager _authStatusManager;
  bool _showDeleteConfirmation = false;
  TextEditingController _confirmTextEditingController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _auth = Auth.instance;
    _userService = UserService.instance;
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
      _authStatusManager =
          Provider.of<AuthStatusManager>(context, listen: false);
    });
  }

  void _showDeleteConfirmationForm() {
    if (!_showDeleteConfirmation) {
      setState(() {
        _resetPasswordErrorMessage = "";
        _showDeleteConfirmation = true;
      });
    }
  }

  bool _validateAndSave() {
    if (_confirmTextEditingController.text !=
        Translations.of(context).text("confirm")) {
      return false;
    }
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _resetPassword() async {
    setState(() {
      _resetPasswordErrorMessage = "";
      _deleteAccountErrorMessage = "";
      _showDeleteConfirmation = false;
      _isLoading = true;
    });
    try {
      await _auth.sendResetPasswordEmail(_userService.currentUser.email);
      setState(() {
        _isLoading = false;
        _resetPasswordErrorMessage =
            Translations.of(context).text("reset_email_sent");
        print(Translations.of(context).text("reset_email_sent"));
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
        _resetPasswordErrorMessage = e.message;
      });
    }
  }

  Future<void> _deleteAccount() async {
    if (_validateAndSave()) {
      setState(() {
        _resetPasswordErrorMessage = "";
        _deleteAccountErrorMessage = "";
        _isLoading = true;
      });
      try {
        await _userService.deleteUserAccount();
        setState(() {
          _isLoading = false;
          FocusScope.of(context).unfocus();
          _auth.signOut();
          _userService.logoutUser();
          _authStatusManager.changeAuthState(AuthStatus.NOT_LOGGED_IN);
          _appStateManager.changeAppState(AppState.LOGIN);
        });
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          _showDeleteConfirmation = false;
          _deleteAccountErrorMessage = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(child: Stack(children: [
      Padding(
          padding: EdgeInsets.all(16),
          child: ListView(shrinkWrap: true, children: <Widget>[
            ButtonPrimaryWidget(
                text: Translations.of(context).text("reset_email"),
                submit: _resetPassword),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Center(
                  child: TextErrorWidget(text: _resetPasswordErrorMessage)),
            ),
            ButtonPrimaryWidget(
                text: Translations.of(context).text("delete_account"),
                submit: _showDeleteConfirmationForm),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Center(
                  child: TextErrorWidget(
                      text: _showDeleteConfirmation
                          ? Translations.of(context)
                          .text("delete_account_confirm")
                          : _deleteAccountErrorMessage)),
            ),
            Visibility(
                visible: _showDeleteConfirmation,
                child: Column(children: [
                  Form(
                      key: _formKey,
                      child: InputWithIconWidget(
                          ctrl: _confirmTextEditingController,
                          hint: Translations.of(context).text("confirm"),
                          icon: Icons.done,
                          type: TextInputType.text,
                          maxLines: 1,
                          error: Translations.of(context)
                              .text("error_confim_empty"))),
                  ButtonPrimaryWidget(
                      text: Translations.of(context).text("confirm"),
                      submit: _deleteAccount)
                ], crossAxisAlignment: CrossAxisAlignment.stretch)),
          ])),
      AnimationCircularProgressWidget(status: _isLoading)
    ]));
  }
}
