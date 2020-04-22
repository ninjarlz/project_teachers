import 'package:project_teachers/entities/user_enums.dart';
import 'package:project_teachers/entities/valid_email_address.dart';
import 'package:project_teachers/repositories/valid_email_address_repository.dart';

class ValidEmailAddressService {
  ValidEmailAddressService._privateConstructor();

  static ValidEmailAddressService _instance;

  static ValidEmailAddressService get instance {
    if (_instance == null) {
      _instance = ValidEmailAddressService._privateConstructor();
      _instance._validEmailAddressRepository =
          ValidEmailAddressRepository.instance;
    }
    return _instance;
  }

  ValidEmailAddressRepository _validEmailAddressRepository;

  Future<List<ValidEmailAddress>> getNotValidatedEmailAddresses() async {
    return await _validEmailAddressRepository.getNotValidatedEmailAddresses();
  }

  Future<ValidEmailAddress> getNotValidatedEmailAddress(String email) async {
    return await _validEmailAddressRepository
        .getNotValidatedEmailAddress(email);
  }

  Future<List<ValidEmailAddress>> getEmailAddresses() async {
    return await _validEmailAddressRepository.getEmailAddresses();
  }

  Future<bool> checkIfAddressIsValid(String email) async {
    ValidEmailAddress notValidatedValidEmail =
        await getNotValidatedEmailAddress(email);
    return notValidatedValidEmail != null;
  }

  Future<bool> checkIfAddressIsInitialized(String email) async {
    ValidEmailAddress validEmail = await getValidEmailAddress(email);
    if (validEmail == null) {
      return false;
    }
    return validEmail.isInitialized;
  }

  Future<ValidEmailAddress> getValidEmailAddress(String email) async {
    return _validEmailAddressRepository.getValidEmailAddress(email);
  }

  Future<void> markAddressAsValidated(String email) async {
    await _validEmailAddressRepository.updateAddressFromData(
        email, false, true);
  }

  Future<void> markAddressAsInitialized(String email) async {
    await _validEmailAddressRepository.updateAddressFromData(email, true, true);
  }

  Future<UserType> getUserType(String email) async {
    ValidEmailAddress validEmailAddress = await getValidEmailAddress(email);
    if (validEmailAddress != null) {
      return validEmailAddress.userType;
    }
    return null;
  }

}
