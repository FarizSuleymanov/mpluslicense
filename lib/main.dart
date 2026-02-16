import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mpluslicense/pages/login.dart';
import 'package:mpluslicense/pages/main/mainpage.dart';
import 'package:mpluslicense/theme/styles.dart';

void main() {
  runApp(MaterialApp(
    scrollBehavior: MyCustomScrollBehavior(),
    title: 'M+ License',
    theme: ThemeData(
        fontFamily: 'poppins_regular',
        appBarTheme:
            AppBarTheme(backgroundColor: Styles.scaffoldBackgroundColorMode),
        scaffoldBackgroundColor: Styles.scaffoldBackgroundColorMode,
        scrollbarTheme: Styles.scrollbarTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Styles.defaultWidgetForeColor,
        )),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Styles.defaultWidgetForeColor,
        ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: Styles.defaultWidgetForeColor,
            surface: Colors.white,
            primary: Styles.defaultWidgetForeColor)),
    initialRoute: '/login',
    routes: {
      '/login': (context) => const Login(),
      '/main': (context) => const MainPage(),
    },
  ));
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
