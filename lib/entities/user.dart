import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_enums.dart';

class User {

  String name;
  String surname;
  String city;
  String school;
  String email;
  UserType userType;


  User(String name, String surname, String email, String city, String school, UserType userType) {
    this.name = name;
    this.surname = surname;
    this.school = school;
    this.city = city;
    this.email = email;
    this.userType = userType;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json["name"],
      json["surname"],
      json["email"],
      json["city"],
      json["school"],
      UserTypeExtension.getValue(json["userType"])
    );
  }

  factory User.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return User(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
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
      "userType": userType.label
    };
  }
}