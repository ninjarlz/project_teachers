import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/utils/constants/constants.dart';

class StorageRepository {
  StorageRepository._privateConstructor();

  static StorageRepository _instance;

  static StorageRepository get instance {
    if (_instance == null) {
      _instance = StorageRepository._privateConstructor();
      _instance._storage = FirebaseStorage(
          app: FirebaseApp.instance, storageBucket: Constants.STORAGE_BUCKET);
      _instance._storageReference = _instance._storage.ref();
    }
    return _instance;
  }

  FirebaseStorage _storage;
  StorageReference _storageReference;

  StorageReference get storageReference => _storageReference;


  Future<void> uploadImage(File image, String fileName, String dir,
      String uid) async {
    StorageReference ref =
    _storageReference.child(uid).child(dir).child(
        fileName);
    StorageUploadTask uploadTask = ref.putFile(image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  }

  Future<Image> getProfileImageFromUser(UserEntity user) async {
    var url = await _storage
        .ref()
        .child(user.uid)
        .child(Constants.PROFILE_IMAGE_DIR)
        .child(user.profileImageName)
        .getDownloadURL();
    return await Image.network(url,
        fit: BoxFit.cover, alignment: Alignment.bottomCenter);
  }

  Future<Image> getProfileImageFromData(String uid, String profileImageName) async {
    var url = await _storage
        .ref()
        .child(uid)
        .child(Constants.PROFILE_IMAGE_DIR)
        .child(profileImageName)
        .getDownloadURL();
    return await Image.network(url,
        fit: BoxFit.cover, alignment: Alignment.bottomCenter);
  }

  Future<Image> getBackgroundImageFromUser(UserEntity user) async {
    var url = await _storage
        .ref()
        .child(user.uid)
        .child(Constants.BACKGROUND_IMAGE_DIR)
        .child(user.backgroundImageName)
        .getDownloadURL();
    return await Image.network(url,
        fit: BoxFit.cover, alignment: Alignment.bottomCenter);
  }

  Future<void> deleteUserProfileImage(UserEntity userEntity) async {
    await _storageReference
        .child(userEntity.uid)
        .child(Constants.PROFILE_IMAGE_DIR)
        .child(userEntity.profileImageName)
        .delete();
  }

  Future<void> deleteUserBackgroundImage(UserEntity userEntity) async {
    await _storageReference
        .child(userEntity.uid)
        .child(Constants.BACKGROUND_IMAGE_DIR)
        .child(userEntity.backgroundImageName)
        .delete();
  }

}
