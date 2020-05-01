import 'package:project_teachers/repositories/messaging_repository.dart';

class MessagingService {
  MessagingService._privateConstructor();

  static MessagingService _instance;

  static MessagingService get instance {
    if (_instance == null) {
      _instance = MessagingService._privateConstructor();
      _instance._messagingRepository = MessagingRepository.instance;
    }
    return _instance;
  }

  MessagingRepository _messagingRepository;
}