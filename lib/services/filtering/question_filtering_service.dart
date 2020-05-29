import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/users/user_enums.dart';
import 'package:project_teachers/services/filtering/base_filtering_service.dart';

class QuestionFilteringService extends BaseFilteringService {
  static QuestionFilteringService _instance;

  QuestionFilteringService._privateConstructor();

  static QuestionFilteringService get instance {
    if (_instance == null) {
      _instance = QuestionFilteringService._privateConstructor();
      _instance.orderingField = _instance.orderingValues[0];
    }
    return _instance;
  }

  String selectedTag;
  SchoolSubject selectedSubject;
  String orderingField = "timestamp";
  List<String> orderingValues = [
    "timestamp",
    "reactionsCounter",
    "answersCounter"
  ];

  @override
  void resetFilters() {
    selectedTag = null;
    selectedSubject = null;
    orderingField = _instance.orderingValues[0];
  }

  @override
  Query prepareQuery(Query query) {
    if (selectedTag != null) {
      query = query.where("tags", arrayContains: selectedTag);
    }
    if (selectedSubject != null) {
      query = query.where("schoolSubject", isEqualTo: selectedSubject.label);
    }
    query = query.orderBy(orderingField, descending: true);
    return query;
  }
}
