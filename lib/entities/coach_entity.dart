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
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations,
      CoachType coachType)
      : super(name, surname, email, city, school, profession, bio,
            schoolSubjects, specializations) {
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
        ExpertEntity.subjectsListFromSnapshot(json),
        ExpertEntity.specializationListFromSnapshot(json),
        json["coachType"]);
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
      "userType": userType.label,
      "schoolSubjects": ExpertEntity.getSubjectsLabels(schoolSubjects),
      "specializations": ExpertEntity.getSpecializationsLabels(specializations),
      "coach": coachType.label
    };
  }
}
