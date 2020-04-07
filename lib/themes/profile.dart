import 'package:flutter/material.dart';
import 'global.dart';

class ThemeProfile {
  BoxDecoration profileContainer = BoxDecoration(
    border: Border.all(color: ThemeGlobalColor().secondaryColorDark, width: 1),
    borderRadius: BorderRadius.circular(7),
    color: ThemeGlobalColor().containerColor,
  );
}
