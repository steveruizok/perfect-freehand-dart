import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData createTheme({required Brightness brightness}) {
  final baseTheme = ThemeData(
    brightness: brightness,
    colorSchemeSeed: Colors.blue,
  );
  return baseTheme.copyWith(
    textTheme: GoogleFonts.recursiveTextTheme(baseTheme.textTheme),
  );
}
