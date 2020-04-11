import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_enums.dart';

class UserEntity {

  String name;
  String surname;
  String city;
  String school;
  String email;
  String profession;
  UserType userType;


  UserEntity(String name, String surname, String email, String city, String school, String profession, UserType userType) {
    this.name = name;
    this.surname = surname;
    this.school = school;
    this.city = city;
    this.email = email;
    this.profession = profession;
    this.userType = userType;
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      json["name"],
      json["surname"],
      json["email"],
      json["city"],
      json["school"],
      json["profession"],
      UserTypeExtension.getValue(json["userType"])
    );
  }

  factory UserEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserEntity(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        documentSnapshot.data["profession"],
        UserTypeExtension.getValue(documentSnapshot.data["userType"])
    );
  }

  toJson() {
    return {
      "name": name,
      "surname": surname,
      "city" : city,
      "school" : school,
      "email": email,
      "profession": profession,
      "userType": userType.label
    };
  }
}