import 'package:firebase_database/firebase_database.dart';
import 'user_enums.dart';
import 'user.dart';

//
//class Expert extends User {
//
//  List<SchoolSubject> schoolSubjects;
//  List<Specialization> specializations;
//
//  Expert(String name, String surname, String email,
//      List<SchoolSubject> schoolSubjects, List<Specialization> specializations) : super(name, surname, email) {
//    userType = UserType.EXPERT;
//
//  }

//  factory Expert.fromJson(Map<dynamic, dynamic> json) {
//    if (!json.containsKey("schoolSubject"))
//
//    return Expert(
//      json["name"],
//      json["surname"],
//      json["email"],
//    );
//  }
//
//  factory User.fromSnapshot(DataSnapshot dataSnapshot) {
//    return User(
//        dataSnapshot.value["name"],
//        dataSnapshot.value["surname"],
//        dataSnapshot.value["email"]
//    );
//  }
//
//  toJson() {
//    return {
//      "name": name,
//      "surname": surname,
//      "email": email
//    };
//  }
//}