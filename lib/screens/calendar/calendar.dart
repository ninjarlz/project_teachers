import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';

class Calendar extends StatefulWidget {
  static SpeedDial buildCalendarFloatingActionButtons(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: true,
      curve: Curves.bounceIn,
      backgroundColor: ThemeGlobalColor().secondaryColor,
      children: [
        SpeedDialChild(
          child: Icon(Icons.delete_forever, color: Colors.white),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          label: Translations.of(context).text("cancel_consultation_hours"),
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        ),
        SpeedDialChild(
          child: Icon(Icons.add_circle_outline, color: Colors.white),
          backgroundColor: ThemeGlobalColor().secondaryColor,
          label: Translations.of(context).text("book_consultation_hours"),
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: ThemeGlobalColor().secondaryColor,
        )
      ],
    );
  }

  @override
  State<StatefulWidget> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _currentDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: SingleChildScrollView(
            child: CalendarCarousel(
      onDayPressed: (DateTime datetime, List<EventInterface> events) {
        setState(() {
          _currentDate = datetime;
        });
      },
      iconColor: ThemeGlobalColor().mainColor,
      daysTextStyle: ThemeGlobalText().text,
      inactiveDaysTextStyle: ThemeGlobalText().inactiveDayText,
      weekdayTextStyle: ThemeGlobalText().boldSmallText,
      prevDaysTextStyle: ThemeGlobalText().inactiveDayText,
      nextDaysTextStyle: ThemeGlobalText().inactiveDayText,
      weekendTextStyle: ThemeGlobalText().weekendDayText,
      selectedDateTime: _currentDate,
      todayButtonColor: ThemeGlobalColor().mainColor,
      selectedDayButtonColor: ThemeGlobalColor().secondaryColor,
      headerTextStyle: ThemeGlobalText().titleText,
      locale: Translations.of(context).text("lang"),
      height: 400,
    )));
  }
}
