import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/users/user_enums.dart';

class ValidEmailAddress {

  static const String EMAIL_FIELD_NAME = "email";
  static const String IS_VALIDATED_NAME_FIELD_NAME = "isValidated";
  static const String IS_INITIALIZED_FIELD_NAME = "isInitialized";
  static const String USER_TYPE_FIELD_NAME = "userType";

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
        json[EMAIL_FIELD_NAME],
        json[IS_VALIDATED_NAME_FIELD_NAME],
        json[IS_INITIALIZED_FIELD_NAME],
        UserTypeExtension.getValue(json[USER_TYPE_FIELD_NAME])
    );
  }

  factory ValidEmailAddress.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ValidEmailAddress(
        documentSnapshot.data[EMAIL_FIELD_NAME],
        documentSnapshot.data[IS_VALIDATED_NAME_FIELD_NAME],
        documentSnapshot.data[IS_INITIALIZED_FIELD_NAME],
        UserTypeExtension.getValue(documentSnapshot.data[USER_TYPE_FIELD_NAME]),
    );
  }

  toJson() {
    return {
      EMAIL_FIELD_NAME: email,
      IS_VALIDATED_NAME_FIELD_NAME: isValidated,
      IS_INITIALIZED_FIELD_NAME: isInitialized,
      USER_TYPE_FIELD_NAME: userType.label
    };
  }
}