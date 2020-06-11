import 'package:flutter/material.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/index.dart';

abstract class BaseProfileState<T extends StatefulWidget> extends State<T> {
  @protected
  UserService userService;
  @protected
  StorageService storageService;
  @protected
  String userName = "";
  @protected
  List<Specialization> competencies = List<Specialization>();
  @protected
  List<SchoolSubject> subjects = List<SchoolSubject>();
  @protected
  String profession = "";
  @protected
  String bio = "";
  @protected
  String city = "";
  @protected
  String school = "";
  @protected
  UserType userType;
  @protected
  int maxAvailabilityPerWeek;
  @protected
  int remainingAvailabilityInWeek;
  @protected
  CoachType coachType;
  @protected
  Image profileImage;
  @protected
  Image backgroundImage;

  @override
  void initState() {
    super.initState();
    userService = UserService.instance;
    storageService = StorageService.instance;
    backgroundImage = Image.asset(
      "assets/img/default_background.jpg",
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
    profileImage = Image.asset(
      "assets/img/default_profile_2.png",
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
  }

  @protected
  Widget buildBackgroundImage() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        child: backgroundImage);
  }

  @protected
  Widget buildProfileImage() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.width / 2,
      margin: EdgeInsets.only(bottom: 10),
      child: Material(
        child: profileImage,
        elevation: 4.0,
        shape: CircleBorder(),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  @protected
  Widget buildProfileBio() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(bio != null ? bio : "",
          style: ThemeGlobalText().text, textAlign: TextAlign.center),
    );
  }

  @protected
  Widget buildProfileCompetencyRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 3 && (3 * rowIndex + i) < competencies.length; i++) {
      _rowElements.add(PillProfileWidget(
          text: Translations.of(context)
              .text(competencies[3 * rowIndex + i].label + "_s")));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center, children: _rowElements);
  }

  @protected
  Widget buildProfileCompetencies() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: (competencies.length / 3).ceil(),
        itemBuilder: (context, index) {
          return buildProfileCompetencyRow(index);
        });
  }

  @protected
  Widget buildProfileSubjectRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 3 && (3 * rowIndex + i) < subjects.length; i++) {
      _rowElements.add(PillProfileWidget(
        text: Translations.of(context).text(subjects[3 * rowIndex + i].label),
        color: ThemeGlobalColor().secondaryColor,
      ));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center, children: _rowElements);
  }

  @protected
  Widget buildProfileSubjects() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: (userService.currentExpert.schoolSubjects.length / 3).ceil(),
        itemBuilder: (context, index) {
          return buildProfileSubjectRow(index);
        });
  }

  @protected
  Widget buildProfile();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: SingleChildScrollView(
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          buildBackgroundImage(),
          buildProfile(),
        ],
      ),
    ));
  }
}
