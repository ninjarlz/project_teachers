import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/users/coach_entity.dart';
import 'package:project_teachers/entities/users/expert_entity.dart';
import 'package:project_teachers/entities/users/user_entity.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'base_filtering_service.dart';

class UserFilteringService extends BaseFilteringService {
  static const String LAST_UNICODE_CHARACTER = "\uf8ff";

  static const NAME_SURNAME_FILTER = "name_surname";

  static UserFilteringService _instance;

  UserFilteringService._privateConstructor();

  static UserFilteringService get instance {
    if (_instance == null) {
      _instance = UserFilteringService._privateConstructor();
    }
    return _instance;
  }

  UserType activeUserType;
  CoachType activeCoachType;
  List<SchoolSubject> activeSchoolSubjects = List<SchoolSubject>();
  List<Specialization> activeSpecializations = List<Specialization>();
  String schoolId;
  String schoolName;
  int activeMaxAvailability;
  int activeRemainingAvailability;
  String searchFilter;

  @override
  void resetFilters() {
    activeUserType = null;
    activeCoachType = null;
    activeSchoolSubjects = List<SchoolSubject>();
    activeSpecializations = List<Specialization>();
    schoolId = null;
    schoolName = null;
    activeMaxAvailability = null;
    activeRemainingAvailability = null;
    searchFilter = null;
  }

  void prepareCoachPartOfQuery(Query query) {
    query = query.where(UserEntity.USER_TYPE_FIELD_NAME, isEqualTo: UserType.COACH.label);
    if (activeCoachType != null) {
      query = query.where(CoachEntity.COACH_TYPE_FIELD_NAME, isEqualTo: activeCoachType.label);
    }
    if (activeMaxAvailability != null) {
      query = query.where(CoachEntity.MAX_AVAILABILITY_FILED_NAME + "." + activeMaxAvailability.toString(),
          isEqualTo: true);
    }
    if (activeRemainingAvailability != null) {
      query = query.where(CoachEntity.REMAINING_AVAILABILITY_FIELD_NAME + "." + activeRemainingAvailability.toString(),
          isEqualTo: true);
    }
  }

  void prepareCommonPartOfQuery(Query query) {
    activeSpecializations.forEach((activeSpecialization) {
      query = query.where(ExpertEntity.SPECIALIZATIONS_FIELD_NAME + "." + activeSpecialization.label, isEqualTo: true);
    });
    activeSchoolSubjects.forEach((activeSchoolSubject) {
      query = query.where(ExpertEntity.SCHOOL_SUBJECTS_FIELD_NAME + "." + activeSchoolSubject.label, isEqualTo: true);
    });
    if (schoolId != null) {
      query = query.where(UserEntity.SCHOOL_ID_FIELD_NAME, isEqualTo: schoolId);
    }
  }

  @override
  Query prepareQuery(Query query) {
    if (searchFilter != null) {
      query = query.orderBy(NAME_SURNAME_FILTER).startAt([searchFilter]).endAt([searchFilter + LAST_UNICODE_CHARACTER]);
    } else {
      if (activeUserType == UserType.EXPERT) {
        query = query.where(UserEntity.USER_TYPE_FIELD_NAME, isEqualTo: UserType.EXPERT.label);
      } else if (activeUserType == UserType.COACH) {
        prepareCoachPartOfQuery(query);
      }
      prepareCommonPartOfQuery(query);
    }
    return query;
  }
}
