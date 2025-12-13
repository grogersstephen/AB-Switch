import 'package:flutter/material.dart';

const testColor = "#49665F";

class OBSSwitchTheme {
  static TextTheme lightTextTheme = TextTheme(
      // bodySmall: GoogleFonts.openSans(
      //   fontSize: 10.0,
      //   fontWeight: FontWeight.w500,
      //   color: Colors.black,
      // ),
      // bodyMedium: GoogleFonts.openSans(
      //   fontSize: 12.0,
      //   fontWeight: FontWeight.w500,
      //   color: Colors.black,
      // ),
      // bodyLarge: GoogleFonts.openSans(
      //   fontSize: 14.0,
      //   fontWeight: FontWeight.w700,
      //   color: Colors.black,
      // ),
      // displayLarge: GoogleFonts.openSans(
      //   fontSize: 32.0,
      //   fontWeight: FontWeight.bold,
      //   color: Colors.black,
      // ),
      // displayMedium: GoogleFonts.openSans(
      //   fontSize: 21.0,
      //   fontWeight: FontWeight.w700,
      //   color: Colors.black,
      // ),
      // displaySmall: GoogleFonts.openSans(
      //   fontSize: 16.0,
      //   fontWeight: FontWeight.w600,
      //   color: Colors.black,
      // ),
      );

  static TextTheme darkTextTheme = TextTheme(
      // bodySmall: GoogleFonts.openSans(
      //   fontSize: 10.0,
      //   fontWeight: FontWeight.w500,
      //   color: Colors.white,
      // ),
      // bodyMedium: GoogleFonts.openSans(
      //   fontSize: 12.0,
      //   fontWeight: FontWeight.w500,
      //   color: Colors.white,
      // ),
      // bodyLarge: GoogleFonts.openSans(
      //   fontSize: 14.0,
      //   fontWeight: FontWeight.w600,
      //   color: Colors.white,
      // ),
      // displayLarge: GoogleFonts.openSans(
      //   fontSize: 32.0,
      //   fontWeight: FontWeight.bold,
      //   color: Colors.white,
      // ),
      // displayMedium: GoogleFonts.openSans(
      //   fontSize: 21.0,
      //   fontWeight: FontWeight.w700,
      //   color: Colors.white,
      // ),
      // displaySmall: GoogleFonts.openSans(
      //   fontSize: 16.0,
      //   fontWeight: FontWeight.w600,
      //   color: Colors.white,
      // ),
      );

  static ThemeData light() {
    return ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        textTheme: lightTextTheme);
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        actionsIconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF49665F),
      ),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF7BFFE0),
        onPrimary: Colors.black,
        shadow: Colors.black,
        outline: Color(0xff69807A), // Outline
        scrim: Colors.black.withAlpha(22),
        // secondary: Color.fromRGBO(135, 153, 149, 255),
        secondary: Color(0xffFFB37A), // Warning Color
        // secondary: Colors.white,
        onSecondary: Colors.white,
        // surface: Color(0xFF879995),
        surface: Color(0xFF1B332D),
        // surface: Color(0xFF49665F),
        onSurface: Colors.white,
        inverseSurface: Color(0xff69807A),
        onInverseSurface: Colors.white,
        tertiary: Color(0xFF49665F), // Success Color
        onTertiary: Colors.white,
        error: Color(0xffFF847A), // Error color
        brightness: Brightness.dark,

        // TODO where do the dim colors get used?
        // surfaceDim:Colors.red
      ),
      inputDecorationTheme: InputDecorationTheme(
          // enabledBorder: OutlineInputBorder(
          // borderSide: BorderSide(color: Colors.green, width: 1.0),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.blue, width: 2.0),
          // ),
          ),
      // outlinedButtonTheme: OutlinedButtonThemeData(
      //   style: OutlinedButton.styleFrom(
      //     side: BorderSide(color: Colors.purple, width: 2.0),
      //   ),
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(),
      ),
      dividerColor: Colors.purple,
      textTheme: darkTextTheme,
    );
  }
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
