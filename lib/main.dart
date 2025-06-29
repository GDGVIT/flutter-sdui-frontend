import 'package:flutter/material.dart';
import 'views/design_canvas_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design Canvas App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF212121),
        primaryColor: const Color(0xFF2F2F2F),
      ),
      home: const DesignCanvasScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 