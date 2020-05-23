import 'package:cloud_firestore/cloud_firestore.dart';

class TagEntity {
  String value;
  int postsCounter;


  TagEntity(this.value, this.postsCounter);

  factory TagEntity.fromJson(Map<String, dynamic> json) {
    return TagEntity(
        json["value"],
        json["postsCounter"]);
  }

  factory TagEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return TagEntity(
        documentSnapshot.data["value"],
        documentSnapshot.data["postsCounter"]);
  }

  toJson() {
    return {
      "value": value,
      "postsCounter": postsCounter
    };
  }
}