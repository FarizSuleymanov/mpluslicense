import 'package:flutter/material.dart';

class Styles {
  static Color scaffoldBackgroundColorMode = const Color(0xffB4DADA);
  static Color defaultWidgetForeColor = const Color(0xff00C0C0);
  static Color defaultWidgetBackColorMode = const Color(0xfffdfdfd);
  static Color defaultScrollColor = const Color(0xff80e1e1);
  static Color defaultBlackColor = const Color(0xff4e4a69);

  static BorderRadius defaultBorderRadius = BorderRadius.circular(20);

  static ScrollbarThemeData scrollbarTheme =
      const ScrollbarThemeData().copyWith(
    thumbColor: WidgetStateProperty.all(defaultScrollColor),
    thumbVisibility: const WidgetStatePropertyAll(true),
    interactive: true,
  );
}
