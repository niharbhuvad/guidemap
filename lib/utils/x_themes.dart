import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidemap/utils/x_colors.dart';

class XThemes {
  const XThemes._();
  static const String appFontFamily = 'Montserrat';
  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.getFont(appFontFamily).fontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: XColors.greyDark,
      onPrimary: XColors.white,
      secondary: XColors.greyNormal,
      onSecondary: XColors.greyDeep,
      error: XColors.red,
      onError: XColors.white,
      background: XColors.greyHighlight,
      onBackground: XColors.greyDark,
      surface: XColors.white,
      onSurface: XColors.greyDark,
    ),
    appBarTheme: _appBarTheme,
    navigationBarTheme: _navigationBarThemeData,
    textSelectionTheme:
        const TextSelectionThemeData(cursorColor: XColors.greyDark),
    dialogTheme: const DialogTheme(
      backgroundColor: XColors.white,
      surfaceTintColor: XColors.white,
    ),
  );

  static final NavigationBarThemeData _navigationBarThemeData =
      NavigationBarThemeData(
    elevation: 0,
    backgroundColor: XColors.greyHighlight,
    surfaceTintColor: XColors.greyHighlight,
    indicatorColor: XColors.greyDark.withOpacity(0.08),
  );

  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: XColors.greyHighlight,
    foregroundColor: XColors.greyDark,
    surfaceTintColor: XColors.greyHighlight,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 22,
      color: XColors.greyDark,
      fontWeight: FontWeight.bold,
      fontFamily: GoogleFonts.getFont(appFontFamily).fontFamily,
    ),
  );
}
