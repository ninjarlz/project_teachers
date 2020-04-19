import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/user_enums.dart';

import 'expert_entity.dart';

class CoachEntity extends ExpertEntity {
  CoachType coachType;

  CoachEntity(
      String name,
      String surname,
      String email,
      String city,
      String school,
      String profession,
      String bio,
      String profileImageName,
      String backgroundImageName,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations,
      CoachType coachType)
      : super(
            name,
            surname,
            email,
            city,
            school,
            profession,
            bio,
            profileImageName,
            backgroundImageName,
            schoolSubjects,
            specializations) {
    userType = UserType.COACH;
    this.coachType = coachType;
  }

  factory CoachEntity.fromJson(Map<dynamic, dynamic> json) {
    return CoachEntity(
        json["name"],
        json["surname"],
        json["email"],
        json["city"],
        json["school"],
        json["profession"],
        json["bio"],
        json["profileImageName"],
        json["backgroundImageName"],
        ExpertEntity.subjectsListFromSnapshot(json),
        ExpertEntity.specializationListFromSnapshot(json),
        CoachTypeExtension.getValue(json["coachType"]));
  }

  factory CoachEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return CoachEntity(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        documentSnapshot.data["profession"],
        documentSnapshot.data["bio"],
        documentSnapshot.data["profileImageName"],
        documentSnapshot.data["backgroundImageName"],
        ExpertEntity.subjectsListFromSnapshot(documentSnapshot.data),
        ExpertEntity.specializationListFromSnapshot(documentSnapshot.data),
        CoachTypeExtension.getValue(documentSnapshot.data["coachType"]));
  }

  @override
  toJson() {
    return {
      "name": name,
      "surname": surname,
      "city": city,
      "school": school,
      "email": email,
      "profession": profession,
      "bio": bio,
      "profileImageName" : profileImageName,
      "backgroundImageName" : backgroundImageName,
      "userType": userType.label,
      "schoolSubjects": ExpertEntity.getSubjectsLabels(schoolSubjects),
      "specializations": ExpertEntity.getSpecializationsLabels(specializations),
      "coach": coachType.label
    };
  }
}
