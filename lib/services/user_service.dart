import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/coach_entity.dart';
import 'package:project_teachers/entities/expert_entity.dart';
import 'package:project_teachers/entities/user_entity.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/repositories/user_repository.dart';
import 'package:project_teachers/services/auth.dart';
import 'package:project_teachers/services/filtering_serivce.dart';
import 'package:project_teachers/services/storage_sevice.dart';
import 'package:project_teachers/utils/helpers/function_wrappers.dart';

class UserService {
  UserService._privateConstructor();

  static UserService _instance;

  static UserService get instance {
    if (_instance == null) {
      _instance = UserService._privateConstructor();
      _instance._userRepository = UserRepository.instance;
      _instance._filteringService = FilteringService.instance;
      _instance._auth = Auth.instance;
      _instance._storageService = StorageService.instance;
    }
    return _instance;
  }

  List<CoachPageListener> _coachPageListeners = List<CoachPageListener>();

  List<CoachPageListener> get coachPageListeners => _coachPageListeners;

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
  FilteringService _filteringService;
  BaseAuth _auth;
  StorageService _storageService;

  void logoutUser() {
    _currentUser = null;
    _currentCoach = null;
    _currentExpert = null;
    _userRepository.cancelUserSubscription();
    _userListeners.clear();
    _filteringService.resetFilters();
    resetCoachList();
    _storageService.logoutUser();
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
      coach.uid = element.documentID;
      if (coach.uid != _auth.currentUser.uid) {
        _coachList.add(coach);
      }
    });
    for (CoachPageListener coachPageListener in _coachPageListeners) {
      coachPageListener.onCoachListChange();
    }
  }

  Future<void> updateCoachList() async {
    _coachesOffset += _coachesLimit;
    Query query = _userRepository.coachesQuery();
    query = _filteringService.prepareQuery(query).limit(_coachesOffset);
    _userRepository.subscribeCoachList(query, _onCoachListChange);
  }

  Future<void> resetCoachList() async {
    _coachesOffset = 0;
    if (_coachList != null) {
      _coachList.clear();
    }
    _hasMoreCoaches = true;
    _userRepository.cancelCoachListSubscription();
    _userRepository.cancelSelectedCoachSubscription();
  }

  void _onCoachDataChange(DocumentSnapshot event, int cnt) {
    if (cnt == 1) {
      return;
    }
    if (!event.exists) {
      _selectedCoach = null;
    } else {
      _selectedCoach = CoachEntity.fromJson(event.data);
      _selectedCoach.uid = event.documentID;
    }
    _coachListeners.forEach((coachListener) {
      coachListener.onCoachDataChange();
    });
  }

  void setSelectedCoach(UserEntity coach) {
    if (coach == null) {
      _selectedCoach = null;
      return;
    }
    _selectedCoach = coach;
    _storageService.getCoachBackgroundImage(_selectedCoach);
    _storageService.getCoachProfileImage(_selectedCoach);
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
    String profession,
    String bio,
    List<SchoolSubject> schoolSubjects,
    List<Specialization> specializations,
  ) async {
    ExpertEntity expertEntity = ExpertEntity(
        name,
        surname,
        email,
        city,
        school,
        profession,
        bio,
        null,
        null,
        schoolSubjects,
        specializations);
    expertEntity.uid = userId;
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
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations,
      CoachType coachType) async {
    CoachEntity coachEntity = CoachEntity(
        name,
        surname,
        email,
        city,
        school,
        profession,
        bio,
        null,
        null,
        schoolSubjects,
        specializations,
        coachType);
    coachEntity.uid = userId;
    await _userRepository.updateUser(coachEntity);
    setCurrentUser(userId);
  }

  void _onUserDataChange(DocumentSnapshot event, int cnt) {
    UserType userType = UserTypeExtension.getValue(event.data["userType"]);
    switch (userType) {
      case UserType.COACH:
        _currentCoach = CoachEntity.fromJson(event.data);
        _currentCoach.uid = event.documentID;
        _currentUser = _currentExpert = _currentCoach;
        break;
      case UserType.EXPERT:
        _currentExpert = ExpertEntity.fromJson(event.data);
        _currentExpert.uid = event.documentID;
        _currentUser = _currentExpert;
        break;
    }
    if (cnt == 1) {
      _storageService.getUserProfileImage();
      _storageService.getUserBackgroundImage();
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

  Future<void> updateCurrentCoachData(
      String name,
      String surname,
      String city,
      String school,
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations,
      CoachType coachType) async {
    String profileImageName = _currentUser.profileImageName;
    String backgroundImageName = _currentUser.backgroundImageName;
    CoachEntity coach = CoachEntity(
        name,
        surname,
        _currentUser.email,
        city,
        school,
        profession,
        bio,
        profileImageName,
        backgroundImageName,
        schoolSubjects,
        specializations,
        coachType);
    coach.uid = _currentUser.uid;
    await updateUser(coach);
  }

  Future<void> updateCurrentExpertData(
      String name,
      String surname,
      String city,
      String school,
      String profession,
      String bio,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations) async {
    String profileImageName = _currentUser.profileImageName;
    String backgroundImageName = _currentUser.backgroundImageName;
    ExpertEntity expert = ExpertEntity(
        name,
        surname,
        _currentUser.email,
        city,
        school,
        profession,
        bio,
        profileImageName,
        backgroundImageName,
        schoolSubjects,
        specializations);
    expert.uid = _currentUser.uid;
    await updateUser(expert);
  }

  Future<void> updateUser(UserEntity userEntity) async {
    await _userRepository.updateUser(userEntity);
  }
}

abstract class UserListener {
  void onUserDataChange();
}

abstract class CoachPageListener {
  void onCoachListChange();
}

abstract class CoachListener {
  void onCoachDataChange();
}
