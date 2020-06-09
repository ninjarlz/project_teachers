import 'package:flutter/material.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/validation/valid_email_address_service.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/index.dart';

class Login extends StatefulWidget {
  Login({this.loginCallback});

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

enum LoginState { REGISTER_FORM, LOGIN_FORM, FORGOT_PASSWORD_FORM }

class _LoginState extends State<Login> {
  BaseAuth _auth;
  bool _isLoading = false;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  LoginState _currentLoginState = LoginState.LOGIN_FORM;
  String _errorMessage;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValidEmailAddressService _validEmailAddressService;
  String INVALID_EMAIL_MSG;
  String NOT_VERIFIED_EMAIL_MSG;
  String ACTIVATE_EMAIL_MSG;
  String PASSWORD_RESET_EMAIL_MSG;

  @override
  void initState() {
    super.initState();
    _validEmailAddressService = ValidEmailAddressService.instance;
    _auth = Auth.instance;
    Future.delayed(Duration.zero, () {
      INVALID_EMAIL_MSG = Translations.of(context).text("error_email_invalid");
      NOT_VERIFIED_EMAIL_MSG =
          Translations.of(context).text("error_email_unverified");
      ACTIVATE_EMAIL_MSG = Translations.of(context).text("login_code_sent");
      PASSWORD_RESET_EMAIL_MSG =
          Translations.of(context).text("reset_email_sent");
    });
  }

  void _setFormMode(LoginState loginState) {
    setState(() {
      _currentLoginState = loginState;
      _errorMessage = "";
      _formKey.currentState.reset();
    });
  }

  void _goToPasswordRecovery() {
    _setFormMode(LoginState.FORGOT_PASSWORD_FORM);
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      String userId;
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      try {
        switch (_currentLoginState) {
          case LoginState.LOGIN_FORM:
            _auth.signIn(_email.text, _password.text).then((user) {
              if (user.isEmailVerified) {
                widget.loginCallback();
                userId = user.uid;
                print('Signed in: $userId');
              } else {
                setState(() {
                  _isLoading = false;
                  _errorMessage = NOT_VERIFIED_EMAIL_MSG;
                  print(NOT_VERIFIED_EMAIL_MSG);
                  _auth.signOut();
                });
              }
              setState(() {
                _isLoading = false;
                _formKey.currentState.reset();
                FocusScope.of(context).unfocus();
              });
            }).catchError((e) {
              print("Error: $e");
              setState(() {
                _errorMessage = e.message;
                print(e.message);
                _isLoading = false;
                _formKey.currentState.reset();
                FocusScope.of(context).unfocus();
              });
            });
            break;

          case LoginState.REGISTER_FORM:
            bool isEmailValid = await _validEmailAddressService
                .checkIfAddressIsValid(_email.text);
            if (isEmailValid) {
              userId = await _auth.signUp(_email.text, _password.text);
              await _validEmailAddressService
                  .markAddressAsValidated(_email.text);
              await _auth.sendEmailVerification();
              _errorMessage = ACTIVATE_EMAIL_MSG;
              print('Signed up user: $userId');
            } else {
              setState(() {
                _errorMessage = INVALID_EMAIL_MSG;
                print(INVALID_EMAIL_MSG);
              });
            }
            setState(() {
              _isLoading = false;
              _currentLoginState = LoginState.LOGIN_FORM;
              _formKey.currentState.reset();
              FocusScope.of(context).unfocus();
            });
            break;

          case LoginState.FORGOT_PASSWORD_FORM:
            await _auth.sendResetPasswordEmail(_email.text);
            setState(() {
              _isLoading = false;
              _formKey.currentState.reset();
              _errorMessage = PASSWORD_RESET_EMAIL_MSG;
              print(PASSWORD_RESET_EMAIL_MSG);
              FocusScope.of(context).unfocus();
            });
            break;
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
          FocusScope.of(context).unfocus();
        });
      }
    }
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget _showForm() {
    String firstButtonTxt;
    String secondButtonTxt;
    Function onSecondButton;

    switch (_currentLoginState) {
      case LoginState.FORGOT_PASSWORD_FORM:
        firstButtonTxt = Translations.of(context).text("reset_email");
        secondButtonTxt = Translations.of(context).text("global_back");
        onSecondButton = () {
          _setFormMode(LoginState.LOGIN_FORM);
        };
        break;
      case LoginState.REGISTER_FORM:
        firstButtonTxt = Translations.of(context).text("register");
        secondButtonTxt = Translations.of(context).text("login_have_account");
        onSecondButton = () {
          _setFormMode(LoginState.LOGIN_FORM);
        };
        break;
      case LoginState.LOGIN_FORM:
        firstButtonTxt = Translations.of(context).text("login");
        secondButtonTxt = Translations.of(context).text("register");
        onSecondButton = () {
          _setFormMode(LoginState.REGISTER_FORM);
        };
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Image.asset("assets/img/logo.jpeg"),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(children: [
                InputWithIconWidget(
                    ctrl: _email,
                    hint: Translations.of(context).text("login_email"),
                    icon: Icons.email,
                    type: TextInputType.emailAddress,
                    error: Translations.of(context).text("error_email_empty"),
                    maxLines: 1),
                Visibility(
                    visible:
                        _currentLoginState != LoginState.FORGOT_PASSWORD_FORM,
                    child: InputWithIconWidget(
                        ctrl: _password,
                        hint: Translations.of(context).text("login_password"),
                        icon: Icons.lock,
                        type: TextInputType.visiblePassword,
                        maxLines: 1,
                        error: Translations.of(context)
                            .text("error_password_empty"))),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: TextErrorWidget(text: _errorMessage)),
                ),
                ButtonPrimaryWidget(
                    text: firstButtonTxt, submit: _validateAndSubmit),
                ButtonSecondaryWidget(
                    text: secondButtonTxt, submit: onSecondButton),
                Visibility(
                    visible:
                        _currentLoginState != LoginState.FORGOT_PASSWORD_FORM,
                    child: ButtonSecondaryWidget(
                      text: Translations.of(context)
                          .text("login_password_forgotten"),
                      submit: _goToPasswordRecovery,
                      size: 12,
                    ))
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeGlobalColor().backgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            _showForm(),
            AnimationCircularProgressWidget(status: _isLoading)
          ],
        ),
      ),
    );
  }
}
