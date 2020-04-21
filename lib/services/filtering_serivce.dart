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

  void resetFilters() {
    activeCoachType = null;
    activeSchoolSubjects = List<SchoolSubject>();
    activeSpecializations = List<Specialization>();
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
    return query;
  }
}
