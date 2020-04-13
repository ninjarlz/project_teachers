import 'package:flutter/material.dart';
import 'package:project_teachers/model/app_state_manager.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:provider/provider.dart';


class Coach extends StatefulWidget {
  static const String TITLE = "Coach";

  @override
  State<StatefulWidget> createState() => _CoachState();
}

class _CoachState extends State<Coach> implements CoachPageListener {

  UserRepository _userRepository;
  ScrollController _scrollController = ScrollController();
  bool _isLoading;
  AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _userRepository = UserRepository.instance;
    _userRepository.coachPageListeners.add(this);
    onCoachListChange();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreCoaches();
      }
    });
    Future.delayed(Duration.zero,() {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: _userRepository.coachList.length == 0
            ? Center(
          child: Text('No Data...'),
        )
            : ListView.builder(
          controller: _scrollController,
          itemCount: _userRepository.coachList.length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.all(5),
              title: Text(_userRepository.coachList[index].name + " " + _userRepository.coachList[index].surname),
              subtitle: Text(_userRepository.coachList[index].profession),
              onTap: (){
                _userRepository.setCurrentCoach(_userRepository.coachList[index]);
                _appStateManager.changeAppState(AppState.COACH_PROFILE_PAGE);
              }
            );
          },
        ),
      ),
      _isLoading
          ? Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(5),
        color: Colors.yellowAccent,
        child: Text(
          'Loading',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : Container()
    ]);
  }

  Future<void> _loadMoreCoaches() async {
    if (!_userRepository.hasMoreCoaches || _isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
      _userRepository.updateCoachList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userRepository.resetCoachList();
    _userRepository.coachPageListeners.remove(this);
  }

  @override
  void onCoachListChange() {
    setState(() {
      _isLoading = false;
    });
  }
}
