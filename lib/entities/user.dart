import 'package:firebase_database/firebase_database.dart';

enum UserType {
  COACH, EXPERT
}

extension on UserType {

}

class User {



  bool isInitialized;
  String name;
  String surname;
  String email;

  User(String name, String surname, String email) {
    this.name = name;
    this.surname = surname;
    this.email = email;
//    if (this.name == null) {
//      List<String> split = email.split("@");
//      this.name = split[0];
//    }
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      json["name"],
      json["surname"],
      json["email"]
    );
  }

  factory User.fromSnapshot(DataSnapshot dataSnapshot) {
    return User(
      dataSnapshot.value["name"],
      dataSnapshot.value["surname"],
      dataSnapshot.value["email"]
    );
  }

  toJson() {
    return {
      "name": name,
      "email": email
    };
  }
}