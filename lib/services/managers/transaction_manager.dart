import 'package:cloud_firestore/cloud_firestore.dart';

class WriteBatchManager {
  WriteBatchManager.privateConstructor();

  static WriteBatchManager _instance;

  static WriteBatchManager get instance {
    if (_instance == null) {
      _instance = WriteBatchManager.privateConstructor();
      _instance._database = Firestore.instance;
    }
    return _instance;
  }
  
  Firestore _database;
  
  WriteBatch createWriteBatch() {
    return _database.batch();
  }

  Future<void> commitWriteBatch(WriteBatch writeBatch) async {
    await writeBatch.commit();
  }
}
