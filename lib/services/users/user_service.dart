import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/expert_entity.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/repositories/users/user_repository.dart';
import 'package:project_teachers/services/authentication/auth.dart';
import 'package:project_teachers/services/filtering/coach_filtering_serivce.dart';
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
      _instance._coachFilteringService = CoachFilteringService.instance;
      _instance._questionFilteringService = QuestionFilteringService.instance;
      _instance._messagingService = MessagingService.instance;
      _instance._timelineService = TimelineService.instance;
      _instance._auth = Auth.instance;
      _instance._storageService = StorageService.instance;
      _instance._transactionManager = TransactionManager.instance;
    }
    return _instance;
  }

  List<CoachListListener> _coachListListeners = List<CoachListListener>();

  List<CoachListListener> get coachListListeners => _coachListListeners;

  List<CoachListener> _coachListeners = List<CoachListener>();

  List<CoachListener> get coachListeners => _coachListeners;

  CoachEntity _selectedCoach;

  CoachEntity get selectedCoach => _selectedCoach;

  bool _hasMoreCoaches = true;

  bool get hasMoreCoaches => _hasMoreCoaches;
  int _coachesLimit = 20;
  int _coachesOffset = 0;

  List<CoachEntity> _coachList;

  List<CoachEntity> get coachList => _coachList;

  List<UserListener> _userListeners = List<UserListener>();

  List<UserListener> get userListeners => _userListeners;

  UserEntity _currentUser;

  UserEntity get currentUser => _currentUser;

  ExpertEntity _currentExpert;

  ExpertEntity get currentExpert => _currentExpert;

  CoachEntity _currentCoach;

  CoachEntity get currentCoach => _currentCoach;

  UserRepository _userRepository;
  CoachFilteringService _coachFilteringService;
  QuestionFilteringService _questionFilteringService;
  MessagingService _messagingService;
  TimelineService _timelineService;
  BaseAuth _auth;
  StorageService _storageService;
  TransactionManager _transactionManager;

  Future<void> loginUser() async {
    updateCoachList();
    await _storageService.getUserProfileImage();
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
    _coachListListeners.clear();
    _coachListeners.clear();
    _coachFilteringService.resetFilters();
    _questionFilteringService.resetFilters();
    resetCoachList();
    _storageService.logoutUser();
    _messagingService.logoutUser();
    _timelineService.logoutUser();
  }

  void _onCoachListChange(QuerySnapshot event) {
    _coachList = List<CoachEntity>();
    if (event.documents.length < _coachesOffset) {
      _hasMoreCoaches = false;
    } else {
      _hasMoreCoaches = true;
    }
    event.documents.forEach((element) {
      CoachEntity coach = CoachEntity.fromJson(element.data);
      if (coach.uid != _auth.currentUser.uid) {
        _coachList.add(coach);
      }
    });
    _storageService.updateUserListProfileImages(_coachList);
    for (CoachListListener coachListListener in _coachListListeners) {
      coachListListener.onCoachListChange();
    }
  }

  Future<void> updateCoachList() async {
    _coachesOffset += _coachesLimit;
    Query query = _userRepository.coachesQuery();
    query = _coachFilteringService.prepareQuery(query).limit(_coachesOffset);
    _userRepository.subscribeCoachList(query, _onCoachListChange);
  }

  Future<void> resetCoachList() async {
    _coachesOffset = 0;
    if (_coachList != null) {
      _coachList.clear();
    }
    _hasMoreCoaches = true;
    _userRepository.cancelCoachListSubscription();
  }

  void _onCoachDataChange(DocumentSnapshot event, int cnt) {
    if (!event.exists) {
      _selectedCoach = null;
      return;
    }
    if (cnt == 1) {
      _storageService.updateCoachBackgroundImage(_selectedCoach);
      return;
    }
    _selectedCoach = CoachEntity.fromJson(event.data);
    _storageService.updateSelectedCoachProfileImage(_selectedCoach);
    _storageService.updateCoachBackgroundImage(_selectedCoach);

    _coachListeners.forEach((coachListener) {
      coachListener.onCoachDataChange();
    });
  }

  void setSelectedCoach(CoachEntity coach, Tuple2<String, Image> profileImage) {
    if (coach == null) {
      _selectedCoach = null;
      return;
    }
    _selectedCoach = coach;
    _storageService.selectedCoachProfileImage = profileImage;
    Function onCoachDataChangeWithCounter =
        FunctionWrappers.createDocumentSnapshotFunctionWithCounter(
            _onCoachDataChange, 0);
    _userRepository.subscribeSelectedCoach(
        coach.uid, onCoachDataChangeWithCounter);
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
        _currentCoach = CoachEntity.fromJson(event.data);
        _currentUser = _currentExpert = _currentCoach;
        break;
      case UserType.EXPERT:
        _currentExpert = ExpertEntity.fromJson(event.data);
        _currentUser = _currentExpert;
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

  Future<CoachEntity> getCoach(String coachId) async {
    return _userRepository.getCoach(coachId);
  }

  Future<List<CoachEntity>> getCoaches(List<String> coachIds) async {
    return await _userRepository.getCoaches(coachIds);
  }

  void cancelSelectedCoachSubscription() {
    _userRepository.cancelSelectedCoachSubscription();
  }
}

abstract class UserListener {
  void onUserDataChange();
}

abstract class CoachListListener {
  void onCoachListChange();
}

abstract class CoachListener {
  void onCoachDataChange();
}
