import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFilteringService {
  void resetFilters();

  Query prepareQuery(Query query);
}
