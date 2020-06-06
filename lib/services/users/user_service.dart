import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/expert_entity.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/repositories/users/user_repository.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/filtering/user_filtering_serivce.dart';
import 'package:project_teachers/services/filtering/question_filtering_service.dart';
import 'package:project_teachers/services/messaging/messaging_service.dart';
import 'package:project_teachers/services/storage/storage_service.dart';
import 'package:project_teachers/services/timeline/timeline_service.dart';
import 'package:project_teachers/services/managers/transaction_manager.dart';
import 'package:project_teachers/utils/helpers/function_wrappers.dart';
import 'package:tuple/tuple.dart';

class UserService {
  UserService._privateConstructor();

  static UserService _instance;

  static UserService get instance {
    if (_instance == null) {
      _instance = UserService._privateConstructor();
      _instance._userRepository = UserRepository.instance;
      _instance._userFilteringService = UserFilteringService.instance;
      _instance._questionFilteringService = QuestionFilteringService.instance;
      _instance._messagingService = MessagingService.instance;
      _instance._timelineService = TimelineService.instance;
      _instance._auth = Auth.instance;
      _instance._storageService = StorageService.instance;
      _instance._transactionManager = TransactionManager.instance;
    }
    return _instance;
  }

  List<UserListListener> _userListListeners = List<UserListListener>();

  List<UserListListener> get userListListeners => _userListListeners;

  List<SelectedUserListener> _selectedUserListeners =
      List<SelectedUserListener>();

  List<SelectedUserListener> get selectedUserListeners =>
      _selectedUserListeners;

  UserEntity _selectedUser;

  UserEntity get selectedUser => _selectedUser;

  CoachEntity _selectedCoach;

  CoachEntity get selectedCoach => _selectedCoach;

  ExpertEntity _selectedExpert;

  ExpertEntity get selectedExpert => _selectedExpert;

  bool _hasMoreUsers = true;

  bool get hasMoreUsers => _hasMoreUsers;
  int _usersLimit = 20;
  int _usersOffset = 0;

  List<UserEntity> _userList;

  List<UserEntity> get userList => _userList;

  List<UserListener> _userListeners = List<UserListener>();

  List<UserListener> get userListeners => _userListeners;

  UserEntity _currentUser;

  UserEntity get currentUser => _currentUser;

  ExpertEntity _currentExpert;

  ExpertEntity get currentExpert => _currentExpert;

  CoachEntity _currentCoach;

  CoachEntity get currentCoach => _currentCoach;

  UserRepository _userRepository;
  UserFilteringService _userFilteringService;
  QuestionFilteringService _questionFilteringService;
  MessagingService _messagingService;
  TimelineService _timelineService;
  BaseAuth _auth;
  StorageService _storageService;
  TransactionManager _transactionManager;

  Future<void> loginUser() async {
    updateUserList();
    _storageService.getUserProfileImage();
    _storageService.getUserBackgroundImage();
    _messagingService.loginUser();
    _timelineService.loginUser();
  }

  void logoutUser() {
    _currentUser = null;
    _currentCoach = null;
    _currentExpert = null;
    _userRepository.cancelUserSubscription();
    _userListeners.clear();
    _userListListeners.clear();
    _selectedUserListeners.clear();
    _userFilteringService.resetFilters();
    _questionFilteringService.resetFilters();
    resetUserList();
    _storageService.logoutUser();
    _messagingService.logoutUser();
    _timelineService.logoutUser();
  }

  void _onUserListChange(QuerySnapshot event) {
    _userList = List<UserEntity>();
    if (event.documents.length < _usersOffset) {
      _hasMoreUsers = false;
    } else {
      _hasMoreUsers = true;
    }
    event.documents.forEach((element) {
      UserType userType = UserTypeExtension.getValue(element.data["userType"]);
      switch (userType) {
        case UserType.COACH:
          CoachEntity coach = CoachEntity.fromJson(element.data);
          if (coach.uid != _auth.currentUser.uid) {
            _userList.add(coach);
          }
          break;
        default:
          ExpertEntity expert = ExpertEntity.fromJson(element.data);
          if (expert.uid != _auth.currentUser.uid) {
            _userList.add(expert);
          }
          break;
      }
    });
    _storageService.updateUserListProfileImages(_userList);
    for (UserListListener userListListener in _userListListeners) {
      userListListener.onUserListChange();
    }
  }

