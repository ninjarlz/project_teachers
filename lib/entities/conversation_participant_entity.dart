import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationParticipantEntity {

  String id;
  String profileImageName;
  String name;
  String surname;

  ConversationParticipantEntity(this.profileImageName, this.name, this.surname);

  factory ConversationParticipantEntity.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantEntity(
        json["profileImageName"],
        json["name"],
        json["surname"]);
  }

  factory ConversationParticipantEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ConversationParticipantEntity(
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