import 'package:flutter/material.dart';

class FlutterFlowTheme {
  // Define your custom theme properties
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color primaryText;
  final Color secondaryText;
  
  
  // Constructor to initialize the theme properties
  FlutterFlowTheme({
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.primaryText,
    required this.secondaryText,
  });

  // Add methods to get your theme properties
  static FlutterFlowTheme of(BuildContext context) {
    // Fetch the current theme of the context (you can replace this with your own logic)
    // Here, we are using the default Flutter theme for simplicity
    final themeData = Theme.of(context);

    return FlutterFlowTheme(
      primaryBackground: themeData.primaryColor, // or any other custom colors
      secondaryBackground: Colors.white, // example, can be changed
      primaryText: Colors.black,
      secondaryText: Colors.grey,
    );
  }
}