  Future<void> updateUserList() async {
    _usersOffset += _usersLimit;
    Query query = _userRepository.userListRef..limit(_usersOffset);
    query = _userFilteringService.prepareQuery(query);
    _userRepository.subscribeUserList(query, _onUserListChange);
  }

  Future<void> resetUserList() async {
    _usersOffset = 0;
    if (_userList != null) {
      _userList.clear();
    }
    _hasMoreUsers = true;
    _userRepository.cancelUserListSubscription();
  }

  void _onSelectedUserDataChange(DocumentSnapshot event, int cnt) {
    if (!event.exists) {
      _selectedCoach = null;
      _selectedUser = null;
      _selectedExpert = null;
      return;
    }
    if (cnt == 1) {
      _storageService.updateSelectedUserBackgroundImage(_selectedCoach);
      return;
    }
    UserType userType = UserTypeExtension.getValue(event.data["userType"]);
    switch (userType) {
      case UserType.COACH:
        _selectedUser =
            _selectedExpert = _selectedCoach = CoachEntity.fromJson(event.data);
        break;
      default:
        _selectedUser = _selectedExpert = ExpertEntity.fromJson(event.data);
        _selectedCoach = null;
        break;
    }
    _storageService.updateSelectedUserProfileImage(_selectedUser);
    _storageService.updateSelectedUserBackgroundImage(_selectedUser);
    _selectedUserListeners.forEach((selectedUserListener) {
      selectedUserListener.onUserDataChange();
    });
  }

  void setSelectedUser(UserEntity user, Tuple2<String, Image> profileImage) {
    if (user == null) {
      _selectedUser = null;
      _selectedExpert = null;
      _selectedCoach = null;
      return;
    }
    switch (user.userType) {
      case UserType.COACH:
        _selectedUser = _selectedExpert = _selectedCoach = user;
        break;
      default:
        _selectedUser = _selectedExpert = user;
        _selectedCoach = null;
        break;
    }
    _storageService.selectedUserProfileImage = profileImage;
    Function onSelectedUserDataChangeWithCounter =
        FunctionWrappers.createDocumentSnapshotFunctionWithCounter(
            _onSelectedUserDataChange, 0);
    _userRepository.subscribeSelectedUser(
        user.uid, onSelectedUserDataChangeWithCounter);
  }

  Future<void> setInitializedCurrentExpert(
      String userId,
      String email,
      String name,
      String surname,
      String city,
      String school,
      String schoolID,
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations) async {
    ExpertEntity expertEntity = ExpertEntity(
        userId,
        name,
        surname,
        email,
        city,
        school,
        schoolID,
        profession,
        bio,
        null,
        null,
        List<String>(),
        schoolSubjects,
        specializations);
    await _userRepository.updateUser(expertEntity);
    setCurrentUser(userId);
  }

  Future<void> setInitializedCurrentCoach(
      String userId,
      String email,
      String name,
      String surname,
      String city,
      String school,
      String schoolID,
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations,
      CoachType coachType,
      int maxAvailabilityPerWeek) async {
    CoachEntity coachEntity = CoachEntity(
        userId,
        name,
        surname,
        email,
        city,
        school,
        schoolID,
        profession,
        bio,
        null,
        null,
        List<String>(),
        schoolSubjects,
        specializations,
        coachType,
        maxAvailabilityPerWeek,
        maxAvailabilityPerWeek);
    await _userRepository.updateUser(coachEntity);
    setCurrentUser(userId);
  }

