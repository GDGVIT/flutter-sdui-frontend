import 'package:flutter/material.dart';
import '../../models/widget_data.dart';

// This file will contain the PaletteDragFeedback widget/function.
// The logic will be moved from design_canvas.dart. 

Widget buildPaletteDragFeedback(WidgetData data) {
  return Material(
    color: Colors.transparent,
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      ),
      child: Icon(data.icon, color: const Color(0xFF212121), size: 32),
    ),
  );
} 