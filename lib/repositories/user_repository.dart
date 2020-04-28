import 'dart:async';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  UserRepository._privateConstructor();

  static const String DB_ERROR_MSG = "An error with database occured: ";

  static UserRepository _instance;

  static UserRepository get instance {
    if (_instance == null) {
      _instance = UserRepository._privateConstructor();
      _instance._database = Firestore.instance;
      _instance._userListRef = _instance._database.collection("Users");
    }
    return _instance;
  }

  StreamSubscription<QuerySnapshot> _coachListSub;
  StreamSubscription<DocumentSnapshot> _selectedCoachSub;
  StreamSubscription<DocumentSnapshot> _userSub;
  DocumentReference _coachRef;
  CollectionReference _userListRef;
  DocumentReference _userRef;
  Firestore _database;

  void cancelUserSubscription() {
    if (_userSub != null) {
      _userSub.cancel();
      _userSub = null;
    }
  }

  void cancelCoachListSubscription() {
    if (_coachListSub != null) {
      _coachListSub.cancel();
      _coachListSub = null;
    }
  }

  void cancelSelectedCoachSubscription() {
    if (_selectedCoachSub != null) {
      _selectedCoachSub.cancel();
      _selectedCoachSub = null;
    }
  }

  Query coachesQuery() {
    return _userListRef.where("userType", isEqualTo: "Coach");
  }

  void subscribeCoachList(
      Query query, Function onCoachListChange) {
    cancelCoachListSubscription();
    _coachListSub = query.snapshots().listen(onCoachListChange);
    _coachListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  void subscribeSelectedCoach(String coachId, Function onCoachDataChange) {
    cancelSelectedCoachSubscription();
    _coachRef = _userListRef.document(coachId);
    _selectedCoachSub = _coachRef.snapshots().listen(onCoachDataChange);
    _selectedCoachSub.onError((error) {
      print(DB_ERROR_MSG + error.message);
    });
  }

  void subscribeCurrentUser(String userId, Function onUserDataChange) {
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
    _userSub = _userRef.snapshots().listen(onUserDataChange);
    _userSub.onError((error) {
      print(DB_ERROR_MSG + error.message);
    });
  }

  Future<void> updateUser(UserEntity user) async {
    await _userListRef.document(user.uid).setData(user.toJson());
  }
}
