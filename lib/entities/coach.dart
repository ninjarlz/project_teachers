import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/user_enums.dart';

import 'expert.dart';

class Coach extends Expert {

  CoachType coachType;

  Coach(String name, String surname, String city, String school, String email,
      List<SchoolSubject> schoolSubjects, List<Specialization> specializations,
      CoachType coachType) : super(
      name, surname, city, school, email, schoolSubjects, specializations) {
    userType = UserType.COACH;
    this.coachType = coachType;
  }

  factory Coach.fromJson(Map<dynamic, dynamic> json) {
    return Coach(
        json["name"],
        json["surname"],
        json["email"],
        json["city"],
        json["school"],
        Expert.subjectsListFromSnapshot(json),
        Expert.specializationListFromSnapshot(json),
        json["coachType"]
    );
  }

  factory Coach.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return Coach(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        Expert.subjectsListFromSnapshot(documentSnapshot.data),
        Expert.specializationListFromSnapshot(documentSnapshot.data),
        CoachTypeExtension.getValue(documentSnapshot.data["coachType"])
    );
  }

  @override
  toJson() {
    return {
      "name": name,
      "surname": surname,
      "city" : city,
      "school" : school,
      "email": email,
      "userType": userType.label,
      "schoolSubjects": Expert.getSubjectsLabels(schoolSubjects),
      "specializations": Expert.getSpecializationsLabels(specializations),
      "coach": coachType.label
    };
  }

}