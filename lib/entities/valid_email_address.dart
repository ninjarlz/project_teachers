import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/user_enums.dart';

class ValidEmailAddress {

  String email;
  bool isValidated;
  bool isInitialized;
  UserType userType;

  ValidEmailAddress(String email, bool isValidated, bool isInitialized, UserType userType) {
    this.email = email;
    this.isValidated = isValidated;
    this.isInitialized = isInitialized;
    this.userType = userType;
  }

  factory ValidEmailAddress.fromJson(Map<String, dynamic> json) {
    return ValidEmailAddress(
        json["email"],
        json["isValidated"],
        json["isInitialized"],
        UserTypeExtension.getValue(json["userType"])
    );
  }

  factory ValidEmailAddress.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ValidEmailAddress(
        documentSnapshot.data["email"],
        documentSnapshot.data["isValidated"],
        documentSnapshot.data["isInitialized"],
        UserTypeExtension.getValue(documentSnapshot.data["userType"]),
    );
  }

  toJson() {
    return {
      "email": email,
      "isValidated": isValidated,
      "isInitialized": isInitialized,
      "userType": userType.label
    };
  }
}