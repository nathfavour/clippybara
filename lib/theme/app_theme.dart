import 'package:flutter/material.dart';

class AppTheme {
  static const Color aquamarine = Color(0xFF7FFFD4);
  static const Color darkTextColor = Color(0xFF333333);
  static const Color lightTextColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: aquamarine,
    colorScheme: ColorScheme.light(
      primary: aquamarine,
      secondary: Colors.teal,
      surface: Colors.white,
      background: Colors.grey[50]!,
      onPrimary: lightTextColor,
      onSecondary: lightTextColor,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: aquamarine,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: lightTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: aquamarine,
        foregroundColor: lightTextColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(aquamarine),
      trackColor: MaterialStateProperty.all(aquamarine.withOpacity(0.5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: aquamarine,
      foregroundColor: lightTextColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: darkTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: darkTextColor),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: darkTextColor),
      titleMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: darkTextColor),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: aquamarine,
    colorScheme: ColorScheme.dark(
      primary: aquamarine,
      secondary: Colors.tealAccent,
      surface: Colors.grey[800]!,
      background: Colors.grey[900]!,
      onPrimary: darkTextColor,
      onSecondary: darkTextColor,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: aquamarine,
      elevation: 0,
      titleTextStyle: const TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: darkTextColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: aquamarine,
        foregroundColor: darkTextColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(aquamarine),
      trackColor: MaterialStateProperty.all(aquamarine.withOpacity(0.5)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: aquamarine,
      foregroundColor: darkTextColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: lightTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: lightTextColor),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: lightTextColor),
      titleMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: lightTextColor),
    ),
  );
}