  void _onUserDataChange(DocumentSnapshot event, int cnt) {
    UserType userType = UserTypeExtension.getValue(event.data["userType"]);
    switch (userType) {
      case UserType.COACH:
        _currentUser =
            _currentExpert = _currentCoach = CoachEntity.fromJson(event.data);
        break;
      case UserType.EXPERT:
        _currentUser = _currentExpert = ExpertEntity.fromJson(event.data);
        _currentCoach = null;
        break;
    }
    if (cnt == 1) {
      loginUser();
    }
    _userListeners.forEach((userListener) {
      userListener.onUserDataChange();
    });
  }

  void setCurrentUser(String userId) {
    _userRepository.cancelUserSubscription();
    Function onUserDataChangeWithCounter =
        FunctionWrappers.createDocumentSnapshotFunctionWithCounter(
            _onUserDataChange, 0);
    _userRepository.subscribeCurrentUser(userId, onUserDataChangeWithCounter);
  }

  Future<bool> transactionCheckIfPostIsLiked(
      String postId, Transaction transaction) async {
    return await _userRepository.transactionCheckIfPostIsLiked(
        _currentUser, postId, transaction);
  }

  Future<void> updateCurrentCoachData(
      String name,
      String surname,
      String city,
      String school,
      String schoolID,
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations,
      CoachType coachType,
      int maxAvailabilityPerWeek,
      int remainingAvailabilityPerWeek) async {
    String profileImageName = _currentUser.profileImageName;
    String backgroundImageName = _currentUser.backgroundImageName;
    if (schoolID == null) {
      schoolID = _currentUser.schoolID;
    }
    CoachEntity coach = CoachEntity(
        _currentUser.uid,
        name,
        surname,
        _currentUser.email,
        city,
        school,
        schoolID,
        profession,
        bio,
        profileImageName,
        backgroundImageName,
        _currentUser.likedPosts,
        schoolSubjects,
        specializations,
        coachType,
        maxAvailabilityPerWeek,
        remainingAvailabilityPerWeek);
    await _transactionManager
        .runTransaction(await (Transaction transaction) async {
      await transactionUpdateUser(coach, transaction);
      await _messagingService.transactionUpdateUserData(
          _currentUser.uid, name, surname, transaction);
      await _timelineService.transactionUpdateUserData(
          _currentUser.uid, name, surname, transaction);
    });
  }

  Future<void> transactionAddLikedPost(
      String likedPostId, Transaction transaction) async {
    await _userRepository.transactionAddLikedPost(
        _currentUser, likedPostId, transaction);
  }

  Future<void> transactionRemoveLikedPost(
      String likedPostId, Transaction transaction) async {
    await _userRepository.transactionRemoveLikedPost(
        _currentUser, likedPostId, transaction);
  }

  Future<void> updateCurrentExpertData(
      String name,
      String surname,
      String city,
      String school,
      String schoolID,
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations) async {
    String profileImageName = _currentUser.profileImageName;
    String backgroundImageName = _currentUser.backgroundImageName;
    if (schoolID == null) {
      schoolID = _currentUser.schoolID;
    }
    ExpertEntity expert = ExpertEntity(
        _currentUser.uid,
        name,
        surname,
        _currentUser.email,
        city,
        school,
        schoolID,
        profession,
        bio,
        profileImageName,
        backgroundImageName,
        _currentUser.likedPosts,
        schoolSubjects,
        specializations);
    await _transactionManager
        .runTransaction(await (Transaction transaction) async {
      await transactionUpdateUser(expert, transaction);
      await _messagingService.transactionUpdateUserData(
          _currentUser.uid, name, surname, transaction);
      await _timelineService.transactionUpdateUserData(
          _currentUser.uid, name, surname, transaction);
    });
  }

  Future<void> transactionUpdateUser(
      UserEntity userEntity, Transaction transaction) async {
    await _userRepository.transactionUpdateUser(userEntity, transaction);
  }

  void updateUser(UserEntity userEntity) async {
    await _userRepository.updateUser(userEntity);
  }

  void cancelSelectedUserSubscription() {
    _userRepository.cancelSelectedUserSubscription();
  }
}

abstract class UserListener {
  void onUserDataChange();
}

abstract class UserListListener {
  void onUserListChange();
}

abstract class SelectedUserListener {
  void onUserDataChange();
}
