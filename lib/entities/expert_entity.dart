import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_enums.dart';
import 'user_entity.dart';

class ExpertEntity extends UserEntity {
  List<SchoolSubject> schoolSubjects;
  List<Specialization> specializations;

  ExpertEntity(String name,
      String surname,
      String email,
      String city,
      String school,
      String profession,
      String bio,
      String profileImageName,
      String backgroundImageName,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations)
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
      UserType.EXPERT) {
    this.schoolSubjects = schoolSubjects;
    this.specializations = specializations;
  }

  factory ExpertEntity.fromJson(Map<dynamic, dynamic> json) {
    return ExpertEntity(
        json["name"],
        json["surname"],
        json["email"],
        json["city"],
        json["school"],
        json["profession"],
        json["bio"],
        json["profileImageName"],
        json["backgroundImageName"],
        subjectsListFromSnapshot(json),
        specializationListFromSnapshot(json));
  }

  factory ExpertEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ExpertEntity(
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        documentSnapshot.data["profession"],
        documentSnapshot.data["bio"],
        documentSnapshot.data["profileImageName"],
        documentSnapshot.data["backgroundImageName"],
        subjectsListFromSnapshot(documentSnapshot.data),
        specializationListFromSnapshot(documentSnapshot.data));
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
      "schoolSubjects": SchoolSubjectExtension.getLabelsFromList(schoolSubjects),
      "specializations": SpecializationExtension.getLabelsFromList(specializations)
    };
  }





  static List<Specialization> specializationListFromSnapshot(
      Map<dynamic, dynamic> snapshotMap) {
    List<Specialization> specializations = null;
    if (snapshotMap.containsKey("specializations")) {
      specializations = new List<Specialization>();
      List<dynamic> specializationLabels = snapshotMap["specializations"];
      specializationLabels.forEach((label) {
        specializations.add(SpecializationExtension.getValueFromLabel(label));
      });
    }
    return specializations;
  }

  static List<SchoolSubject> subjectsListFromSnapshot(
      Map<dynamic, dynamic> snapshotMap) {
    List<SchoolSubject> subjects = null;
    if (snapshotMap.containsKey("schoolSubjects")) {
      subjects = new List<SchoolSubject>();
      List<dynamic> subjectsLabels = snapshotMap["schoolSubjects"];
      subjectsLabels.forEach((label) {
        subjects.add(SchoolSubjectExtension.getValue(label));
      });
    }
    return subjects;
  }
}
