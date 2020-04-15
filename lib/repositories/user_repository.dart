import 'dart:async';
import 'package:project_teachers/entities/coach_entity.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized/synchronized.dart';

class UserRepository {
  UserRepository._privateConstructor();

  static const String DB_ERROR_MSG = "An error with database occured: ";

  static UserRepository _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._validEmailAddressRepository =
          ValidEmailAddressRepository.instance;
      _instance._userListRef = _instance._database.collection("Users");
    }
    return _instance;
  }

  List<CoachPageListener> _coachPageListeners = List<CoachPageListener>();

  List<CoachPageListener> get coachPageListeners => _coachPageListeners;
  List<CoachListener> _coachListeners = List<CoachListener>();

  List<CoachListener> get coachListeners => _coachListeners;
  StreamSubscription<QuerySnapshot> _coachListSub;
  StreamSubscription<DocumentSnapshot> _coachSub;
  DocumentReference _coachRef;
  UserEntity _currentCoach;

  UserEntity get currentCoach => _currentCoach;
  bool _hasMoreCoaches = true;
  Lock _coachesLock = new Lock();

  bool get hasMoreCoaches => _hasMoreCoaches;
  int _coachesLimit = 10;
  int _coachesOffset = 0;
  List<UserEntity> _coachList;

  List<UserEntity> get coachList => _coachList;

  List<UserListener> _userListeners = List<UserListener>();

  List<UserListener> get userListeners => _userListeners;
  StreamSubscription<DocumentSnapshot> _userSub;
  UserEntity _currentUser;
  UserType _currentUserType;

  UserType get currentUserType => _currentUserType;

  UserEntity get currentUser => _currentUser;
  CollectionReference _userListRef;
  DocumentReference _userRef;
  Firestore _database;
  ValidEmailAddressRepository _validEmailAddressRepository;

  void initRestrictedData() {
    updateCoachList();
  }

  void logoutUser() {
    _currentUser = null;
    if (_userSub != null) {
      _userSub.cancel();
    }
    _userListeners.clear();
    _coachList.clear();
  }

  Function _createFunctionCounter(
      void function(QuerySnapshot event, int cnt), int invokeBeforeExecution) {
    int count = 0;
    return (args) {
      count++;
      if (count <= invokeBeforeExecution) {
        return;
      } else {
        return function(args, count);
      }
    };
  }

  void _onCoachesChange(QuerySnapshot event, int cnt) {
    int size = _coachList != null ? _coachList.length : 0;
    _coachList = List<UserEntity>();
    if (cnt == 1) {
      _coachesOffset += _coachesLimit;
      if (event.documents.length < _coachesOffset) {
        _hasMoreCoaches = false;
      }
    }
    event.documents.forEach((element) {
      UserEntity coach = UserEntity.fromJson(element.data);
      coach.uid = element.documentID;
      _coachList.add(coach);
      for (CoachPageListener coachPageListener in _coachPageListeners) {
        coachPageListener.onCoachListChange();
      }
    });
  }

  Future<void> updateCoachList() async {
    if (_coachListSub != null) {
      _coachListSub.cancel();
    }

    Function onCoachesChangeWithCounter =
        _createFunctionCounter(_onCoachesChange, 0);
    print("k");
    _coachListSub = _userListRef
        .where("userType", isEqualTo: "Coach")
        .orderBy("surname")
        .limit(_coachesOffset + _coachesLimit)
        .snapshots()
        .listen(onCoachesChangeWithCounter, onError: (o) {
      {
        print(DB_ERROR_MSG + o.message);
      }
    });
  }

  Future<void> resetCoachList() async {
    _coachesOffset = 0;
    _hasMoreCoaches = true;
    updateCoachList();
  }

  void setCurrentCoach(UserEntity coach) {
    if (_coachSub != null) {
      _coachSub.cancel();
    }
    if (coach == null) {
      _currentCoach = null;
      return;
    }
    _currentCoach = coach;
    _coachRef = _userListRef.document(coach.uid);
    _coachSub = _coachRef.snapshots().listen((event) {
      if (!event.exists) {
        _currentCoach = null;
      } else {
        _currentCoach = UserEntity.fromJson(event.data);
      }
      _coachListeners.forEach((coachListener) {
        coachListener.onCoachDataChange();
      });
    }, onError: (o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  Future<void> setInitializedCurrentUser(
      String userId,
      String email,
      String name,
      String surname,
      String city,
      String school,
      String profession) async {
    UserType userType = await _validEmailAddressRepository.getUserType(email);
    await _userListRef.document(userId).setData(
        UserEntity(name, surname, email, city, school, profession, userType)
            .toJson());
    setCurrentUser(userId);
  }

  void setCurrentUser(String userId) {
    if (_userSub != null) {
      _userSub.cancel();
    }

//FOR ADDING TEST DATA
//    for (int i = 0; i < 300; i++) {
//      _userListRef.add(UserEntity("test", "test" + (i + 20).toString(), "test" + (i + 20).toString() + "@test.com", "test", "test", "test", UserType.COACH).toJson());
//    }

// FOR REMOVING TEST DATA
//
//    _userListRef
//        .where("name", isEqualTo: "test")
//        .getDocuments()
//        .then((querySnapshot) => {
//              querySnapshot.documents.forEach((element) {
//                _userListRef.document(element.documentID).delete();
//              })
//            });

    _userRef = _userListRef.document(userId);
    _userSub = _userRef.snapshots().listen((event) {
      _currentUser = UserEntity.fromJson(event.data);
      _currentUser.uid = event.documentID;
      _userListeners.forEach((userListener) {
        userListener.onUserDataChange();
      });
    }, onError: (o) {
      print(DB_ERROR_MSG + o.message);
    });
  }
}

abstract class UserListener {
  void onUserDataChange();
}

abstract class CoachPageListener {
  void onCoachListChange();
}

abstract class CoachListener {
  void onCoachDataChange();
}
