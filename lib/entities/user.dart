import 'package:firebase_database/firebase_database.dart';

class User {

  String name;
  String email;

  User(String name, String email) {
    this.name = name;
    this.email = email;
    if (this.name == null) {
      List<String> split = email.split("@");
      this.name = split[0];
    }
  }

  factory User.fromJson(Map<dynamic, dynamic> json) {
    return User(
      json["name"],
      json["email"]
    );
  }

  factory User.fromSnapshot(DataSnapshot dataSnapshot) {
    return User(
      dataSnapshot.value["name"],
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