import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/model/app_state_manager.dart';
import 'package:project_teachers/model/auth_status_manager.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:project_teachers/services/auth.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/button/button_primary.dart';
import 'package:project_teachers/widgets/button/button_secondary.dart';
import 'package:project_teachers/widgets/input/input_with_icon.dart';
import 'package:project_teachers/widgets/text/text_error.dart';
import 'package:provider/provider.dart';

abstract class BaseEditFormState<T extends StatefulWidget> extends State<T> {
  @protected
  UserRepository userRepository;
  @protected
  ValidEmailAddressRepository validEmailAddressRepository;
  @protected
  BaseAuth auth;
  @protected
  UserType userType;
  @protected
  bool isLoading;
  @protected
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @protected
  String errorMessage;
  @protected
  TextEditingController name = TextEditingController();
  @protected
  TextEditingController surname = TextEditingController();
  @protected
  TextEditingController school = TextEditingController();
  @protected
  TextEditingController city = TextEditingController();
  @protected
  TextEditingController profession = TextEditingController();
  @protected
  AuthStatusManager authStatusManager;
  @protected
  AppStateManager appStateManager;
  @protected
  String imagePath;
  @protected
  String submitLabel;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository.instance;
    validEmailAddressRepository = ValidEmailAddressRepository.instance;
    auth = Auth.instance;
    Future.delayed(Duration.zero, () {
      authStatusManager =
          Provider.of<AuthStatusManager>(context, listen: false);
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
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

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
            formKey.currentState.reset();
            FocusScope.of(context).unfocus();
          });
        }
      } catch (e) {
        print("Error: $e");
        setState(() {
          isLoading = false;
          errorMessage = e.message;
          formKey.currentState.reset();
          FocusScope.of(context).unfocus();
        });
      }
    }
  }

  @protected
  Future<void> onSubmit();

  @protected
  void onBack();

  @protected
  Widget showForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      width: MediaQuery.of(context).size.width,
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                height: imagePath != null ? 150 : 0,
                margin: EdgeInsets.all(10),
                child: imagePath != null ? Image.asset(imagePath) : null),
            InputWithIconWidget(
                ctrl: name,
                hint: Translations.of(context).text("register_firstname"),
                icon: Icons.person,
                type: TextInputType.text,
                error: Translations.of(context).text("error_firstname_empty")),
            InputWithIconWidget(
                ctrl: surname,
                hint: Translations.of(context).text("register_lastname"),
                icon: Icons.person,
                type: TextInputType.text,
                error: Translations.of(context).text("error_lastname_empty")),
            InputWithIconWidget(
                ctrl: city,
                hint: Translations.of(context).text("register_city"),
                icon: Icons.location_city,
                type: TextInputType.text,
                error: Translations.of(context).text("error_city_empty")),
            InputWithIconWidget(
                ctrl: school,
                hint: Translations.of(context).text("register_school"),
                icon: Icons.school,
                type: TextInputType.text,
                error: Translations.of(context).text("error_school_empty")),
            InputWithIconWidget(
                ctrl: profession,
                hint: Translations.of(context).text("register_profession"),
                icon: Icons.work,
                type: TextInputType.text,
                error: Translations.of(context).text("error_profession_empty")),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(child: TextErrorWidget(text: errorMessage)),
            ),
            ButtonPrimaryWidget(
                text: Translations.of(context).text(submitLabel),
                submit: validateAndSubmit),
            ButtonSecondaryWidget(
                text: Translations.of(context).text("global_back"),
                submit: onBack),
          ],
        ),
      ),
    );
  }
}
