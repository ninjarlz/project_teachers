import 'package:firebase_database/firebase_database.dart';
import 'user_enums.dart';

class User {

  bool isInitialized;
  String name;
  String surname;
  String email;
  UserType userType;


  User(String name, String surname, String email, UserType userType) {
    this.name = name;
    this.surname = surname;
    this.email = email;
    this.userType = userType;
  }


  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      json["name"],
      json["surname"],
      json["email"],
      UserTypeExtension.getValue(json["userType"])
    );
  }

  factory User.fromSnapshot(DataSnapshot dataSnapshot) {
    return User(
        dataSnapshot.value["name"],
        dataSnapshot.value["surname"],
        dataSnapshot.value["email"],
        UserTypeExtension.getValue(dataSnapshot.value["userType"])
    );
  }

  toJson() {
    return {
      "name": name,
      "surname": surname,
      "email": email,
      "userType": userType.label
    };
  }
}