import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';

class Contact extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactState();
}

class _ContactState extends State<Contact> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        Image.asset("assets/img/logo.jpeg"),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(Translations.of(context).text("app_description"),
                    style: ThemeGlobalText().text,
                    textAlign: TextAlign.center)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Text(Translations.of(context).text("development"),
                  style: ThemeGlobalText().titleText),
            ),
            _buildDevelopersSection(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Text(Translations.of(context).text("design"),
                  style: ThemeGlobalText().titleText),
            ),
            _buildDesignersSection(),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(Translations.of(context).text("problems"),
                    style: ThemeGlobalText().text, textAlign: TextAlign.center))
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ],
    ));
  }

  Widget _buildDesignersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          Text("Renske van den Broek", style: ThemeGlobalText().text),
          Text("Minyeong Hong", style: ThemeGlobalText().text),
          Text("Jana Smirnova", style: ThemeGlobalText().text),
          Text("Youngmin Park", style: ThemeGlobalText().text),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  Widget _buildDevelopersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: [
          Text("Michał Kuśmidrowicz", style: ThemeGlobalText().text),
          Text("Fabien Diaz", style: ThemeGlobalText().text),
        ],
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

}
