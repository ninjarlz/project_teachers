import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolEntity {

  String id;
  String name;
  //String presentFor

  SchoolEntity(String name) {
    this.name = name;
  }

  factory SchoolEntity.fromJson(Map<String, dynamic> json) {
    return SchoolEntity(json["name"]);
  }

  factory SchoolEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return SchoolEntity(documentSnapshot.data["name"]);
  }

  toJson() {
    return {"name": name};
  }
}
