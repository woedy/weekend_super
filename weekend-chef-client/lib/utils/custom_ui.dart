import 'package:flutter/material.dart';

class FlutterFlowTheme {
  // Define your custom theme properties
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color primaryText;
  final Color secondaryText;
  final TextStyle bodyMedium;  // Add this property for bodyMedium

  // Constructor to initialize the theme properties
  FlutterFlowTheme({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.bodyMedium,  // Initialize bodyMedium
  });

  // Add methods to get your theme properties
  static FlutterFlowTheme of(BuildContext context) {
    final themeData = Theme.of(context);

    return FlutterFlowTheme(
      primaryBackground: themeData.primaryColor,
      secondaryBackground: Colors.white,
      primaryText: Colors.black,
      secondaryText: Colors.grey,
      bodyMedium: themeData.textTheme.bodyMedium ?? TextStyle(),  // Fetch bodyMedium from Flutter's theme
    );
  }
}
