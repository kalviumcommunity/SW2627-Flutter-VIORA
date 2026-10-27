import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Brand display title "MAISON"
  static TextStyle brandTitle({double fontSize = 42, FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 2.2,
      color: AppColors.textPrimary,
      fontStyle: FontStyle.normal,
    );
  }

  /// Editorial serif title ("Find Your Nearest Salon", "Welcome")
  static TextStyle editorialTitle({double fontSize = 30, FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
      height: 1.25,
    );
  }

  /// Wide letter-spaced uppercase subtitle ("EXCLUSIVE SALON MEMBER ACCESS", "YOUR BEAUTY, PERFECTED")
  static TextStyle uppercaseSubtitle({double fontSize = 12, double letterSpacing = 2.4}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: letterSpacing,
      color: AppColors.textSecondary,
    );
  }

  /// Form field label ("EMAIL ADDRESS", "PASSWORD")
  static TextStyle fieldLabel = GoogleFonts.inter(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.9,
    color: const Color(0xFF5A5652),
  );

  /// Standard input text style
  static TextStyle inputText = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Explanatory body text
  static TextStyle bodyText = GoogleFonts.inter(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  /// Primary button text (all-caps, bold)
  static TextStyle buttonText({Color color = Colors.white}) {
    return GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color,
    );
  }

  /// Tertiary link text
  static TextStyle linkText({bool underline = false}) {
    return GoogleFonts.inter(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: AppColors.primary,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      decorationColor: AppColors.primary,
    );
  }

  /// Social button label
  static TextStyle socialButtonText = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  /// Caption / small label text
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Compatibility getters
  static TextStyle get labelStyle => uppercaseSubtitle();
  static TextStyle get h1 => editorialTitle(fontSize: 32);
  static TextStyle get h2 => editorialTitle(fontSize: 24);
  static TextStyle get h3 => editorialTitle(fontSize: 20);
  static TextStyle get priceStyle => GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary);
  static TextStyle get bodyMedium => bodyText;
  static TextStyle get bodySmall => caption;
}