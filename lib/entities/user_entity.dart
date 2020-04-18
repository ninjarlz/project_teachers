import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_enums.dart';

class UserEntity {
  String uid;
  String name;
  String surname;
  String city;
  String school;

  //Map<String, dynamic>
  String email;
  String profession;
  String bio;
  UserType userType;

  UserEntity(String name, String surname, String email, String city,
      String school, String profession, String bio, UserType userType) {
    this.name = name;
    this.surname = surname;
    this.school = school;
    this.city = city;
    this.email = email;
    this.profession = profession;
    this.bio = bio;
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
        json["bio"],
        UserTypeExtension.getValue(json["userType"]));
  }

  factory UserEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserEntity(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        documentSnapshot.data["profession"],
        documentSnapshot.data["bio"],
        UserTypeExtension.getValue(documentSnapshot.data["userType"]));
  }

  toJson() {
    return {
      "name": name,
      "surname": surname,
      "city": city,
      "school": school,
      "email": email,
      "profession": profession,
      "bio": bio,
      "userType": userType.label
    };
  }
}
