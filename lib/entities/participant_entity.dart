import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantEntity {

  String id;
  String profileImageName;
  String name;
  String surname;

  ParticipantEntity(this.profileImageName, this.name, this.surname);

  factory ParticipantEntity.fromJson(Map<String, dynamic> json) {
    return ParticipantEntity(
        json["profileImageName"],
        json["name"],
        json["surname"]);
  }

  factory ParticipantEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ParticipantEntity(
        documentSnapshot.data["profileImageName"],
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"]);
  }

  toJson() {
    return {
      "profileImageName": profileImageName,
      "name": name,
      "surname": surname
    };
  }
}