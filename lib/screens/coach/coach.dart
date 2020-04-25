import 'package:flutter/material.dart';
import 'package:project_teachers/services/app_state_manager.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:provider/provider.dart';

class Coach extends StatefulWidget {
  static const String TITLE = "Coach";

  static FloatingActionButton getFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
        onPressed: () {
          Provider.of<AppStateManager>(context, listen: false).changeAppState(AppState.FILTER_COACH);
        },
        backgroundColor: ThemeGlobalColor().secondaryColor,
        child: Icon(Icons.filter_list));
  }

  @override
  State<StatefulWidget> createState() => _CoachState();
}

class _CoachState extends State<Coach> implements CoachPageListener {
  UserService _userService;
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  AppStateManager _appStateManager;
  TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userService = UserService.instance;
    _userService.coachPageListeners.add(this);
    _userService.updateCoachList();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreCoaches();
      }
    });
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  Widget _buildRow(int index) {
    String fullName = "${_userService.coachList[index].name} ${_userService.coachList[index].surname}";
    if (_searchCtrl.text.length != 0 && !fullName.toLowerCase().contains(_searchCtrl.text.toLowerCase())) return Container();
    return ListTile(
        leading: Material(
          child: _userService.coachList[index].profileImageName != null
              ? Image.asset(                                                  // TODO: Display real profile image
                  "assets/img/default_profile_2.png",
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                )
              : Image.asset(
                  "assets/img/default_profile_2.png",
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
          elevation: 4.0,
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
        ),
        contentPadding: EdgeInsets.all(5),
        title: Text(fullName),
        subtitle: Text(
          _userService.coachList[index].profession,
          style: ThemeGlobalText().smallText,
        ),
        onTap: () {
          _userService.setSelectedCoach(_userService.coachList[index]);
          _appStateManager.changeAppState(AppState.COACH_PROFILE_PAGE);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        children: [
          InputSearchWidget(ctrl: _searchCtrl, submitChange: _loadMoreCoaches,),
          Expanded(
            child: _userService.coachList == null || _userService.coachList.length == 0
                ? Center(
                    child: Text('No Data...'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _userService.coachList.length,
                    itemBuilder: (context, index) {
                      return _buildRow(index);
                    },
                  ),
          ),
          _isLoading
              ? Text(
                  'Loading',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Future<void> _loadMoreCoaches() async {
    if (!_userService.hasMoreCoaches || _isLoading) {
      return;
    }
    _userService.updateCoachList();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userService.resetCoachList();
    _userService.coachPageListeners.remove(this);
  }

  @override
  void onCoachListChange() {
    setState(() {
      _isLoading = false;
    });
  }
}
