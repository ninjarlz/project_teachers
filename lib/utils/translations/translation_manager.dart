import 'package:flutter/material.dart';
import 'package:project_teachers/translations/application.dart';
import 'package:project_teachers/utils/index.dart';

class TranslationManagerWidget extends StatelessWidget {

  void _changeLang(String lang) {
    applic.onLocaleChanged(new Locale(lang, ''));
    AuthenticationSave().saveString("lang", lang);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        MaterialButton(
          minWidth: 20,
          onPressed: () => _changeLang('en'),
          padding: EdgeInsets.all(0),
          child: Image.asset(
            "assets/img/lang/lang_en.png",
            scale: 2.5,
          ),
        ),
        MaterialButton(
          minWidth: 20,
          onPressed: () => _changeLang('nl'),
          padding: EdgeInsets.all(0),
          child: Image.asset(
            "assets/img/lang/lang_nl.png",
            scale: 2.5,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
      ],
    );
  }
}