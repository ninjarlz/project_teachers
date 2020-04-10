import 'package:flutter/material.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:project_teachers/screens/home/index.dart';
import 'package:project_teachers/services/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/index.dart';

class Login extends StatefulWidget {
  Login({this.loginCallback});

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  BaseAuth _auth;
  bool _isLoading = false;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _isLoginForm = true;
  String _errorMessage;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValidEmailAddressRepository _validEmailAddressRepository;
  String INVALID_EMAIL_MSG;
  String NOT_VERIFIED_EMAIL_MSG;
  String ACTIVATE_EMAIL_MSG;

  @override
  void initState() {
    super.initState();
    _validEmailAddressRepository = ValidEmailAddressRepository.instance;
    _auth = Auth.instance;
    Future.delayed(Duration.zero, () {
      INVALID_EMAIL_MSG = Translations.of(context).text("error_email_invalid");
      NOT_VERIFIED_EMAIL_MSG = Translations.of(context).text("error_email_unverified");
      ACTIVATE_EMAIL_MSG = Translations.of(context).text("login_code_sent");
    });
  }


  void _toggleFormMode() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  void _goToPasswordRecovery() {}

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      String userId;
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      try {
        if (_isLoginForm) {
          _auth.signIn(_email.text, _password.text).then((user) {
            if (user.isEmailVerified) {
              widget.loginCallback();
              userId = user.uid;
              print('Signed in: $userId');
            }
            else {
              setState(() {
                _isLoading = false;
                _errorMessage = NOT_VERIFIED_EMAIL_MSG;
                print(NOT_VERIFIED_EMAIL_MSG);
                _auth.signOut();
              });
            }
            setState(() {
              _isLoading = false;
              _formKey.currentState.reset();;
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
        }
        else {
          bool isEmailValid = await _validEmailAddressRepository.checkIfAddressIsValid(_email.text);
          if (isEmailValid) {
            userId = await _auth.signUp(_email.text, _password.text);
            _validEmailAddressRepository.markAddressAsValidated(_email.text);
            _auth.sendEmailVerification();
            _errorMessage = ACTIVATE_EMAIL_MSG;
            print('Signed up user: $userId');
          }
          else {
            setState(() {
              _errorMessage = INVALID_EMAIL_MSG;
              print(INVALID_EMAIL_MSG);
            });
          }
          setState(() {
            _isLoading = false;
            _formKey.currentState.reset();
            FocusScope.of(context).unfocus();
          });
        }
      }
      catch (e) {
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

  Widget _showLogo() {
    return Hero(
        tag: 'hero',
        child: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
            child: CircleAvatar(backgroundColor: Colors.transparent, radius: 100.0, child: Image.asset("assets/img/logo.png"))));
  }

  Widget _showForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            InputWithIconWidget(ctrl: _email, hint: Translations.of(context).text("login_email"), icon: Icons.email, type: TextInputType.emailAddress, error: Translations.of(context).text("error_email_empty")),
            InputWithIconWidget(ctrl: _password, hint: Translations.of(context).text("login_password"), icon: Icons.lock, type: TextInputType.visiblePassword, error: Translations.of(context).text("error_password_empty")),
            Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Center(child: TextErrorWidget(text: _errorMessage)),),
            ButtonPrimaryWidget(text: _isLoginForm ? Translations.of(context).text("login") : Translations.of(context).text("register"), submit: _validateAndSubmit),
            ButtonSecondaryWidget(text: _isLoginForm ? Translations.of(context).text("register") : Translations.of(context).text("login_have_account"), submit: _toggleFormMode),
            ButtonSecondaryWidget(text: Translations.of(context).text("login_password_forgotten"), submit: _goToPasswordRecovery, size: 12,),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[_showForm(), AnimationCircularProgressWidget(status: _isLoading)],
      ),
    );
  }
}
