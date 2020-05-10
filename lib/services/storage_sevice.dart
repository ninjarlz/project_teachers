import 'dart:io';
import 'dart:ui';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_teachers/entities/coach_entity.dart';
import 'package:project_teachers/entities/conversation_entity.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/repositories/storage_repository.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/services/messaging_service.dart';
import 'package:project_teachers/services/user_service.dart';
import 'package:project_teachers/utils/constants/constants.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
import 'package:tuple/tuple.dart';

class StorageService {
  StorageService._privateConstructor();

  static StorageService _instance;

  static StorageService get instance {
    if (_instance == null) {
      _instance = new StorageService._privateConstructor();
      _instance._storageRepository = StorageRepository.instance;
      _instance._userService = UserService.instance;
      _instance._messagingService = MessagingService.instance;
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

  Tuple2<String, Image> _selectedCoachProfileImage;

  Tuple2<String, Image> get selectedCoachProfileImage =>
      _selectedCoachProfileImage;

  void set selectedCoachProfileImage(Tuple2<String, Image> coachProfileImage) {
    _selectedCoachProfileImage = coachProfileImage;
    if (coachProfileImage != null) {
      _coachProfileImageListeners.forEach((element) {
        element.onCoachProfileImageChange();
      });
    }
  }

  Tuple2<String, Image> _selectedCoachBackgroundImage;

  Tuple2<String, Image> get selectedCoachBackgroundImage =>
      _selectedCoachBackgroundImage;

  Map<String, Tuple2<String, Image>> _coachImages = Map<String,
      Tuple2<String, Image>>(); // <coachId, Tuple2<profileImageName, Image>>
  Map<String, Tuple2<String, Image>> get coachImages => _coachImages;

  List<CoachProfileImageListener> _coachProfileImageListeners =
      List<CoachProfileImageListener>();

  List<CoachProfileImageListener> get coachProfileImageListeners =>
      _coachProfileImageListeners;

  List<CoachBackgroundImageListener> _coachBackgroundImageListeners =
      List<CoachBackgroundImageListener>();

  List<CoachBackgroundImageListener> get coachBackgroundImageListeners =>
      _coachBackgroundImageListeners;

  List<CoachListProfileImagesListener> _coachListProfileImageListeners =
      List<CoachListProfileImagesListener>();

  List<CoachListProfileImagesListener> get coachListProfileImageListeners =>
      _coachListProfileImageListeners;
  StorageRepository _storageRepository;
  UserService _userService;
  MessagingService _messagingService;

  Future<void> uploadProfileImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File croppedImage = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatioPresets: [CropAspectRatioPreset.square]);
      if (croppedImage != null) {
        String fileName = Uuid().generateV4() + basename(croppedImage.path);
        UserEntity user = _userService.currentUser;
        if (user.profileImageName != null) {
          await _storageRepository.deleteUserProfileImage(user);
        }
        await _storageRepository.uploadImage(
            croppedImage, fileName, Constants.PROFILE_IMAGE_DIR, user.uid);
        user.profileImageName = fileName;
        await _userService.updateUser(user);
        await _messagingService.updateProfileImageData(user.uid, fileName);
        _userProfileImage = await Image.file(
          croppedImage,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        );
        _userProfileImageListeners.forEach((element) {
          element.onUserProfileImageChange();
        });
      }
    }
  }

  Future<void> updateCoachListProfileImages(List<CoachEntity> coaches) async {
    for (CoachEntity coach in coaches) {
      if (coach.profileImageName != null) {
        if (_coachImages.containsKey(coach.uid)) {
          if (coach.profileImageName != coachImages[coach.uid].item1) {
            await updateCoachProfileImage(coach);
          }
        } else {
          await updateCoachProfileImage(coach);
        }
      }
    }
    _coachListProfileImageListeners.forEach((element) {
      element.onCoachListProfileImagesChange();
    });
  }

  Future<void> updateCoachListProfileImagesWithConversationList(
      List<ConversationEntity> conversations) async {
    for (ConversationEntity conversation in conversations) {
      if (conversation.otherParticipantData.profileImageName != null) {
        if (_coachImages.containsKey(conversation.otherParticipantId)) {
          if (conversation.otherParticipantData.profileImageName !=
              coachImages[conversation.otherParticipantId].item1) {
            updateCoachProfileImageWithConversation(conversation);
          }
        } else {
          updateCoachProfileImageWithConversation(conversation);
        }
      }
    }
    _coachListProfileImageListeners.forEach((element) {
      element.onCoachListProfileImagesChange();
    });
  }

  Future<void> updateCoachProfileImageWithConversation(
      ConversationEntity conversation) async {
    Image image = await _storageRepository.getProfileImageFromData(
        conversation.otherParticipantId,
        conversation.otherParticipantData.profileImageName);
    _coachImages[conversation.otherParticipantId] =
        Tuple2(conversation.otherParticipantData.profileImageName, image);
  }

  Future<void> updateCoachProfileImage(CoachEntity coach) async {
    Image image = await _storageRepository.getProfileImageFromUser(coach);
    _coachImages[coach.uid] = Tuple2(coach.profileImageName, image);
  }

  Future<void> uploadBackgroundImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String fileName = Uuid().generateV4() + basename(image.path);
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
      _userProfileImage =
          await _storageRepository.getProfileImageFromUser(user);
      _userProfileImageListeners.forEach((element) {
        element.onUserProfileImageChange();
      });
    }
  }

  Future<void> getUserBackgroundImage() async {
    UserEntity user = _userService.currentUser;
    if (user.backgroundImageName != null) {
      _userBackgroundImage =
          await _storageRepository.getBackgroundImageFromUser(user);
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

  Future<void> updateSelectedCoachProfileImage(CoachEntity coach) async {
    if (coach.profileImageName != null) {
      if (_coachImages.containsKey(coach.uid)) {
        if (coach.profileImageName != coachImages[coach.uid].item1) {
          await updateCoachProfileImage(coach);
          _selectedCoachProfileImage = _coachImages[coach.uid];
          _coachProfileImageListeners.forEach((element) {
            element.onCoachProfileImageChange();
          });
        }
      } else {
        await updateCoachProfileImage(coach);
        _selectedCoachProfileImage = _coachImages[coach.uid];
        _coachProfileImageListeners.forEach((element) {
          element.onCoachProfileImageChange();
        });
      }
    }
  }

  Future<void> updateCoachBackgroundImage(CoachEntity coach) async {
    if (coach.backgroundImageName != null) {
      if (_selectedCoachBackgroundImage == null ||
          (_selectedCoachBackgroundImage != null &&
              _selectedCoachBackgroundImage.item1 !=
                  coach.backgroundImageName)) {
        Image image =
            await _storageRepository.getBackgroundImageFromUser(coach);
        _selectedCoachBackgroundImage =
            Tuple2(coach.backgroundImageName, image);
        _coachBackgroundImageListeners.forEach((element) {
          element.onCoachBackgroundImageChange();
        });
      }
    }
  }

  void disposeCoachImages() {
    _coachBackgroundImageListeners.clear();
    _coachProfileImageListeners.clear();
    _selectedCoachProfileImage = null;
    _selectedCoachBackgroundImage = null;
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

abstract class CoachListProfileImagesListener {
  void onCoachListProfileImagesChange();
}
