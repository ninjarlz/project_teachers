import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/user_enums.dart';

class FilteringService {
  static FilteringService _instance;

  FilteringService._privateConstructor();

  static FilteringService get instance {
    if (_instance == null) {
      _instance = FilteringService._privateConstructor();
    }
    return _instance;
  }

  CoachType activeCoachType;
  List<SchoolSubject> activeSchoolSubjects = List<SchoolSubject>();
  List<Specialization> activeSpecializations = List<Specialization>();
  int activeMaxAvailability;
  int activeRemainingAvailability;

  void resetFilters() {
    activeCoachType = null;
    activeSchoolSubjects = List<SchoolSubject>();
    activeSpecializations = List<Specialization>();
    activeMaxAvailability = null;
    activeRemainingAvailability = null;
  }

  Query prepareQuery(Query query) {
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
    if (activeMaxAvailability != null) {
      query = query.where(
          "maxAvailabilityPerWeek." + activeMaxAvailability.toString(),
          isEqualTo: true);
    }
    if (activeRemainingAvailability != null) {
      query = query.where(
          "remainingAvailabilityInWeek." + activeRemainingAvailability.toString(),
          isEqualTo: true);
    }
    return query;
  }
}
