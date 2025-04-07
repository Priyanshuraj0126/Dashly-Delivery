import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/color_constants.dart';

/// Defines the theme for the application
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: ColorConstants.primaryColor,
      scaffoldBackgroundColor: ColorConstants.backgroundColor,
      cardColor: ColorConstants.cardColor,
      dividerColor: ColorConstants.dividerColor,
      shadowColor: ColorConstants.shadowColor,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: ColorConstants.backgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorConstants.primaryColor,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorConstants.primaryColor,
          side: const BorderSide(color: ColorConstants.primaryColor),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: ColorConstants.cardColor,
        elevation: 2,
        shadowColor: ColorConstants.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.errorColor),
        ),
        hintStyle: const TextStyle(color: ColorConstants.secondaryTextColor),
        errorStyle: const TextStyle(color: ColorConstants.errorColor),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ColorConstants.textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ColorConstants.textColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ColorConstants.textColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: ColorConstants.secondaryTextColor,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: ColorConstants.secondaryTextColor,
        ),
      ),

      // Bottom Nav Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ColorConstants.primaryColor,
        unselectedItemColor: ColorConstants.secondaryTextColor,
        selectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ColorConstants.cardColor,
        elevation: 4,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorConstants.textColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: ColorConstants.dividerColor,
        selectedColor: ColorConstants.primaryColor,
        labelStyle: const TextStyle(color: ColorConstants.textColor),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: ColorConstants.primaryColor,
        unselectedLabelColor: ColorConstants.secondaryTextColor,
        indicatorColor: ColorConstants.primaryColor,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryLightColor;
          }
          return null;
        }),
      ),

      // ProgressIndicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorConstants.primaryColor,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: ColorConstants.primaryColor,
      scaffoldBackgroundColor: ColorConstants.darkBackgroundColor,
      cardColor: ColorConstants.darkCardColor,
      dividerColor: ColorConstants.darkDividerColor,
      shadowColor: ColorConstants.darkShadowColor,

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // FAB Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorConstants.primaryColor,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ColorConstants.primaryColor,
          side: const BorderSide(color: ColorConstants.primaryColor),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: ColorConstants.darkCardColor,
        elevation: 2,
        shadowColor: ColorConstants.darkShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorConstants.darkCardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.darkDividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.darkDividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorConstants.errorColor),
        ),
        hintStyle:
            const TextStyle(color: ColorConstants.darkSecondaryTextColor),
        errorStyle: const TextStyle(color: ColorConstants.errorColor),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ColorConstants.darkTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: ColorConstants.darkTextColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ColorConstants.darkTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: ColorConstants.darkSecondaryTextColor,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: ColorConstants.darkSecondaryTextColor,
        ),
      ),

      // Bottom Nav Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: ColorConstants.primaryColor,
        unselectedItemColor: ColorConstants.darkSecondaryTextColor,
        selectedLabelStyle: TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: ColorConstants.darkCardColor,
        elevation: 4,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ColorConstants.darkTextColor,
        contentTextStyle: const TextStyle(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: ColorConstants.darkDividerColor,
        selectedColor: ColorConstants.primaryColor,
        labelStyle: const TextStyle(color: ColorConstants.darkTextColor),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: ColorConstants.primaryColor,
        unselectedLabelColor: ColorConstants.darkSecondaryTextColor,
        indicatorColor: ColorConstants.primaryColor,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryColor;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ColorConstants.primaryLightColor;
          }
          return null;
        }),
      ),

      // ProgressIndicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorConstants.primaryColor,
      ),
    );
  }
}
