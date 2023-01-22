import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      backgroundColor: Colors.white,
      bottomAppBarColor: Colors.white,
      buttonColor: const Color(0xFF3345A9),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: const Color(0xFF3345A9),
      ),
      // primarySwatch: Colors.pink,
      primaryColor: const Color(0xFF3345A9),
      accentColor: Colors.pink,
      hintColor: Colors.grey[700],
      highlightColor: Colors.grey[700],
      disabledColor: Colors.grey[400],
      toggleableActiveColor: const Color(0xFF3345A9),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
          elevation: 1,
          color: Colors.transparent,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(
            headline2: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.bold,
                color: Colors.black),
            headline6: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.bold,
                color: Colors.black),
            subtitle2: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.bold,
                color: Colors.black),
          )),
      iconTheme: IconThemeData(color: Colors.grey[400]),
      textTheme: TextTheme(
        headline1: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black),
        headline2: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black),
        headline3: TextStyle(
            fontSize: 13.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w200,
            color: Colors.grey[400]),
        headline4: TextStyle(
            fontSize: 12.0,
            fontFamily: 'Noto Sans',
            fontStyle: FontStyle.normal,
            color: Colors.grey[600]),
        headline5: TextStyle(
            fontSize: 15.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white),
        headline6: TextStyle(
            fontSize: 16.0,
            fontStyle: FontStyle.normal,
            color: Colors.grey[700]),
        subtitle1: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.normal,
            color: Colors.grey[500]),
        subtitle2: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black),
        bodyText1: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.normal,
            color: Colors.grey[600]),
        bodyText2: TextStyle(
            fontSize: 15.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w600,
            color: Colors.black),
        button: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3345A9)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3345A9),
          unselectedItemColor: Colors.grey[400]));
  static final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1c1c28),
      cardColor: const Color(0xFF28293d),
      backgroundColor: const Color(0xFF1c1c28),
      bottomAppBarColor: const Color(0xFF1c1c28),
      buttonColor: Colors.cyan,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.cyan[700],
      ),
      // primarySwatch: Colors.pink,
      primaryColor: Colors.cyan,
      accentColor: Colors.yellow,
      hintColor: Colors.grey[300],
      highlightColor: Colors.grey[400],
      disabledColor: Colors.grey[300],
      toggleableActiveColor: Colors.cyan,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
          elevation: 1,
          color: Colors.transparent,
          brightness: Brightness.dark,
          iconTheme: IconThemeData(color: Colors.white),
          textTheme: TextTheme(
            headline2: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.bold,
                color: Colors.white),
            headline6: TextStyle(
                fontSize: 16.0,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.bold,
                color: Colors.white),
            subtitle2: TextStyle(
                fontSize: 14.0,
                fontFamily: 'Noto Sans',
                fontWeight: FontWeight.bold,
                color: Colors.white),
          )),
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: TextTheme(
        headline1: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white),
        headline2: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white),
        headline3: TextStyle(
            fontSize: 13.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w200,
            color: Colors.white),
        headline4: TextStyle(
            fontSize: 12.0,
            fontFamily: 'Noto Sans',
            fontStyle: FontStyle.normal,
            color: Colors.grey[200]),
        headline5: TextStyle(
            fontSize: 15.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white),
        headline6: TextStyle(
            fontSize: 16.0,
            fontStyle: FontStyle.normal,
            color: Colors.grey[300]),
        subtitle1: TextStyle(
            fontSize: 20.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.normal,
            color: Colors.white),
        subtitle2: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.white),
        bodyText1: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.normal,
            color: Colors.white),
        bodyText2: TextStyle(
            fontSize: 15.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w600,
            color: Colors.white),
        button: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
            color: Colors.cyan),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF1c1c28),
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.grey[300]));
}
