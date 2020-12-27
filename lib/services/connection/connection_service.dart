import 'dart:io';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class ConnectionService {

  static ConnectionService _instance;
  ConnectionService._private();
  static ConnectionService get instance {
    if (_instance == null) {
      _instance = ConnectionService._private();
      _instance._connectivity = Connectivity();
      _instance.connectionChangeController = StreamController.broadcast();
      _instance.initialize();
    }
    return _instance;
  }

  bool hasConnection = false;
  StreamController connectionChangeController;
  Connectivity _connectivity;

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;


  void dispose() {
    connectionChangeController.close();
  }

  void _connectionChange(ConnectivityResult result) {
    checkConnection();
  }

  Future<bool> checkConnection() async {
    bool previousConnection = hasConnection;
    try {
      final result = await InternetAddress.lookup('google.com');
      hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch(_) {
      hasConnection = false;
    }

    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}