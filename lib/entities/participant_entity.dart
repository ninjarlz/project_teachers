import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantEntity {

  static const String ID_FIELD_NAME = "id";
  static const String PROFILE_IMAGE_NAME_FIELD_NAME = "profileImageName";
  static const String NAME_FIELD_NAME = "name";
  static const String SURNAME_FIELD_NAME = "surname";

  String id;
  String profileImageName;
  String name;
  String surname;

  ParticipantEntity(this.profileImageName, this.name, this.surname);

  factory ParticipantEntity.fromJson(Map<String, dynamic> json) {
    return ParticipantEntity(
        json[PROFILE_IMAGE_NAME_FIELD_NAME],
        json[NAME_FIELD_NAME],
        json[SURNAME_FIELD_NAME]);
  }

  factory ParticipantEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ParticipantEntity(
        documentSnapshot.data[PROFILE_IMAGE_NAME_FIELD_NAME],
        documentSnapshot.data[NAME_FIELD_NAME],
        documentSnapshot.data[SURNAME_FIELD_NAME]);
  }

  toJson() {
    return {
      PROFILE_IMAGE_NAME_FIELD_NAME: profileImageName,
      NAME_FIELD_NAME: name,
      SURNAME_FIELD_NAME: surname
    };
  }
}