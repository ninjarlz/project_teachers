import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/entities/valid_email_address.dart';


class ValidEmailAddressRepository {

  ValidEmailAddressRepository._privateConstructor();

  static const String DB_ERROR_MSG = "An error with database occured: ";
  static const String TRANSACTION_NOT_COMMITED_MSG = "Transaction not committed";
  static const String NO_OR_Validated_EMAIL_ADDRESS_MSG = "There is no such email address or it is already Validated";

  static ValidEmailAddressRepository _instance;
  static ValidEmailAddressRepository get instance {
    if (_instance == null) {
      _instance = ValidEmailAddressRepository._privateConstructor();
      _instance._database = FirebaseDatabase.instance;
    }
    return _instance;
  }

  FirebaseDatabase _database;


  Future<List<ValidEmailAddress>> getNotValidatedEmailAddresses() async {
      DataSnapshot emailSnapshot = await _database.reference()
          .child("ValidEmailAdresses").once();
      List<ValidEmailAddress> notValidatedValidEmails = List<ValidEmailAddress>();
      emailSnapshot.value.forEach((element) {
          ValidEmailAddress validEmailAddress = ValidEmailAddress.fromJson(element);
          print(element);
          if (!validEmailAddress.isValidated) {
            notValidatedValidEmails.add(validEmailAddress);
          }
      });
      return notValidatedValidEmails;
  }

  Future<List<ValidEmailAddress>> getEmailAddresses() async {
    DataSnapshot emailSnapshot = await _database.reference()
        .child("ValidEmailAdresses").once();
    List<ValidEmailAddress> validEmails = List<ValidEmailAddress>();
    emailSnapshot.value.forEach((element) {
      ValidEmailAddress validEmailAddress = ValidEmailAddress.fromJson(element);
      print(element);
      validEmails.add(validEmailAddress);
    });
    return validEmails;
  }

  Future<bool> checkIfAddressIsValid(String email) async {
    List<ValidEmailAddress> notValidatedValidEmails =
    await getNotValidatedEmailAddresses();
    notValidatedValidEmails.forEach((element) {print(element.email);});
    for (ValidEmailAddress validEmailAddress in notValidatedValidEmails) {
      if (validEmailAddress.email == email) {
        return true;
      }
    }
    return false;
  }

  Future<void> markAddressAsValidated(String email) async {
    List<ValidEmailAddress> notValidatedValidEmails =
    await getNotValidatedEmailAddresses();
    for (int index = 0; index < notValidatedValidEmails.length; index++) {
      if (notValidatedValidEmails[index].email == email) {
        TransactionResult transactionResult =
        await _database.reference().child("ValidEmailAdresses")
            .child(index.toString()).child("isValidated")
            .runTransaction((mutableData) async {
          mutableData.value = true;
          return mutableData;
        });
        if (!transactionResult.committed) {
          print(TRANSACTION_NOT_COMMITED_MSG);
          if (transactionResult.error != null) {
            print(DB_ERROR_MSG + transactionResult.error.message);
          }
        }
        return;
      }
    }
    print(TRANSACTION_NOT_COMMITED_MSG + ": " + NO_OR_Validated_EMAIL_ADDRESS_MSG);
  }

  Future<UserType> getUserType(String email) async {
    List<ValidEmailAddress> notValidatedValidEmails =
    await getEmailAddresses();
    for (ValidEmailAddress validEmailAddress in notValidatedValidEmails) {
      if (validEmailAddress.email == email) {
        return validEmailAddress.userType;
      }
    }
    return null;
  }



}
