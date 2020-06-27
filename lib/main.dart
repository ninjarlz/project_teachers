import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_teachers/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_teachers/services/managers/auth_status_manager.dart';
import 'package:project_teachers/utils/constants/restricted_constants.dart';
import 'package:provider/provider.dart';

import 'services/managers/app_state_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'Project: TEACHERS',
    options: const FirebaseOptions(
      googleAppID: RestrictedConstants.GOOGLE_APP_ID,
      apiKey: RestrictedConstants.API_KEY,
    ), // TODO: iOS config
  );
  Firestore.instance.enablePersistence(true);

  //-- Debug rendering, do not remove

  //debugPaintSizeEnabled = true;
  //debugPaintPointersEnabled = true;
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppStateManager()),
          ChangeNotifierProvider(create: (context) => AuthStatusManager()),
        ],
        child: Routes(null, app)
      )
  );
}
