import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';

class Contact extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  DateTime _currentDate;

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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                children: [
                  Text("Michał Kuśmidrowicz", style: ThemeGlobalText().text),
                  Text("Fabien Diaz", style: ThemeGlobalText().text),
                ],
                crossAxisAlignment: CrossAxisAlignment.stretch,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: Text(Translations.of(context).text("design"),
                  style: ThemeGlobalText().titleText),
            ),
            Padding(
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
            ),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(Translations.of(context).text("problems"),
                    style: ThemeGlobalText().text, textAlign: TextAlign.center))
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ],
    ));
  }
}
