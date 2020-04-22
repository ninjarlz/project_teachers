import 'dart:async';
import 'package:project_teachers/entities/valid_email_address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ValidEmailAddressRepository {

  ValidEmailAddressRepository._privateConstructor();

  static const String DB_ERROR_MSG = "An error with database occured";
  static const String TRANSACTION_NOT_COMMITED_MSG = "Transaction not committed";
  static const String NO_EMAIL_ADDRESS_MSG = "There is no such email address";

  static ValidEmailAddressRepository _instance;
  static ValidEmailAddressRepository get instance {
    if (_instance == null) {
      _instance = ValidEmailAddressRepository._privateConstructor();
      _instance._database = Firestore.instance;
    }
    return _instance;
  }

  Firestore _database;


  Future<List<ValidEmailAddress>> getNotValidatedEmailAddresses() async {
    QuerySnapshot emailSnapshot = await _database
        .collection("ValidEmailAdresses").where("isValidated", isEqualTo: false).getDocuments();
    List<ValidEmailAddress> notValidatedValidEmails = List<ValidEmailAddress>();
    List<DocumentSnapshot> list = emailSnapshot.documents;
    print(list);
    list.forEach((element) {
      ValidEmailAddress validEmailAddress = ValidEmailAddress.fromSnapshot(element);
      print(element);
      notValidatedValidEmails.add(validEmailAddress);
    });
    return notValidatedValidEmails;
  }

  Future<ValidEmailAddress> getNotValidatedEmailAddress(String email) async {
    QuerySnapshot emailSnapshot = await _database
        .collection("ValidEmailAdresses").where("isValidated", isEqualTo: false)
        .where("email", isEqualTo: email).getDocuments();
    if (emailSnapshot.documents.isNotEmpty) {
      return ValidEmailAddress.fromSnapshot(emailSnapshot.documents[0]);
    } else {
      return null;
    }
  }

  Future<List<ValidEmailAddress>> getEmailAddresses() async {
    QuerySnapshot emailSnapshot = await _database
        .collection("ValidEmailAdresses").getDocuments();
    List<ValidEmailAddress> emails = List<ValidEmailAddress>();
    List<DocumentSnapshot> list = emailSnapshot.documents;
    list.forEach((element) {
      ValidEmailAddress validEmailAddress = ValidEmailAddress.fromSnapshot(element);
      print(element);
      emails.add(validEmailAddress);
    });
    return emails;
  }


  Future<ValidEmailAddress> getValidEmailAddress(String email) async {
    QuerySnapshot emailSnapshot = await getValidEmailAddressSnapshot(email);
    List<DocumentSnapshot> list = emailSnapshot.documents;
    if (list == null || list.isEmpty) {
      print(DB_ERROR_MSG + ": " +
          NO_EMAIL_ADDRESS_MSG);
      return null;
    }
    return ValidEmailAddress.fromSnapshot(list[0]);
  }

  Future<QuerySnapshot> getValidEmailAddressSnapshot(String email) async {
    QuerySnapshot emailSnapshot = await _database
        .collection("ValidEmailAdresses").where("email", isEqualTo: email).getDocuments();
    return emailSnapshot;
  }


  Future<void> updateAddressFromData(String email, bool isInitialized, bool isValidated) async {
    QuerySnapshot emailSnapshot = await getValidEmailAddressSnapshot(email);
    List<DocumentSnapshot> list = emailSnapshot.documents;
    if (list == null || list.isEmpty) {
      print(DB_ERROR_MSG + ": " +
          NO_EMAIL_ADDRESS_MSG);
      return null;
    }
    DocumentReference dr = _database.collection("ValidEmailAdresses").document(list[0].documentID);
    _database.runTransaction((transaction) async {
      await transaction.update(dr, {"isInitialized" : isInitialized });
      await transaction.update(dr, {"isValidated" : isValidated });
    }).catchError((e) {
      print(DB_ERROR_MSG + e.message);
    });
  }
}
