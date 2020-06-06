import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/users/user_entity.dart';

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

  StreamSubscription<QuerySnapshot> _userListSub;
  StreamSubscription<DocumentSnapshot> _selectedUserSub;
  StreamSubscription<DocumentSnapshot> _userSub;
  DocumentReference _selectedUserRef;
  CollectionReference _userListRef;
  CollectionReference get userListRef => _userListRef;
  DocumentReference _userRef;
  Firestore _database;

  void cancelUserSubscription() {
    if (_userSub != null) {
      _userSub.cancel();
      _userSub = null;
    }
  }

  void cancelUserListSubscription() {
    if (_userListSub != null) {
      _userListSub.cancel();
      _userListSub = null;
    }
  }

  void cancelSelectedUserSubscription() {
    if (_selectedUserSub != null) {
      _selectedUserSub.cancel();
      _selectedUserSub = null;
    }
  }

  void subscribeUserList(Query query, Function onUserListChange) {
    cancelUserListSubscription();
    _userListSub = query.snapshots().listen(onUserListChange);
    _userListSub.onError((o) {
      print(DB_ERROR_MSG + o.message);
    });
  }

  void subscribeSelectedUser(String uid, Function onSelectedUserDataChange) {
    cancelSelectedUserSubscription();
    _selectedUserRef = _userListRef.document(uid);
    _selectedUserSub = _selectedUserRef.snapshots().listen(onSelectedUserDataChange);
    _selectedUserSub.onError((error) {
      print(DB_ERROR_MSG + error.message);
    });
  }

  void subscribeCurrentUser(String userId, Function onUserDataChange) {
//    FOR ADDING TEST DATA
//    for (int i = 0; i < 300; i++) {
//      _userListRef.document("test test" + (i+ 20).toString()).setData(CoachEntity("test test" + (i+ 20).toString(), "test", "test" + (i + 20).toString(), "test" + (i + 20).toString() + "@test.com", "test", "test","test", "test", "test", null, null, null, null, CoachType.PRO_ACTIVE, 2, 2).toJson());
//    }

// FOR REMOVING TEST DATA
//    for (int i = 0; i < 300; i++) {
//      _userListRef.document("test test" + (i+ 20).toString()).delete();
//    }

    _userRef = _userListRef.document(userId);
    _userSub = _userRef.snapshots().listen(onUserDataChange);
    _userSub.onError((error) {
      print(DB_ERROR_MSG + error.message);
    });
  }

  Future<void> transactionUpdateUser(
      UserEntity user, Transaction transaction) async {
    await transaction.set(_userListRef.document(user.uid), user.toJson());
  }

  Future<void> updateUser(UserEntity user) async {
    await _userListRef.document(user.uid).setData(user.toJson());
  }

  Future<void> transactionAddLikedPost(UserEntity userEntity,
      String likedPostId, Transaction transaction) async {
    List<String> likedPosts = userEntity.likedPosts != null
        ? List<String>.from(userEntity.likedPosts)
        : List<String>();
    likedPosts.add(likedPostId);
    transaction.update(
        _userListRef.document(userEntity.uid), {"likedPosts": likedPosts});
  }

  Future<void> transactionRemoveLikedPost(UserEntity userEntity,
      String likedPostId, Transaction transaction) async {
    List<String> likedPosts = userEntity.likedPosts != null
        ? List<String>.from(userEntity.likedPosts)
        : List<String>();
    likedPosts.remove(likedPostId);
    transaction.update(
        _userListRef.document(userEntity.uid), {"likedPosts": likedPosts});
  }

  Future<bool> transactionCheckIfPostIsLiked(
      UserEntity userEntity, String postId, Transaction transaction) async {
    DocumentSnapshot documentSnapshot =
        await transaction.get(_userListRef.document(userEntity.uid));
    await transaction.update(_userListRef.document(userEntity.uid), {});
    if (documentSnapshot.data["likedPosts"] == null) {
      return false;
    }
    List<String> likedPosts =
        List<String>.from(documentSnapshot.data["likedPosts"]);
    return likedPosts.contains(postId);
  }
}
