import 'dart:async';
import 'package:project_teachers/entities/user.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {

  UserRepository._privateConstructor();

  static const String DB_ERROR_MSG = "An error with database occured: ";


  static UserRepository _instance;
  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._validEmailAddressRepository = ValidEmailAddressRepository.instance;
      _instance._userListRef =  _instance._database.collection("Users");
      _instance._usersMap = new Map<String, User>();
      _instance._userListSub = _instance._userListRef.snapshots().listen((event) {
        event.documentChanges.forEach((element) {
          DocumentSnapshot documentSnapshot = element.document;
          _instance._usersMap[documentSnapshot.documentID] = User.fromJson(documentSnapshot.data);
        });
        _instance._userListListeners.forEach((userListListener) {
          userListListener.onUsersListChange();
        });
      } , onError: (o) {
        print(DB_ERROR_MSG + o.message);
      });
    }
    return _instance;
  }

  List<UserListListener> _userListListeners = List<UserListListener>();
  List<UserListListener> get userListListeners => _userListListeners;
  List<UserListener> _userListeners = List<UserListener>();
  List<UserListener> get userListeners => _userListeners;
  Map<String, User> _usersMap;
  Map<String, User> get usersMap => _usersMap;
  StreamSubscription<QuerySnapshot> _userListSub;
  StreamSubscription<DocumentSnapshot> _userSub;
  User _currentUser;
  UserType _currentUserType;
  UserType get currentUserType => _currentUserType;
  User get currentUser => _currentUser;
  CollectionReference _userListRef;
  DocumentReference _userRef;
  Firestore _database;
  ValidEmailAddressRepository _validEmailAddressRepository;


  void logoutUser() {
    _currentUser = null;
    if (_userSub != null) {
      _userSub.cancel();
    }
    _userListeners.clear();
  }



  Future<void> setInitializedCurrentUser(String userId, String email, String name, String surname,
      String city, String school) async {
    UserType userType = await _validEmailAddressRepository.getUserType(email);
    await _userListRef.document(userId).setData(User(name, surname, email, city, school, userType).toJson());
    setCurrentUser(userId);
  }

  void setCurrentUser(String userId) {
    if (_userSub != null) {
      _userSub.cancel();
    }
    _userRef = _userListRef.document(userId);
    _userSub = _userRef.snapshots().listen((event) {
      _currentUser = User.fromJson(event.data);
      _userListeners.forEach((userListener) {
        userListener.onUserDataChange();
      });
    }, onError: (o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

}


abstract class UserListener {
  onUserDataChange();
}

abstract class UserListListener {
  onUsersListChange();
}
