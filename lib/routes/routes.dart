import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_teachers/utils/index.dart';
import 'package:project_teachers/screens/index.dart';
import 'package:project_teachers/themes/index.dart';
import 'package:project_teachers/translations/translations.dart';
import 'package:project_teachers/translations/application.dart';

class Routes extends StatefulWidget {

  final Widget testWidget;
  final FirebaseApp app;

  Routes([this.testWidget, this.app]);

  @override
  State<StatefulWidget> createState() {
    return _RoutesState();
  }
}

class _RoutesState extends State<Routes> {
  SpecificLocalizationDelegate _localeOverrideDelegate;
  var routes;

  @override
  void initState() {
    super.initState();
    _localeOverrideDelegate = SpecificLocalizationDelegate(null);
    applic.onLocaleChanged = onLocaleChange;
    AuthenticationSave().getString("lang").then((response) {
      if (response != null) applic.onLocaleChanged(new Locale(response));
    });

    routes = <String, WidgetBuilder>{
      Splashscreen.routeName: (BuildContext context) => Splashscreen(),
    };
  }

  onLocaleChange(Locale locale) {
    setState(() {
      _localeOverrideDelegate = SpecificLocalizationDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'ProjectTeachers',
      routes: routes,
      initialRoute: Splashscreen.routeName,
      debugShowCheckedModeBanner: false,
      // Custom Routes
      onGenerateRoute: (RouteSettings settings) {
        final List<String> pathElements = settings.name.split("/");
        if (pathElements[0] != "") return null;
        return null;
      },
      // 404 Route
      onUnknownRoute: (RouteSettings settings) {
        return MaterialPageRoute<bool>(builder: (context) => Login());
      },
      theme: ThemeData(
        primaryTextTheme: TextTheme(title: ThemeGlobalText().appBarText),
        primaryIconTheme: Theme.of(context)
            .primaryIconTheme
            .copyWith(color: ThemeGlobalColor().mainColor),
      ),
      localizationsDelegates: [
        _localeOverrideDelegate,
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: applic.supportedLocales(),
    );
  }
}
