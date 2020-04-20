import 'package:flutter/material.dart';
import 'package:project_teachers/repositories/storage_repository.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/index.dart';

abstract class BaseProfileState<T extends StatefulWidget> extends State<T> {
  @protected
  UserRepository userRepository;
  @protected
  StorageRepository storageRepository;
  @protected
  String userName = "";
  @protected
  String profilePicture = "";
  @protected
  String backgroundPicture = "";
  @protected
  List<String> competencies = List<String>();
  @protected
  String profession = "";
  @protected
  String bio = "";
  @protected
  String city = "";
  @protected
  String school = "";
  @protected
  Image profileImage;
  @protected
  Image backgroundImage;

  @override
  void initState() {
    super.initState();
    userRepository = UserRepository.instance;
    storageRepository = StorageRepository.instance;
    backgroundImage = Image.asset(
      "assets/img/default_background.jpg",
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
    profileImage = Image.asset(
      "assets/img/default_profile.png",
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        child: backgroundImage);
  }

  Widget _buildProfileImage() {
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

  Widget _buildProfileBio() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child:
          Text(bio, style: ThemeGlobalText().text, textAlign: TextAlign.center),
    );
  }

  Widget _buildProfileCompetencyRow(int rowIndex) {
    List<Widget> _rowElements = List<Widget>();
    for (int i = 0; i < 3 && (3 * rowIndex + i) < competencies.length; i++) {
      _rowElements.add(PillProfileWidget(text: competencies[3 * rowIndex + i]));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center, children: _rowElements);
  }

  Widget _buildProfileCompetencies() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        itemCount: (competencies.length / 3).ceil(),
        itemBuilder: (context, index) {
          return _buildProfileCompetencyRow(index);
        });
  }

  Widget _buildProfile() {
    return Column(
      children: <Widget>[
        SizedBox(height: MediaQuery.of(context).size.height / 3),
        _buildProfileImage(),
        Text(userName, style: ThemeGlobalText().titleText),
        SizedBox(height: 5),
        Text(city, style: ThemeGlobalText().smallText),
        SizedBox(height: 5),
        Text(profession, style: ThemeGlobalText().text),
        SizedBox(height: 5),
        Text(school, style: ThemeGlobalText().text),
        SizedBox(height: 10),
        _buildProfileCompetencies(),
        SizedBox(height: 10),
        _buildProfileBio(),
        SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          _buildBackgroundImage(),
          _buildProfile(),
        ],
      ),
    );
  }
}
