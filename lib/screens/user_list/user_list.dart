import 'package:flutter/material.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/services/filtering/user_filtering_serivce.dart';
import 'package:project_teachers/services/managers/app_state_manager.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/widgets/index.dart';
import 'package:provider/provider.dart';

class UserList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _UserListState();
}

class _UserListState extends State<UserList>
    implements UserListListener, UserListProfileImagesListener {
  UserService _userService;
  UserFilteringService _filteringService;
  StorageService _storageService;
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  AppStateManager _appStateManager;
  TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userService = UserService.instance;
    _storageService = StorageService.instance;
    _filteringService = UserFilteringService.instance;
    if (_filteringService.searchFilter != null) {
      _searchCtrl.text = _filteringService.searchFilter;
    }
    _userService.userListListeners.add(this);
    _storageService.userListProfileImageListeners.add(this);
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        _loadMoreUsers();
      }
    });
    Future.delayed(Duration.zero, () {
      _appStateManager = Provider.of<AppStateManager>(context, listen: false);
    });
  }

  void _searchFilter() {
    _filteringService.resetFilters();
    if (_searchCtrl.text != "" && _searchCtrl.text != null) {
      _filteringService.searchFilter = _searchCtrl.text.toLowerCase();
    }
    _userService.resetUserList();
    _userService.updateUserList();
  }

  Widget _buildRow(int index) {
    UserEntity user = _userService.userList[index];
    String fullName = "${user.name} ${user.surname}";
    return ListTile(
        leading: Material(
          child: _storageService.userImages.containsKey(user.uid)
              ? _storageService.userImages[user.uid].item2
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
          user.profession,
          style: ThemeGlobalText().smallText,
        ),
        onTap: () {
          _userService.setSelectedUser(
              user,
              _storageService.userImages.containsKey(user.uid)
                  ? _storageService.userImages[user.uid]
                  : null);
          _appStateManager.changeAppState(AppState.SELECTED_USER_PROFILE_PAGE);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 20, top: 10, right: 20),
      child: Column(
        children: [
          InputSearchWidget(
            ctrl: _searchCtrl,
            submitChange: _searchFilter,
          ),
          Expanded(
            child: _userService.userList == null ||
                    _userService.userList.length == 0
                ? Center(
                    child: Text(
                        Translations.of(context).text("no_results") + "..."),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _userService.userList.length,
                    itemBuilder: (context, index) {
                      return _buildRow(index);
                    },
                  ),
          ),
          _isLoading
              ? Text(
                  Translations.of(context).text("loading") + "...",
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

  Future<void> _loadMoreUsers() async {
    if (!_userService.hasMoreUsers || _isLoading) {
      return;
    }
    _userService.updateUserList();
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userService.userListListeners.remove(this);
    _storageService.userListProfileImageListeners.remove(this);
  }

  @override
  void onUserListChange() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void onUserListProfileImagesChange(List<String> updatedUsersIds) {
    List<String> userIds = _userService.userList.map((e) => e.uid).toList();
    String id = userIds.firstWhere(
        (element) => updatedUsersIds.contains(element),
        orElse: () => null);
    if (id != null) {
      setState(() {});
    }
  }
}
