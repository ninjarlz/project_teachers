import 'dart:io';
import 'dart:ui';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/repositories/storage/storage_repository.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
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
      _instance._timelineService = TimelineService.instance;
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

  Map<String, Tuple2<String, Image>> _userImages = Map<String,
      Tuple2<String, Image>>(); // <coachId, Tuple2<profileImageName, Image>>
  Map<String, Tuple2<String, Image>> get userImages => _userImages;

  List<CoachProfileImageListener> _coachProfileImageListeners =
      List<CoachProfileImageListener>();

  List<CoachProfileImageListener> get coachProfileImageListeners =>
      _coachProfileImageListeners;

  List<CoachBackgroundImageListener> _coachBackgroundImageListeners =
      List<CoachBackgroundImageListener>();

  List<CoachBackgroundImageListener> get coachBackgroundImageListeners =>
      _coachBackgroundImageListeners;

  List<UserListProfileImagesListener> _userListProfileImageListeners =
      List<UserListProfileImagesListener>();

  List<UserListProfileImagesListener> get userListProfileImageListeners =>
      _userListProfileImageListeners;
  StorageRepository _storageRepository;
  UserService _userService;
  MessagingService _messagingService;
  TimelineService _timelineService;


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
        await _timelineService.updateProfileImageData(user.uid, fileName);
        _userProfileImage = await Image.file(
          croppedImage,
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        );
        _userImages[user.uid] =
            Tuple2<String, Image>(user.profileImageName, _userProfileImage);
        _userProfileImageListeners.forEach((element) {
          element.onUserProfileImageChange();
        });
      }
    }
  }

  Future<void> updateUserListProfileImages(List<UserEntity> users) async {
    List<String> updatedUsersIds = List<String>();
    for (UserEntity user in users) {
      if (user.profileImageName != null) {
        if (_userImages.containsKey(user.uid)) {
          if (user.profileImageName != userImages[user.uid].item1) {
            await updateUserProfileImage(user);
            updatedUsersIds.add(user.uid);
          }
        } else {
          await updateUserProfileImage(user);
          updatedUsersIds.add(user.uid);
        }
      }
    }
    _userListProfileImageListeners.forEach((element) {
      element.onUserListProfileImagesChange(updatedUsersIds);
    });
  }

  Future<void> updateUserListProfileImagesWithConversationList(
      List<ConversationEntity> conversations) async {
    List<String> updatedUsersIds = List<String>();
    for (ConversationEntity conversation in conversations) {
      if (conversation.otherParticipantData.profileImageName != null) {
        if (_userImages.containsKey(conversation.otherParticipantId)) {
          if (conversation.otherParticipantData.profileImageName !=
              userImages[conversation.otherParticipantId].item1) {
            await updateUserProfileImageWithConversation(conversation);
            updatedUsersIds.add(conversation.otherParticipantId);
          }
        } else {
          await updateUserProfileImageWithConversation(conversation);
          updatedUsersIds.add(conversation.otherParticipantId);
        }
      }
    }
    _userListProfileImageListeners.forEach((element) {
      element.onUserListProfileImagesChange(updatedUsersIds);
    });
  }

  Future<void> updateUserListProfileImagesWithQuestions(
      List<QuestionEntity> questions) async {
    List<String> updatedUsersIds = List<String>();
    for (QuestionEntity question in questions) {
      if (question.authorData.profileImageName != null) {
        if (_userImages.containsKey(question.authorId)) {
          if (question.authorData.profileImageName !=
              userImages[question.authorId].item1) {
            await updateUserProfileImageWithQuestion(question);
            updatedUsersIds.add(question.authorId);
          }
        } else {
          await updateUserProfileImageWithQuestion(question);
          updatedUsersIds.add(question.authorId);
        }
      }
    }
    _userListProfileImageListeners.forEach((element) {
      element.onUserListProfileImagesChange(updatedUsersIds);
    });
  }

  Future<void> updateUserProfileImageWithConversation(
      ConversationEntity conversation) async {
    Image image = await _storageRepository.getProfileImageFromData(
        conversation.otherParticipantId,
        conversation.otherParticipantData.profileImageName);
    _userImages[conversation.otherParticipantId] =
        Tuple2(conversation.otherParticipantData.profileImageName, image);
  }

  Future<void> updateUserProfileImageWithQuestion(
      QuestionEntity question) async {
    Image image = await _storageRepository.getProfileImageFromData(
        question.authorId, question.authorData.profileImageName);
    _userImages[question.authorId] =
        Tuple2(question.authorData.profileImageName, image);
  }

  Future<void> updateUserProfileImage(UserEntity user) async {
    Image image = await _storageRepository.getProfileImageFromUser(user);
    _userImages[user.uid] = Tuple2(user.profileImageName, image);
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
      if (_userImages.containsKey(user.uid)) {
        if (user.profileImageName != userImages[user.uid].item1) {
          await updateUserProfileImage(user);
        }
      } else {
        await updateUserProfileImage(user);
      }
      _userProfileImage = _userImages[user.uid].item2;
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
      if (_userImages.containsKey(coach.uid)) {
        if (coach.profileImageName != userImages[coach.uid].item1) {
          await updateUserProfileImage(coach);
          _selectedCoachProfileImage = _userImages[coach.uid];
          _coachProfileImageListeners.forEach((element) {
            element.onCoachProfileImageChange();
          });
        }
      } else {
        await updateUserProfileImage(coach);
        _selectedCoachProfileImage = _userImages[coach.uid];
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

abstract class UserListProfileImagesListener {
  void onUserListProfileImagesChange(List<String> updatedUsersIds);
}
