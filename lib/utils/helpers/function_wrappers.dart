import 'package:cloud_firestore/cloud_firestore.dart';

class FunctionWrappers {
  static Function createDocumentSnapshotFunctionWithCounter(
      void function(DocumentSnapshot event, int cnt),
      int invokeBeforeExecution) {
    int count = 0;
    return (args) {
      count++;
      if (count <= invokeBeforeExecution) {
        return;
      } else {
        return function(args, count);
      }
    };
  }
}