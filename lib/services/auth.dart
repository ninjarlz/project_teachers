import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {

  FirebaseUser get currentUser;

  Future<FirebaseUser> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();

  Future<void> deleteUser();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;

  @override
  FirebaseUser get currentUser => _currentUser;

  Auth._privateConstructor();
  static Auth _instance;
  static Auth get instance {
    if (_instance == null) {
      _instance = Auth._privateConstructor();
    }
    return _instance;
  }

  Future<FirebaseUser> signIn(String email, String password) async {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      _currentUser = result.user;
      return _currentUser;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<void> signOut() async {
    _currentUser = null;
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<void> deleteUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    await user.delete();
  }
}