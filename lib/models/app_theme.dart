import 'package:flutter/material.dart';

class AppTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color accentColor;
  final double borderRadius;
  final double defaultPadding;
  final String fontFamily;

  const AppTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.accentColor,
    required this.borderRadius,
    required this.defaultPadding,
    required this.fontFamily,
  });

  static const AppTheme defaultTheme = AppTheme(
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFF2196F3),
    backgroundColor: Color(0xFF2F2F2F),
    surfaceColor: Color(0xFF3F3F3F),
    textColor: Color(0xFFEDF1EE),
    accentColor: Color(0xFF9C27B0),
    borderRadius: 8.0,
    defaultPadding: 16.0,
    fontFamily: 'Roboto',
  );

  AppTheme copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    Color? accentColor,
    double? borderRadius,
    double? defaultPadding,
    String? fontFamily,
  }) {
    return AppTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      borderRadius: borderRadius ?? this.borderRadius,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'surfaceColor': surfaceColor.value,
      'textColor': textColor.value,
      'accentColor': accentColor.value,
      'borderRadius': borderRadius,
      'defaultPadding': defaultPadding,
      'fontFamily': fontFamily,
    };
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      backgroundColor: Color(json['backgroundColor']),
      surfaceColor: Color(json['surfaceColor']),
      textColor: Color(json['textColor']),
      accentColor: Color(json['accentColor']),
      borderRadius: (json['borderRadius'] as num).toDouble(),
      defaultPadding: (json['defaultPadding'] as num).toDouble(),
      fontFamily: json['fontFamily'],
    );
  }
} 