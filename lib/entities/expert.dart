import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_enums.dart';
import 'user.dart';


class Expert extends User {

  List<SchoolSubject> schoolSubjects;
  List<Specialization> specializations;

  Expert(String name, String surname, String city, String school, String email,
      List<SchoolSubject> schoolSubjects, List<Specialization> specializations) : super(
      name, surname, city, school, email, UserType.EXPERT) {
      this.schoolSubjects = schoolSubjects;
      this.specializations = specializations;
  }

  factory Expert.fromJson(Map<dynamic, dynamic> json) {
    return Expert(
      json["name"],
      json["surname"],
      json["email"],
      json["city"],
      json["school"],
      subjectsListFromSnapshot(json),
      specializationListFromSnapshot(json)
    );
  }

  factory Expert.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return Expert(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        subjectsListFromSnapshot(documentSnapshot.data),
        specializationListFromSnapshot(documentSnapshot.data)
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
      "schoolSubjects": getSubjectsLabels(schoolSubjects),
      "specializations": getSpecializationsLabels(specializations)
    };
  }

  static List<String> getSpecializationsLabels(List<Specialization> specializations) {
    List<String> specializationsLabels = List<String>();
    for (Specialization specialization in specializations) {
      specializationsLabels.add(specialization.label);
    }
    return specializationsLabels;
  }

  static List<String> getSubjectsLabels(List<SchoolSubject> schoolSubjects) {
    List<String> subjectsLabels = List<String>();
    for (SchoolSubject schoolSubject in schoolSubjects) {
      subjectsLabels.add(schoolSubject.label);
    }
    return subjectsLabels;
  }


  static List<Specialization> specializationListFromSnapshot(Map<dynamic, dynamic> snapshotMap) {
    List<Specialization> specializations = null;
    if (snapshotMap.containsKey("specializations")) {
      List<String> specializationLabels = new List<String>();
      specializations = new List<Specialization>();
      specializationLabels = snapshotMap["specializations"];
      specializationLabels.forEach((label) {
        specializations.add(SpecializationExtension.getValue(label));
      });
    }
    return specializations;
  }

  static List<SchoolSubject> subjectsListFromSnapshot(Map<dynamic, dynamic> snapshotMap) {
    List<SchoolSubject> subjects = null;
    if (snapshotMap.containsKey("schoolSubjects")) {
      List<String> subjectsLabels = new List<String>();
      subjects = new List<SchoolSubject>();
      subjectsLabels = snapshotMap["schoolSubjects"];
      subjectsLabels.forEach((label) {
        subjects.add(SchoolSubjectExtension.getValue(label));
      });
    }
    return subjects;
  }
}