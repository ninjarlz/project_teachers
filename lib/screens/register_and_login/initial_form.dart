import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:project_teachers/screens/home/index.dart';
import 'package:project_teachers/services/auth.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:project_teachers/translations/translations.dart';

enum InitialFormState { USER_TYPE_DETERMINED, USER_TYPE_NOT_DETERMINED }

// ignore: must_be_immutable
class InitialForm extends StatefulWidget {
  VoidCallback _initializedCallback;
  VoidCallback _logoutCallback;
  FirebaseUser _user;
  static const String TITLE = "Initial data form";

  InitialForm(VoidCallback initializedCallback, VoidCallback logoutCallback, FirebaseUser user) {
    _initializedCallback = initializedCallback;
    _logoutCallback = logoutCallback;
    _user = user;
  }

  InitialFormState initialFormState = InitialFormState.USER_TYPE_NOT_DETERMINED;

  @override
  State<StatefulWidget> createState() => _InitialFormState();
}

class _InitialFormState extends State<InitialForm> {
  UserRepository _userRepository;
  ValidEmailAddressRepository _validEmailAddressRepository;
  BaseAuth _auth;
  UserType _userType;
  Splashscreen _splashscreen;
  bool _isLoading;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _errorMessage;
  TextEditingController _name = TextEditingController();
  TextEditingController _surname = TextEditingController();
  TextEditingController _school = TextEditingController();
  TextEditingController _city = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _validEmailAddressRepository = ValidEmailAddressRepository.instance;
    _auth = Auth.instance;
    _splashscreen = Splashscreen.instance();
    if (widget._user != null) {
      _validEmailAddressRepository.getUserType(widget._user.email).then((userType) {
        setState(() {
          _userType = userType;
          widget.initialFormState = InitialFormState.USER_TYPE_DETERMINED;
        });
      });
    }
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _validateAndSubmit() async {
    if (_validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });

      try {
        if (widget._user != null) {
          String email = widget._user.email;
          await _validEmailAddressRepository.markAddressAsInitialized(email);
          await _userRepository.setInitializedCurrentUser(widget._user.uid, email, _name.text, _surname.text, _city.text, _school.text);
          widget._initializedCallback();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = Translations.of(context).text("error_unknown");
            _formKey.currentState.reset();
            FocusScope.of(context).unfocus();
          });
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

  void _signOut() {
    _splashscreen.currentAppState = AppState.LOGIN;
    widget._logoutCallback();
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
            Container(height: 150, margin: EdgeInsets.all(10), child: Image.asset("assets/img/icon_new.png")),
            InputWithIconWidget(ctrl: _name, hint: Translations.of(context).text("register_firstname"), icon: Icons.person, type: TextInputType.text, error: Translations.of(context).text("error_firstname_empty")),
            InputWithIconWidget(ctrl: _surname, hint: Translations.of(context).text("register_lastname"), icon: Icons.person, type: TextInputType.text, error: Translations.of(context).text("error_lastname_empty")),
            InputWithIconWidget(ctrl: _city, hint: Translations.of(context).text("register_city"), icon: Icons.location_city, type: TextInputType.text, error: Translations.of(context).text("error_city_empty")),
            InputWithIconWidget(ctrl: _school, hint: Translations.of(context).text("register_school"), icon: Icons.school, type: TextInputType.text, error: Translations.of(context).text("error_school_empty")),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: TextErrorWidget(text: _errorMessage)),
            ),
            ButtonPrimaryWidget(text: Translations.of(context).text("register_create"), submit: _validateAndSubmit),
            ButtonSecondaryWidget(text: Translations.of(context).text("global_back"), submit: _signOut),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.initialFormState) {
      case InitialFormState.USER_TYPE_NOT_DETERMINED:
        return _buildWaitingScreen();
      case InitialFormState.USER_TYPE_DETERMINED:
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: <Widget>[_showForm(), AnimationCircularProgressWidget(status: _isLoading)],
            ),
          ),
        );
      default:
        return _buildWaitingScreen();
    }
  }
}
