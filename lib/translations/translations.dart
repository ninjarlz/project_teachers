import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'application.dart';

class Translations {
  Translations(Locale locale, [Map<dynamic, dynamic> localizedValues]) {
    this.locale = locale;
    lang = locale.languageCode;
    _localizedValues = localizedValues;
  }

  Locale locale;
  static String lang;
  static Map<dynamic, dynamic> _localizedValues;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  String text(String key) {
    if (_localizedValues == null) return "";
    return _localizedValues[key] ?? '** $key not found';
  }

  String key(String text) {
    if (_localizedValues == null) return "";
    return _localizedValues.keys
        .firstWhere((key) => _localizedValues[key] == text, orElse: () => null);
  }

  static Future<Translations> load(Locale locale, Locale oldLocale) async {
    if (locale.languageCode != lang || _localizedValues == null) {
      String jsonContent = await rootBundle
          .loadString("locale/i18n_${locale.languageCode}.json");
      _localizedValues = json.decode(jsonContent);
    }
    Translations translations = new Translations(locale, _localizedValues);
    return translations;
  }

  get currentLanguage => locale.languageCode;
}

class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      applic.supportedLanguages.contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale, locale);

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}

class SpecificLocalizationDelegate extends LocalizationsDelegate<Translations> {
  final Locale overriddenLocale;

  const SpecificLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<Translations> load(Locale locale) =>
      Translations.load(overriddenLocale, locale);

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => true;
}
