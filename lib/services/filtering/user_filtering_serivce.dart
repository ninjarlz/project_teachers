import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'base_filtering_service.dart';

class UserFilteringService extends BaseFilteringService {
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

  @override
  Query prepareQuery(Query query) {
    if (searchFilter != null) {
      query = query
          .orderBy("name_surname")
          .startAt([searchFilter]).endAt([searchFilter + "\uf8ff"]);
    } else {
      if (activeUserType == UserType.EXPERT) {
        query = query.where("userType", isEqualTo: "Expert");
      } else if (activeUserType == UserType.COACH) {
        query = query.where("userType", isEqualTo: "Coach");
        if (activeCoachType != null) {
          query = query.where("coachType", isEqualTo: activeCoachType.label);
        }
        if (activeMaxAvailability != null) {
          query = query.where(
              "maxAvailabilityPerWeek." + activeMaxAvailability.toString(),
              isEqualTo: true);
        }
        if (activeRemainingAvailability != null) {
          query = query.where(
              "remainingAvailabilityInWeek." +
                  activeRemainingAvailability.toString(),
              isEqualTo: true);
        }
      }
      for (Specialization activeSpecialization in activeSpecializations) {
        query = query.where("specializations." + activeSpecialization.label,
            isEqualTo: true);
      }
      for (SchoolSubject activeSchoolSubject in activeSchoolSubjects) {
        query = query.where("schoolSubjects." + activeSchoolSubject.label,
            isEqualTo: true);
      }
      if (schoolId != null) {
        query = query.where("schoolID", isEqualTo: schoolId);
      }
    }
    return query;
  }
}
