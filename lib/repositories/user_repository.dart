import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_teachers/entities/user.dart';

class UserRepository {

  UserRepository._privateConstructor();

  static const String DB_ERROR_MSG = "An error with database occured: ";


  static UserRepository _instance;
  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._privateConstructor();
      _instance._database = FirebaseDatabase.instance;
      _instance._userListRef =  _instance._database.reference().child("Users");
      _instance._userListRef.keepSynced(true);
      _instance._userListSub = _instance._userListRef.onValue.listen((event) {
        _instance._usersMap = event.snapshot.value;
        _instance._userList = List<User>();
        _instance._usersMap.forEach((key, value) {
          _instance._userList.add(User.fromJson(value));
        });
        _instance._userListListeners.forEach((userListListener) {
          userListListener.onUsersListChange(_instance._userList)
          ;});
      }, onError: (Object o) {
        final DatabaseError error = o;
        print(DB_ERROR_MSG + error.message);
      });
    }
    return _instance;
  }

  List<UserListListener> _userListListeners = List<UserListListener>();
  List<UserListListener> get userListListeners => _userListListeners;
  List<UserListener> _userListeners = List<UserListener>();
  List<UserListener> get userListeners => _userListeners;
  Map<dynamic, dynamic> _usersMap;
  List<User> _userList;
  List<User> get userList => _userList;
  User _currentUser;
  User get currentUser => _currentUser;
  DatabaseReference _userListRef;
  StreamSubscription<Event> _userListSub;
  DatabaseReference _userRef;
  StreamSubscription<Event> _userSub;
  FirebaseDatabase _database;


  void logoutUser() {
    _currentUser = null;
    if (_userSub != null) {
      _userSub.cancel();
    }
    _userListeners.clear();
  }

  void setCurrentUser(String userId, String email) {
    if (_usersMap == null || (_usersMap != null && !_usersMap.containsKey(userId))) {
      _userListRef.child(userId).set(User(null, email).toJson());
    }

    if (_userSub != null) {
      _userSub.cancel();
    }

    _userRef = _userListRef.child(userId);
    _userRef.keepSynced(true);
    _userSub = _userRef.onValue.listen((event) {
      _currentUser = User.fromSnapshot(event.snapshot);
      _userListeners.forEach((userListener) {
        userListener.onUserDataChange();
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      print(DB_ERROR_MSG + error.message);
    });
  }

}


abstract class UserListener {
  onUserDataChange();
}

abstract class UserListListener {
  onUsersListChange(List<User> users);
}
