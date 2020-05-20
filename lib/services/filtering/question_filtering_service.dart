import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/services/filtering/base_filtering_service.dart';

class QuestionFilteringService extends BaseFilteringService {

  static QuestionFilteringService _instance;

  QuestionFilteringService._privateConstructor();

  static QuestionFilteringService get instance {
    if (_instance == null) {
      _instance = QuestionFilteringService._privateConstructor();
    }
    return _instance;
  }


  @override
  Query prepareQuery(Query query) {
    return query;
  }

  @override
  void resetFilters() {
    // TODO: implement resetFilters
  }

}