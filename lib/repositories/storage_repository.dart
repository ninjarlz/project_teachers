import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/utils/constants/constants.dart';

class StorageRepository {
  StorageRepository._privateConstructor();

  static StorageRepository _instance;
  Image _userProfileImage;

  Image get userProfileImage => _userProfileImage;

  Image _userBackgroundImage;

  Image get userBackgroundImage => _userBackgroundImage;

  List<UserProfileImageListener> _userProfileImageListeners =
      List<UserProfileImageListener>();

  List<UserProfileImageListener> get userProfileImageListeners =>
      _userProfileImageListeners;

  List<UserBackgroundImageListener> _userBackgroundImageListeners =
      List<UserBackgroundImageListener>();

  List<UserBackgroundImageListener> get userBackgroundImageListeners =>
      _userBackgroundImageListeners;


  Image _coachProfileImage;

  Image get coachProfileImage => _coachProfileImage;

  Image _coachBackgroundImage;

  Image get coachBackgroundImage => _coachBackgroundImage;

  List<CoachProfileImageListener> _coachProfileImageListeners =
  List<CoachProfileImageListener>();

  List<CoachProfileImageListener> get coachProfileImageListeners =>
      _coachProfileImageListeners;

  List<CoachBackgroundImageListener> _coachBackgroundImageListeners =
  List<CoachBackgroundImageListener>();

  List<CoachBackgroundImageListener> get coachBackgroundImageListeners =>
      _coachBackgroundImageListeners;

  static StorageRepository get instance {
    if (_instance == null) {
      _instance = StorageRepository._privateConstructor();
      _instance._storage = FirebaseStorage(
          app: FirebaseApp.instance, storageBucket: Constants.STORAGE_BUCKET);
      _instance._userRepository = UserRepository.instance;
    }
    return _instance;
  }

  FirebaseStorage _storage;
  UserRepository _userRepository;

  Future<void> uploadProfileImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String fileName = basename(image.path);
      UserEntity user = _userRepository.currentUser;
      StorageReference userRef = _storage.ref().child(user.uid);
      if (user.profileImageName != null) {
        await userRef
            .child(Constants.PROFILE_IMAGE_DIR)
            .child(user.profileImageName)
            .delete();
      }
      StorageReference ref =
          userRef.child(Constants.PROFILE_IMAGE_DIR).child(fileName);
      StorageUploadTask uploadTask = ref.putFile(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      user.profileImageName = fileName;
      await _userRepository.updateUser(user);
      _userProfileImage = await Image.file(
        image,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
      );
      _userProfileImageListeners.forEach((element) {
        element.onUserProfileImageChange();
      });
    }
  }

  Future<void> uploadBackgroundImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String fileName = basename(image.path);
      UserEntity user = _userRepository.currentUser;
      StorageReference userRef = _storage.ref().child(user.uid);
      if (user.backgroundImageName != null) {
        await userRef
            .child(Constants.BACKGROUND_IMAGE_DIR)
            .child(user.backgroundImageName)
            .delete();
      }
      StorageReference ref =
          userRef.child(Constants.BACKGROUND_IMAGE_DIR).child(fileName);
      StorageUploadTask uploadTask = ref.putFile(image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      user.backgroundImageName = fileName;
      await _userRepository.updateUser(user);
      _userBackgroundImage = await Image.file(image,
          fit: BoxFit.cover, alignment: Alignment.bottomCenter);
      _userBackgroundImageListeners.forEach((element) {
        element.onUserBackgroundImageChange();
      });
    }
  }

  Future<void> getUserProfileImage() async {
    UserEntity user = _userRepository.currentUser;
    if (user.profileImageName != null) {
      var url = await _storage
          .ref()
          .child(user.uid)
          .child(Constants.PROFILE_IMAGE_DIR)
          .child(user.profileImageName)
          .getDownloadURL();
      _userProfileImage = await Image.network(url,
          fit: BoxFit.cover, alignment: Alignment.bottomCenter);
      _userProfileImageListeners.forEach((element) {
        element.onUserProfileImageChange();
      });
    }
  }

  Future<void> getUserBackgroundImage() async {
    UserEntity user = _userRepository.currentUser;
    if (user.backgroundImageName != null) {
      var url = await _storage
          .ref()
          .child(user.uid)
          .child(Constants.BACKGROUND_IMAGE_DIR)
          .child(user.backgroundImageName)
          .getDownloadURL();
      _userBackgroundImage = await Image.network(url,
          fit: BoxFit.cover, alignment: Alignment.bottomCenter);
      _userBackgroundImageListeners.forEach((element) {
        element.onUserBackgroundImageChange();
      });
    }
  }

  void logoutUser() {
    _userProfileImage = null;
    _userBackgroundImage = null;
    _userProfileImageListeners.clear();
    _userBackgroundImageListeners.clear();
  }


  Future<void> getCoachProfileImage(UserEntity user) async {
    if (user.profileImageName != null) {
      var url = await _storage
          .ref()
          .child(user.uid)
          .child(Constants.PROFILE_IMAGE_DIR)
          .child(user.profileImageName)
          .getDownloadURL();
      _coachProfileImage = await Image.network(url,
          fit: BoxFit.cover, alignment: Alignment.bottomCenter);
      _coachProfileImageListeners.forEach((element) {
        element.onCoachProfileImageChange();
      });
    }
  }

  Future<void> getCoachBackgroundImage(UserEntity user) async {
    if (user.backgroundImageName != null) {
      var url = await _storage
          .ref()
          .child(user.uid)
          .child(Constants.BACKGROUND_IMAGE_DIR)
          .child(user.backgroundImageName)
          .getDownloadURL();
      _coachBackgroundImage = await Image.network(url,
          fit: BoxFit.cover, alignment: Alignment.bottomCenter);
      _coachBackgroundImageListeners.forEach((element) {
        element.onCoachBackgroundImageChange();
      });
    }
  }

  void disposeCoachImages() {
    _coachBackgroundImageListeners.clear();
    _coachProfileImageListeners.clear();
    _coachProfileImage = null;
    _coachBackgroundImage = null;
  }


}

abstract class UserProfileImageListener {
  void onUserProfileImageChange();
}

abstract class UserBackgroundImageListener {
  void onUserBackgroundImageChange();
}

abstract class CoachProfileImageListener {
  void onCoachProfileImageChange();
}

abstract class CoachBackgroundImageListener {
  void onCoachBackgroundImageChange();
}
