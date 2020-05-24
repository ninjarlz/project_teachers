import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionManager {
  TransactionManager.privateConstructor();

  static TransactionManager _instance;

  static TransactionManager get instance {
    if (_instance == null) {
      _instance = TransactionManager.privateConstructor();
      _instance._database = Firestore.instance;
    }
    return _instance;
  }
  
  Firestore _database;
  
  Future<void> runTransaction(Function(Transaction) onTransaction) async {
    await _database.runTransaction(await onTransaction);
  }
}
