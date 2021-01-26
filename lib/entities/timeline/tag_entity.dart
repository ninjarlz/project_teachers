import 'package:cloud_firestore/cloud_firestore.dart';

class TagEntity {
  static const String VALUE_FIELD_NAME = "value";
  static const String POSTS_COUNTER_FIELD_NAME = "postsCounter";

  String value;
  int postsCounter;

  TagEntity(this.value, this.postsCounter);

  factory TagEntity.fromJson(Map<String, dynamic> json) {
    return TagEntity(json[VALUE_FIELD_NAME], json[POSTS_COUNTER_FIELD_NAME]);
  }

  factory TagEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return TagEntity(documentSnapshot.data[VALUE_FIELD_NAME], documentSnapshot.data[POSTS_COUNTER_FIELD_NAME]);
  }

  toJson() {
    return {VALUE_FIELD_NAME: value, POSTS_COUNTER_FIELD_NAME: postsCounter};
  }
}
