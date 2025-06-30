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

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter_sdui/src/parser/sdui_proto_parser.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Load the example JSON file
//   final file = File('../flutter-sdui-package/example/sample_sdui.json');
//   final jsonString = await file.readAsString();
//   final Map<String, dynamic> jsonData = json.decode(jsonString);

//   // Parse the JSON into an SDUI widget
//   final sduiWidget = SduiParser.parseJSON(jsonData);

//   // Convert to Flutter widget
//   final widget = sduiWidget.toFlutterWidget();

//   runApp(MaterialApp(
//     home: widget,
//   ));
// }

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sample SDUI App',
//       theme: ThemeData.dark(),
//       debugShowCheckedModeBanner: false,
//       home: const SampleSduiScreen(),
//     );
//   }
// }

// class SampleSduiScreen extends StatelessWidget {
//   const SampleSduiScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Padding(
//           padding: const EdgeInsets.all(16),
//           child: const Text(
//             'Sample SDUI App',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         automaticallyImplyLeading: false,
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         elevation: 0,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: const [
//           Text(
//             'Welcome to Server-Driven UI!',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 24),
//           Image(
//             image: NetworkImage('https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png'),
//             width: 120,
//             height: 120,
//             fit: BoxFit.contain,
//           ),
//         ],
//       ),
//     );
//   }
// }
