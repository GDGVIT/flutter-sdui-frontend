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

// // import 'package:flutter/material.dart';
// // import 'dart:convert';
// // import 'dart:io';

// // import 'package:flutter_sdui/src/parser/sdui_proto_parser.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();

// //   // Load the example JSON file
// //   final file = File('../flutter-sdui-package/example/sample_sdui.json');
// //   final jsonString = await file.readAsString();
// //   final Map<String, dynamic> jsonData = json.decode(jsonString);

// //   // Parse the JSON into an SDUI widget
// //   final sduiWidget = SduiParser.parseJSON(jsonData);

// //   // Convert to Flutter widget
// //   final widget = sduiWidget.toFlutterWidget();

// //   runApp(MaterialApp(
// //     home: widget,
// //   ));
// // }

// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Sample SDUI App',
// //       theme: ThemeData.dark(),
// //       debugShowCheckedModeBanner: false,
// //       home: const SampleSduiScreen(),
// //     );
// //   }
// // }

// // class SampleSduiScreen extends StatelessWidget {
// //   const SampleSduiScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: const Text(
// //             'Sample SDUI App',
// //             style: TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //         automaticallyImplyLeading: false,
// //         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
// //         elevation: 0,
// //       ),
// //       body: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: const [
// //           Text(
// //             'Welcome to Server-Driven UI!',
// //             style: TextStyle(
// //               fontSize: 22,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           SizedBox(height: 24),
// //           Image(
// //             image: NetworkImage('https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png'),
// //             width: 120,
// //             height: 120,
// //             fit: BoxFit.contain,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // // }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_sdui/flutter_sdui.dart'; // Replace with actual import if needed

// class SduiJsonScreen extends StatelessWidget {
//   const SduiJsonScreen({super.key});

//   static const Map<String, dynamic> sduiJson = {
//     "type": "scaffold",
//     "body": {
//       "type": "column",
//       "mainAxisAlignment": "start",
//       "crossAxisAlignment": "stretch",
//       "mainAxisSize": "max",
//       "verticalDirection": "down",
//       "children": [
//         {
//           "type": "row",
//           "mainAxisAlignment": "start",
//           "crossAxisAlignment": "center",
//           "mainAxisSize": "max",
//           "verticalDirection": "down",
//           "children": [
//             {
//               "type": "row",
//               "mainAxisAlignment": "start",
//               "crossAxisAlignment": "center",
//               "mainAxisSize": "max",
//               "verticalDirection": "down",
//               "children": [
//                 {
//                   "type": "container",
//                   "decoration": {"color": "#ff681818"},
//                   "width": 230.4,
//                   "color": "#ff681818",
//                   "clipBehavior": "none"
//                 }
//               ]
//             },
//             {
//               "type": "row",
//               "mainAxisAlignment": "start",
//               "crossAxisAlignment": "end",
//               "mainAxisSize": "max",
//               "verticalDirection": "down",
//               "children": [
//                 {
//                   "type": "container",
//                   "decoration": {"color": "#ff212970"},
//                   "width": 230.4,
//                   "color": "#ff212970",
//                   "clipBehavior": "none"
//                 },
//                 {
//                   "type": "container",
//                   "decoration": {"color": "#ff378c21"},
//                   "width": 230.4,
//                   "color": "#ff378c21",
//                   "clipBehavior": "none"
//                 }
//               ]
//             }
//           ]
//         }
//       ]
//     },
//     "primary": true,
//     "extendBody": false,
//     "extendBodyBehindAppBar": false,
//     "drawerEnableOpenDragGesture": true,
//     "endDrawerEnableOpenDragGesture": true
//   };
//   @override
//   Widget build(BuildContext context) {
//     // Assume SduiParser is a class with a static method fromJson that returns a Widget
//     return SduiParser.parseJSON(sduiJson).toFlutterWidget();
//   }
// }

// void main() {
//   runApp(
//     MaterialApp(
//       home: tmp(),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }

// class tmp extends StatefulWidget {
//   const tmp({super.key});

//   @override
//   State<tmp> createState() => _tmpState();
// }

// class _tmpState extends State<tmp> {
//   @override
//   Widget build(BuildContext context) {
//     print(json.encode(SduiParser.toJson(t)));
//     return j.toFlutterWidget();
//   }
// }

// var sduiJson=json.decode('{"type":"scaffold","body":{"type":"column","children":[{"type":"row","mainAxisAlignment":"spaceBetween","children":[{"type":"row","children":[{"type":"container","width":100.0,"height":100.0,"color":"#fff44336"}]},{"type":"row","mainAxisAlignment":"end","children":[{"type":"container","width":100.0,"height":100.0,"color":"#ff2196f3"},{"type":"container","width":100.0,"height":100.0,"color":"#ff4caf50"}]}]},{"type":"container","width":100.0,"height":100.0,"color":"#ffffeb3b"}]}}');
// var j=SduiParser.parseJSON(sduiJson);

// var t= SduiScaffold(
//   body: SduiColumn(
//     children: [
//       SduiRow(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children:[SduiRow(
//         children: [
//           SduiContainer(color: Colors.red, width: 100, height: 100),
//         ],
//       ),
//       SduiRow(
//         mainAxisAlignment: MainAxisAlignment.end, 
//         children: [
//           SduiContainer(color: Colors.blue, width: 100, height: 100),
//           SduiContainer(color: Colors.green, width: 100, height: 100),
//         ],
//       )]),
//       SduiContainer(color: Colors.yellow, width: 100, height: 100),
//     ],
//   ),
// );

// // var t=Scaffold(
//     //   body: Column(
//     //     children: [
//     //       Row(
//     //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     //         children: [
//     //           Row(
//     //             children: [
//     //               Container(color: Colors.red, width: 100, height: 100),
//     //             ],
                
//     //           ),
//     //                         Row(
//     //                           mainAxisAlignment: MainAxisAlignment.end,
//     //             children: [
//     //               Container(color: Colors.blue, width: 100, height: 100),
//     //               Container(color: Colors.green, width: 100, height: 100),
//     //             ],
//     //           ),
//     //         ],
//     //       ),
//     //       Container(color: Colors.yellow,width: 100,height: 100 ),
//     //     ],
//     //   ),
//     // );