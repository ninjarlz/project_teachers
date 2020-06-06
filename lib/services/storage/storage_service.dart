import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_teachers/entities/messaging/conversation_entity.dart';
import 'package:project_teachers/entities/timeline/answer_entity.dart';
import 'package:project_teachers/entities/timeline/question_entity.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/repositories/storage/storage_repository.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/managers/transaction_manager.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/services/users/user_service.dart';
import 'package:project_teachers/utils/constants/constants.dart';
import 'package:project_teachers/utils/helpers/uuid.dart';
import 'package:synchronized_lite/synchronized_lite.dart';
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
      _instance._transactionManager = TransactionManager.instance;
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

  Tuple2<String, Image> _selectedUserProfileImage;

  Tuple2<String, Image> get selectedUserProfileImage =>
      _selectedUserProfileImage;

  void set selectedUserProfileImage(Tuple2<String, Image> userProfileImage) {
    _selectedUserProfileImage = userProfileImage;
    if (userProfileImage != null) {
      _selectedUserProfileImageListeners.forEach((element) {
        element.onSelectedUserProfileImageChange();
      });
    }
  }

  Tuple2<String, Image> _selectedUserBackgroundImage;

  Tuple2<String, Image> get selectedUserBackgroundImage =>
      _selectedUserBackgroundImage;

  Map<String, Tuple2<String, Image>> _userImages = Map<String,
      Tuple2<String, Image>>(); // <userId, Tuple2<profileImageName, Image>>
  Map<String, Tuple2<String, Image>> get userImages => _userImages;

  Map<String, List<Tuple2<String, Image>>> _answerImages = Map<
      String,
      List<
          Tuple2<String,
              Image>>>(); // <questionId, List<Tuple2<photoName, Image>>>

  Map<String, List<Tuple2<String, Image>>> get answerImages =>
      _answerImages;

  Map<String, List<Tuple2<String, Image>>> _questionImages = Map<
      String,
      List<
          Tuple2<String,
              Image>>>(); // <questionId, List<Tuple2<photoName, Image>>>

  Map<String, List<Tuple2<String, Image>>> get questionImages =>
      _questionImages;

  List<SelectedUserProfileImageListener> _selectedUserProfileImageListeners =
      List<SelectedUserProfileImageListener>();

  List<SelectedUserProfileImageListener> get selectedUserProfileImageListeners =>
      _selectedUserProfileImageListeners;

  List<SelectedUserBackgroundImageListener> _selectedUserBackgroundImageListeners =
      List<SelectedUserBackgroundImageListener>();

  List<SelectedUserBackgroundImageListener> get selectedUserBackgroundImageListeners =>
      _selectedUserBackgroundImageListeners;

  List<UserListProfileImagesListener> _userListProfileImageListeners =
      List<UserListProfileImagesListener>();

  List<QuestionsListImagesListener> _questionsListImagesListener =
      List<QuestionsListImagesListener>();

  List<QuestionsListImagesListener> get questionsListImagesListener =>
      _questionsListImagesListener;

  List<AnswersListImagesListener> _answersListImagesListener =
  List<AnswersListImagesListener>();

  List<AnswersListImagesListener> get answersListImagesListener =>
      _answersListImagesListener;

  List<UserListProfileImagesListener> get userListProfileImageListeners =>
      _userListProfileImageListeners;

  Lock _questionListImagesLock = Lock();
  Lock _answerListImagesLock = Lock();
  Lock _userProfileImagesListLock = Lock();

  StorageRepository _storageRepository;
  UserService _userService;
  MessagingService _messagingService;
  TimelineService _timelineService;
  TransactionManager _transactionManager;

  Future<void> uploadProfileImage() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 900,
        imageQuality: 80);
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
        await _storageRepository.uploadUserImage(
            croppedImage, fileName, Constants.PROFILE_IMAGE_DIR, user.uid);
        user.profileImageName = fileName;
        await _transactionManager
            .runTransaction(await (Transaction transaction) async {
          await _userService.transactionUpdateUser(user, transaction);
          await _messagingService.transactionUpdateProfileImageData(
              user.uid, fileName, transaction);
          await _timelineService.transactionUpdateProfileImageData(
              user.uid, fileName, transaction);
        });
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
    await _userProfileImagesListLock.synchronized(await () async {
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
    });
  }

  Future<void> updateUserListProfileImagesWithConversationList(
      List<ConversationEntity> conversations) async {
    await _userProfileImagesListLock.synchronized(await () async {
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
    });
  }

  Future<void> updateUserListProfileImagesWithQuestions(
      List<QuestionEntity> questions) async {
    await _userProfileImagesListLock.synchronized(await () async {
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
    });
  }

  Future<void> updateUserListProfileImagesWithAnswers(
      List<AnswerEntity> answers) async {
    await _userProfileImagesListLock.synchronized(await () async {
      List<String> updatedUsersIds = List<String>();
      for (AnswerEntity answer in answers) {
        if (answer.authorData.profileImageName != null) {
          if (_userImages.containsKey(answer.authorId)) {
            if (answer.authorData.profileImageName !=
                userImages[answer.authorId].item1) {
              await updateUserProfileImageWithAnswer(answer);
              updatedUsersIds.add(answer.authorId);
            }
          } else {
            await updateUserProfileImageWithAnswer(answer);
            updatedUsersIds.add(answer.authorId);
          }
        }
      }
      _userListProfileImageListeners.forEach((element) {
        element.onUserListProfileImagesChange(updatedUsersIds);
      });
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

  Future<void> updateUserProfileImageWithAnswer(
      AnswerEntity answer) async {
    Image image = await _storageRepository.getProfileImageFromData(
        answer.authorId, answer.authorData.profileImageName);
    _userImages[answer.authorId] =
        Tuple2(answer.authorData.profileImageName, image);
  }

  Future<void> updateUserProfileImage(UserEntity user) async {
    Image image = await _storageRepository.getProfileImageFromUser(user);
    _userImages[user.uid] = Tuple2(user.profileImageName, image);
  }

  Future<void> uploadBackgroundImage() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90);
    if (image != null) {
      String fileName = Uuid().generateV4() + basename(image.path);
      UserEntity user = _userService.currentUser;
      if (user.backgroundImageName != null) {
        await _storageRepository.deleteUserBackgroundImage(user);
      }
      await _storageRepository.uploadUserImage(
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

  Future<void> updateQuestionListImages(List<QuestionEntity> questions) async {
    await _questionListImagesLock.synchronized(await () async {
      List<String> updatedQuestions = List<String>();
      for (QuestionEntity question in questions) {
        if (question.photoNames != null) {
          if (_questionImages.containsKey(question.id)) {
            List<String> oldImagesNames = List<String>();
            for (Tuple2<String, Image> image in _questionImages[question.id]) {
              if (!question.photoNames.contains(image.item1)) {
                _questionImages[question.id].remove(image);
              } else {
                oldImagesNames.add(image.item1);
              }
            }
            for (String imageName in question.photoNames) {
              if (!oldImagesNames.contains(imageName)) {
                if (!updatedQuestions.contains(question.id)) {
                  updatedQuestions.add(question.id);
                }
                Image image = await _storageRepository.getQuestionImage(
                    question.id, imageName);
                _questionImages[question.id]
                    .add(Tuple2<String, Image>(imageName, image));
              }
            }
          } else {
            _questionImages[question.id] = List<Tuple2<String, Image>>();
            for (String imageName in question.photoNames) {
              if (!updatedQuestions.contains(question.id)) {
                updatedQuestions.add(question.id);
              }
              Image image = await _storageRepository.getQuestionImage(
                  question.id, imageName);
              _questionImages[question.id]
                  .add(Tuple2<String, Image>(imageName, image));
            }
          }
        }
      }
      _questionsListImagesListener.forEach((element) {
        element.onQuestionListImagesChange(updatedQuestions);
      });
    });
  }

  Future<void> uploadQuestionImages(List<Image> images, List<File> files,
      List<String> fileNames, String questionId) async {
    await _questionListImagesLock.synchronized(await () async {
      List<String> updatedQuestions = [questionId];
      for (int i = 0; i < images.length; i++) {
        await uploadQuestionImage(
            images[i], files[i], fileNames[i], questionId);
      }
      _questionsListImagesListener.forEach((element) {
        element.onQuestionListImagesChange(updatedQuestions);
      });
    });
  }

  Future<void> uploadQuestionImage(
      Image image, File file, String fileName, String questionId) async {
    if (!_questionImages.containsKey(questionId)) {
      _questionImages[questionId] = List<Tuple2<String, Image>>();
    }
    _questionImages[questionId].add(Tuple2<String, Image>(fileName, image));
    await _storageRepository.uploadQuestionImage(file, fileName, questionId);
  }


  Future<void> uploadAnswerImages(List<Image> images, List<File> files,
      List<String> fileNames, String answerId) async {
    await _answerListImagesLock.synchronized(await () async {
      List<String> updatedAnswers = [answerId];
      for (int i = 0; i < images.length; i++) {
        await uploadAnswerImage(
            images[i], files[i], fileNames[i], answerId);
      }
      _answersListImagesListener.forEach((element) {
        element.onAnswerListImagesChange(updatedAnswers);
      });
    });
  }

  Future<void> uploadAnswerImage(
      Image image, File file, String fileName, String answerId) async {
    if (!_answerImages.containsKey(answerId)) {
      _answerImages[answerId] = List<Tuple2<String, Image>>();
    }
    _answerImages[answerId].add(Tuple2<String, Image>(fileName, image));
    await _storageRepository.uploadAnswerImage(file, fileName, answerId);
  }

  Future<void> updateAnswerListImages(List<AnswerEntity> answers) async {
    await _answerListImagesLock.synchronized(await () async {
      List<String> updatedAnswers = List<String>();
      for (AnswerEntity answer in answers) {
        if (answer.photoNames != null) {
          if (_answerImages.containsKey(answer.id)) {
            List<String> oldImagesNames = List<String>();
            for (Tuple2<String, Image> image in _answerImages[answer.id]) {
              if (!answer.photoNames.contains(image.item1)) {
                _answerImages[answer.id].remove(image);
              } else {
                oldImagesNames.add(image.item1);
              }
            }
            for (String imageName in answer.photoNames) {
              if (!oldImagesNames.contains(imageName)) {
                if (!updatedAnswers.contains(answer.id)) {
                  updatedAnswers.add(answer.id);
                }
                Image image = await _storageRepository.getAnswerImage(
                    answer.id, imageName);
                _answerImages[answer.id]
                    .add(Tuple2<String, Image>(imageName, image));
              }
            }
          } else {
            _answerImages[answer.id] = List<Tuple2<String, Image>>();
            for (String imageName in answer.photoNames) {
              if (!updatedAnswers.contains(answer.id)) {
                updatedAnswers.add(answer.id);
              }
              Image image = await _storageRepository.getAnswerImage(
                  answer.id, imageName);
              _answerImages[answer.id]
                  .add(Tuple2<String, Image>(imageName, image));
            }
          }
        }
      }
      _answersListImagesListener.forEach((element) {
        element.onAnswerListImagesChange(updatedAnswers);
      });
    });
  }

  Future<void> getUserProfileImage() async {
    await _userProfileImagesListLock.synchronized(await () async {
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
    });
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

  Future<void> updateSelectedUserProfileImage(UserEntity user) async {
    await _userProfileImagesListLock.synchronized(await () async {
      if (user.profileImageName != null) {
        if (_userImages.containsKey(user.uid)) {
          if (user.profileImageName != userImages[user.uid].item1) {
            await updateUserProfileImage(user);
            _selectedUserProfileImage = _userImages[user.uid];
            _selectedUserProfileImageListeners.forEach((element) {
              element.onSelectedUserProfileImageChange();
            });
          }
        } else {
          await updateUserProfileImage(user);
          _selectedUserProfileImage = _userImages[user.uid];
          _selectedUserProfileImageListeners.forEach((element) {
            element.onSelectedUserProfileImageChange();
          });
        }
      }
    });
  }

  Future<void> updateSelectedUserBackgroundImage(UserEntity user) async {
    if (user.backgroundImageName != null) {
      if (_selectedUserBackgroundImage == null ||
          (_selectedUserBackgroundImage != null &&
              _selectedUserBackgroundImage.item1 !=
                  user.backgroundImageName)) {
        Image image =
            await _storageRepository.getBackgroundImageFromUser(user);
        _selectedUserBackgroundImage =
            Tuple2(user.backgroundImageName, image);
        _selectedUserBackgroundImageListeners.forEach((element) {
          element.onSelectedUserBackgroundImageChange();
        });
      }
    }
  }

  void disposeSelectedUserImages() {
    _selectedUserBackgroundImageListeners.clear();
    _selectedUserProfileImageListeners.clear();
    _selectedUserProfileImage = null;
    _selectedUserBackgroundImage = null;
  }
}

abstract class UserProfileImageListener {
  void onUserProfileImageChange();
}

abstract class UserBackgroundImageListener {
  void onUserBackgroundImageChange();
}

abstract class SelectedUserProfileImageListener {
  void onSelectedUserProfileImageChange();
}

abstract class SelectedUserBackgroundImageListener {
  void onSelectedUserBackgroundImageChange();
}

abstract class UserListProfileImagesListener {
  void onUserListProfileImagesChange(List<String> updatedUsersIds);
}

abstract class QuestionsListImagesListener {
  void onQuestionListImagesChange(List<String> updatedQuestions);
}

abstract class AnswersListImagesListener {
  void onAnswerListImagesChange(List<String> updatedAnswers);
}
