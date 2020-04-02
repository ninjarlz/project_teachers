import 'package:firebase_database/firebase_database.dart';
import 'package:project_teachers/entities/user_enums.dart';

class ValidEmailAddress {

  String email;
  bool isValidated;
  UserType userType;

  ValidEmailAddress(String email, bool isValidated, UserType userType) {
    this.email = email;
    this.isValidated = isValidated;
    this.userType = userType;
  }

  factory ValidEmailAddress.fromJson(Map<dynamic, dynamic> json) {
    return ValidEmailAddress(
        json["email"],
        json["isValidated"],
        UserTypeExtension.getValue(json["userType"])
    );
  }

  factory ValidEmailAddress.fromSnapshot(DataSnapshot dataSnapshot) {
    return ValidEmailAddress(
        dataSnapshot.value["email"],
        dataSnapshot.value["isValidated"],
        UserTypeExtension.getValue(dataSnapshot.value["userType"]),
    );
  }

  toJson() {
    return {
      "email": email,
      "isValidated": isValidated,
      "userType": userType.label
    };
  }
}