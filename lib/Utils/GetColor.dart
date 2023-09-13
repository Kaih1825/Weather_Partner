import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class GetColor {
  static Color getSurface(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 6 : 98));
  }

  static Color getSurfaceDim(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 6 : 87));
  }

  static Color getSurfaceBright(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 24 : 98));
  }

  static Color getSurfaceContainerLowest(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 4 : 100));
  }

  static Color getSurfaceContainerLow(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 10 : 96));
  }

  static Color getSurfaceContainer(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 12 : 94));
  }

  static Color getSurfaceContainerHigh(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 17 : 92));
  }

  static Color getSurfaceContainerHighest(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 22 : 90));
  }

  static Color getOnSurfaceVariant(ThemeData data) {
    var darkMode = data.brightness == Brightness.dark;
    var seedColor = data.colorScheme.primary;
    CorePalette p = CorePalette.of(seedColor.value);
    return Color(p.neutral.get(darkMode ? 80 : 30));
  }
}
