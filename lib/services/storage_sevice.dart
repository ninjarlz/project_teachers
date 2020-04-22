import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/repositories/storage_repository.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/utils/constants/constants.dart';

class StorageService {
  StorageService._privateConstructor();

  static StorageService _instance;

  static StorageService get instance {
    if (_instance == null) {
      _instance = new StorageService._privateConstructor();
      _instance._storageRepository = StorageRepository.instance;
      _instance._userService = UserService.instance;
    }
    return _instance;
  }

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

  StorageRepository _storageRepository;
  UserService _userService;

  Future<void> uploadProfileImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String fileName = basename(image.path);
      UserEntity user = _userService.currentUser;
      if (user.profileImageName != null) {
        await _storageRepository.deleteUserProfileImage(user);
      }
      await _storageRepository.uploadImage(
          image, fileName, Constants.PROFILE_IMAGE_DIR, user.uid);
      user.profileImageName = fileName;
      await _userService.updateUser(user);
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
      UserEntity user = _userService.currentUser;
      if (user.backgroundImageName != null) {
        await _storageRepository.deleteUserBackgroundImage(user);
      }
      await _storageRepository.uploadImage(
          image, fileName, Constants.BACKGROUND_IMAGE_DIR, user.uid);
      user.backgroundImageName = fileName;
      await _userService.updateUser(user);
      _userBackgroundImage = await Image.file(image,
          fit: BoxFit.cover, alignment: Alignment.bottomCenter);
      _userBackgroundImageListeners.forEach((element) {
        element.onUserBackgroundImageChange();
      });
    }
  }

  Future<void> getUserProfileImage() async {
    UserEntity user = _userService.currentUser;
    if (user.profileImageName != null) {
      _userProfileImage = await _storageRepository.getProfileImageFromUrl(user);
      _userProfileImageListeners.forEach((element) {
        element.onUserProfileImageChange();
      });
    }
  }

  Future<void> getUserBackgroundImage() async {
    UserEntity user = _userService.currentUser;
    if (user.backgroundImageName != null) {
      _userBackgroundImage =
          await _storageRepository.getBackgroundImageFromUrl(user);
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
      _coachProfileImage =
          await _storageRepository.getProfileImageFromUrl(user);
      _coachProfileImageListeners.forEach((element) {
        element.onCoachProfileImageChange();
      });
    }
  }

  Future<void> getCoachBackgroundImage(UserEntity user) async {
    if (user.backgroundImageName != null) {
      _coachBackgroundImage =
          await _storageRepository.getBackgroundImageFromUrl(user);
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
