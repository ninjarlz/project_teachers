import 'package:flutter/widgets.dart';
import 'package:project_teachers/translations/translations.dart';

class TranslationMapper {
  static List<String> translateList(List<String> labels, BuildContext context) {
    return labels.map((value) {
      return Translations.of(context).text(value);
    }).toList();
  }

  static List<String> labelsFromTranslation(
      List<String> translations, BuildContext context) {
    return translations.map((translation) {
      return Translations.of(context).key(translation);
    }).toList();
  }
}
