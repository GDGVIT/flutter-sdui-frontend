import 'package:flutter/material.dart';

class ExportPane extends StatelessWidget {
  const ExportPane({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export',
            style: TextStyle(
              color: Color(0xFFEDF1EE),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Export functionality will be displayed here',
            style: TextStyle(color: Color(0xFFEDF1EE)),
          ),
        ],
      ),
    );
  }
} 