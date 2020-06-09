import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:project_teachers/themes/global.dart';
import 'package:project_teachers/translations/translations.dart';

class Calendar extends StatefulWidget {
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
    return Container(
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
            locale: Translations.of(context).text("lang")));
  }
}
