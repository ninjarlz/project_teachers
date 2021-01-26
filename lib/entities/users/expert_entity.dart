import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_enums.dart';
import 'user_entity.dart';

class ExpertEntity extends UserEntity {

  static const String SCHOOL_SUBJECTS_FIELD_NAME = "schoolSubjects";
  static const String SPECIALIZATIONS_FIELD_NAME = "specializations";

  List<SchoolSubject> schoolSubjects;
  List<Specialization> specializations;

  ExpertEntity(
      String uid,
      String name,
      String surname,
      String email,
      String city,
      String school,
      String schoolID,
      String profession,
      String bio,
      String profileImageName,
      String backgroundImageName,
      List<String> likedPosts,
      List<SchoolSubject> schoolSubjects,
      List<Specialization> specializations)
      : super(uid, name, surname, email, city, school, schoolID, profession, bio, profileImageName, backgroundImageName,
            likedPosts, UserType.EXPERT) {
    this.schoolSubjects = schoolSubjects;
    this.specializations = specializations;
  }

  factory ExpertEntity.fromJson(Map<dynamic, dynamic> json) {
    return ExpertEntity(
        json["uid"],
        json["name"],
        json["surname"],
        json["email"],
        json["city"],
        json["school"],
        json["schoolID"],
        json["profession"],
        json["bio"],
        json["profileImageName"],
        json["backgroundImageName"],
        json["likedPosts"] != null ? List<String>.from(json["likedPosts"]) : List<String>(),
        subjectsListFromSnapshot(json),
        specializationListFromSnapshot(json));
  }

  factory ExpertEntity.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return ExpertEntity(
        documentSnapshot.data["uid"],
        documentSnapshot.data["name"],
        documentSnapshot.data["surname"],
        documentSnapshot.data["email"],
        documentSnapshot.data["city"],
        documentSnapshot.data["school"],
        documentSnapshot.data["schoolID"],
        documentSnapshot.data["profession"],
        documentSnapshot.data["bio"],
        documentSnapshot.data["profileImageName"],
        documentSnapshot.data["backgroundImageName"],
        documentSnapshot.data["likedPosts"] != null
            ? List<String>.from(documentSnapshot.data["likedPosts"])
            : List<String>(),
        subjectsListFromSnapshot(documentSnapshot.data),
        specializationListFromSnapshot(documentSnapshot.data));
  }

  @override
  toJson() {
    return {
      "uid": uid,
      "name": name,
      "surname": surname,
      "name_surname": name.toLowerCase() + " " + surname.toLowerCase(),
      "city": city,
      "school": school,
      "schoolID": schoolID,
      "email": email,
      "profession": profession,
      "bio": bio,
      "profileImageName": profileImageName,
      "backgroundImageName": backgroundImageName,
      "likedPosts": likedPosts,
      "userType": userType.label,
      "schoolSubjects": schoolSubjectsMapFromList(schoolSubjects),
      "specializations": specializationsMapFromList(specializations)
    };
  }

  static Map<String, bool> schoolSubjectsMapFromList(List<SchoolSubject> schoolSubjects) {
    if (schoolSubjects == null) {
      return null;
    }
    Map<String, bool> map = Map<String, bool>();
    for (int i = 1; i < SchoolSubject.values.length; i++) {
      map[SchoolSubject.values[i].label] = schoolSubjects.contains(SchoolSubject.values[i]);
    }
    return map;
  }

  static Map<String, bool> specializationsMapFromList(List<Specialization> specializations) {
    if (specializations == null) {
      return null;
    }
    Map<String, bool> map = Map<String, bool>();
    for (Specialization specialization in Specialization.values) {
      map[specialization.label] = specializations.contains(specialization);
    }
    return map;
  }

  static List<Specialization> specializationListFromSnapshot(Map<dynamic, dynamic> snapshotMap) {
    List<Specialization> specializations = null;
    if (snapshotMap.containsKey("specializations") && snapshotMap["specializations"] != null) {
      specializations = new List<Specialization>();
      Map<dynamic, dynamic> specializationsLabels = snapshotMap["specializations"];
      specializationsLabels.forEach((key, value) {
        if (value) {
          specializations.add(SpecializationExtension.getValueFromLabel(key));
        }
      });
    }
    return specializations;
  }

  static List<SchoolSubject> subjectsListFromSnapshot(Map<dynamic, dynamic> snapshotMap) {
    List<SchoolSubject> subjects = null;
    if (snapshotMap.containsKey("schoolSubjects") && snapshotMap["schoolSubjects"] != null) {
      subjects = new List<SchoolSubject>();
      Map<dynamic, dynamic> subjectsLabels = snapshotMap["schoolSubjects"];
      subjectsLabels.forEach((key, value) {
        if (value) {
          subjects.add(SchoolSubjectExtension.getValue(key));
        }
      });
    }
    return subjects;
  }
}
