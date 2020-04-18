import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolRepository {

  SchoolRepository._privateConstructor();
  static SchoolRepository _instance;
  static SchoolRepository get instance {
    if (_instance == null) {
      _instance = SchoolRepository._privateConstructor();
      _instance._database = Firestore.instance;
      //_instance._schoolsReference = _instance._database.collection("");
    }
    return _instance;
  }

  Firestore _database;
  DocumentReference _schoolsReference;
}