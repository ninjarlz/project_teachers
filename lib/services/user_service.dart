class UserService {
  UserService._privateConstructor();

  static UserService _instance;

  static UserService get instance {
    if (_instance == null) {
      _instance = new UserService._privateConstructor();
    }
    return _instance;
  }
}