import 'package:firebase_database/firebase_database.dart';

class ValidEmailAddress {

  String email;
  bool isValidated;

  ValidEmailAddress(String email, bool isValidated) {
    this.email = email;
    this.isValidated = isValidated;
  }

  factory ValidEmailAddress.fromJson(Map<dynamic, dynamic> json) {
    return ValidEmailAddress(
        json["email"],
        json["isValidated"]
    );
  }

  factory ValidEmailAddress.fromSnapshot(DataSnapshot dataSnapshot) {
    return ValidEmailAddress(
        dataSnapshot.value["email"],
        dataSnapshot.value["isValidated"]
    );
  }

  toJson() {
    return {
      "email": email,
      "isValidated": isValidated
    };
  }
}