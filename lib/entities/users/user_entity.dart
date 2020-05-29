import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_enums.dart';

class UserEntity {
  String uid;
  String name;
  String surname;
  String city;
  String school;
  String schoolID;
  String email;
  String profession;
  String bio;
  String profileImageName;
  String backgroundImageName;
  List<String> likedPosts;
  UserType userType;

  UserEntity(
      String uid,
      String name,
      String surname,
      String email,
      String city,
      String school,
      String schoolID,
      String profession,
      String bio,
      String profileImageName,
      String backgroundImageName,
          List<String> likedPosts,
      UserType userType) {
    this.uid = uid;
    this.name = name;
    this.surname = surname;
    this.school = school;
    this.schoolID = schoolID;
    this.city = city;
    this.email = email;
    this.profession = profession;
    this.bio = bio;
    this.profileImageName = profileImageName;
    this.backgroundImageName = backgroundImageName;
    this.likedPosts = likedPosts;
    this.userType = userType;
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
        json["uid"],
        json["name"],
        json["surname"],
        json["email"],
        json["city"],
        json["school"],
        json["schoolID"],
        json["profession"],
        json["bio"],
        json["profileImageName"],
        json["backgroundImageName"],
        json["likedPosts"] != null
            ? List<String>.from(json["likedPosts"])
            : List<String>(),
        UserTypeExtension.getValue(json["userType"]));
  }

  factory UserEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return UserEntity(
        documentSnapshot.data["uid"],
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        documentSnapshot.data["schoolD"],
        documentSnapshot.data["profession"],
        documentSnapshot.data["bio"],
        documentSnapshot.data["profileImageName"],
        documentSnapshot.data["backgroundImageName"],
        documentSnapshot.data["likedPosts"] != null
            ? List<String>.from(documentSnapshot.data["likedPosts"])
            : List<String>(),
        UserTypeExtension.getValue(documentSnapshot.data["userType"]));
  }

  toJson() {
    return {
      "uid": uid,
      "name": name,
      "surname": surname,
      "name_surname": name.toLowerCase() + " " + surname.toLowerCase(),
      "city": city,
      "school": school,
      "schoolID": schoolID,
      "email": email,
      "profession": profession,
      "bio": bio,
      "profileImageName" : profileImageName,
      "backgroundImageName" : backgroundImageName,
      "likedPosts": likedPosts,
      "userType": userType.label
    };
  }
}
