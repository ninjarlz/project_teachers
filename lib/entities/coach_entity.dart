import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/entities/user_enums.dart';

import 'expert_entity.dart';

class CoachEntity extends ExpertEntity {
  CoachType coachType;
  int maxAvailabilityPerWeek;
  int remainingAvailabilityInWeek;

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
      CoachType coachType,
      int maxAvailabilityPerWeek,
      int remainingAvailabilityInWeek)
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
    this.maxAvailabilityPerWeek = maxAvailabilityPerWeek;
    this.remainingAvailabilityInWeek = remainingAvailabilityInWeek;
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
        CoachTypeExtension.getValue(json["coachType"]),
        maxAvailabilityFromSnapshot(json),
        remainingAvailabilityFromSnapshot(json));
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
        CoachTypeExtension.getValue(documentSnapshot.data["coachType"]),
        maxAvailabilityFromSnapshot(documentSnapshot.data),
        remainingAvailabilityFromSnapshot(documentSnapshot.data));
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
      "profileImageName": profileImageName,
      "backgroundImageName": backgroundImageName,
      "userType": userType.label,
      "schoolSubjects": ExpertEntity.schoolSubjectsMapFromList(schoolSubjects),
      "specializations":
          ExpertEntity.specializationsMapFromList(specializations),
      "coachType": coachType.label,
      "maxAvailabilityPerWeek": filterableBoolMapFromMaxAvailability(),
      "remainingAvailabilityInWeek":
          filterableBoolMapFromRemainingAvailability()
    };
  }

  Map<String, bool> filterableBoolMapFromMaxAvailability() {
    Map<String, bool> map = Map<String, bool>();
    for (int i = 1; i <= maxAvailabilityPerWeek; i++) {
      map[i.toString()] = true;
    }
    return map;
  }

  Map<String, bool> filterableBoolMapFromRemainingAvailability() {
    Map<String, bool> map = Map<String, bool>();
    for (int i = 1; i <= maxAvailabilityPerWeek; i++) {
      map[i.toString()] = i <= remainingAvailabilityInWeek;
    }
    return map;
  }

  static int maxAvailabilityFromSnapshot(Map<dynamic, dynamic> snapshot) {
    int maxAvailability = null;
    if (snapshot.containsKey("maxAvailabilityPerWeek")) {
      Map<dynamic, dynamic> maxAvailabilityMap = snapshot["maxAvailabilityPerWeek"];
      maxAvailability = maxAvailabilityMap.values.length;
    }
    return maxAvailability;
  }

  static int remainingAvailabilityFromSnapshot(Map<dynamic, dynamic> snapshot) {
    int remainingAvailability = null;
    if (snapshot.containsKey("remainingAvailabilityInWeek")) {
      Map<dynamic, dynamic> remainingAvailabilityMap =
          snapshot["remainingAvailabilityInWeek"];
      int counter = 0;
      remainingAvailabilityMap.forEach((key, value) {
        if (value) {
          counter++;
        } else {
          return;
        }
      });
      remainingAvailability = counter;
    }
    return remainingAvailability;
  }
}
