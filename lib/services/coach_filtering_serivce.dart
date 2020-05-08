import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/services/base_filtering_service.dart';

class CoachFilteringService extends BaseFilteringService {
  static CoachFilteringService _instance;

  CoachFilteringService._privateConstructor();

  static CoachFilteringService get instance {
    if (_instance == null) {
      _instance = CoachFilteringService._privateConstructor();
    }
    return _instance;
  }

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
      if (activeCoachType != null) {
        query = query.where("coachType", isEqualTo: activeCoachType.label);
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
    return query;
  }
}
