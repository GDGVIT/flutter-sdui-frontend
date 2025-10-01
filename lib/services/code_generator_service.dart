import '../models/widget_node.dart';
import '../models/app_theme.dart';
import '../viewmodels/design_canvas_viewmodel.dart';

class CodeGeneratorService {
  static String generateCode(WidgetNode scaffoldWidget, AppTheme theme) {
    // If root is SDUI, output Dart code using SDUI widgets
    if (scaffoldWidget.type.startsWith('Sdui')) {
      final sduiWidget = DesignCanvasViewModel().widgetNodeToSduiWidget(scaffoldWidget);
      final buffer = StringBuffer();
      buffer.writeln("import 'package:flutter/material.dart';");
      buffer.writeln("import 'package:flutter_sdui/flutter_sdui.dart';");
      buffer.writeln('');
      buffer.writeln('class GeneratedSduiWidget extends StatelessWidget {');
      buffer.writeln('  const GeneratedSduiWidget({super.key});');
      buffer.writeln('');
      buffer.writeln('  @override');
      buffer.writeln('  Widget build(BuildContext context) {');
      buffer.writeln('    return ${_generateSduiWidgetCode(sduiWidget, 2)};');
      buffer.writeln('  }');
      buffer.writeln('}');
      return buffer.toString();
    }
    // Legacy: output Flutter widget code
    final buffer = StringBuffer();
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class GeneratedWidget extends StatelessWidget {');
    buffer.writeln('  const GeneratedWidget({super.key});');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return ${_generateWidgetCode(scaffoldWidget, 2, theme)};');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }

  static String _generateSduiWidgetCode(dynamic sduiWidget, int indent) {
    final indentStr = '  ' * indent;
    final buffer = StringBuffer();
    final type = sduiWidget.runtimeType.toString();
    switch (type) {
      case 'SduiScaffold':
        buffer.write('SduiScaffold(');
        if (sduiWidget.appBar != null) buffer.write('\n${indentStr}appBar: ${_generateSduiWidgetCode(sduiWidget.appBar, indent + 1)},');
        if (sduiWidget.backgroundColor != null) buffer.write('\n${indentStr}backgroundColor: Color(${sduiWidget.backgroundColor.value}),');
        if (sduiWidget.body != null) buffer.write('\n${indentStr}body: ${_generateSduiWidgetCode(sduiWidget.body, indent + 1)},');
        buffer.write('\n${'  ' * (indent - 1)})');
        break;
      case 'SduiColumn':
        buffer.write('SduiColumn(');
        if (sduiWidget.children != null && sduiWidget.children.isNotEmpty) {
          buffer.write('\n${indentStr}children: [');
          for (final child in sduiWidget.children) {
            buffer.write('\n${indentStr}  ${_generateSduiWidgetCode(child, indent + 2)},');
          }
          buffer.write('\n${indentStr}],');
        }
        if (sduiWidget.mainAxisAlignment != null) buffer.write('\n${indentStr}mainAxisAlignment: MainAxisAlignment.${sduiWidget.mainAxisAlignment.toString().split('.').last},');
        if (sduiWidget.crossAxisAlignment != null) buffer.write('\n${indentStr}crossAxisAlignment: CrossAxisAlignment.${sduiWidget.crossAxisAlignment.toString().split('.').last},');
        buffer.write('\n${'  ' * (indent - 1)})');
        break;
      case 'SduiRow':
        buffer.write('SduiRow(');
        if (sduiWidget.children != null && sduiWidget.children.isNotEmpty) {
          buffer.write('\n${indentStr}children: [');
          for (final child in sduiWidget.children) {
            buffer.write('\n${indentStr}  ${_generateSduiWidgetCode(child, indent + 2)},');
          }
          buffer.write('\n${indentStr}],');
        }
        if (sduiWidget.mainAxisAlignment != null) buffer.write('\n${indentStr}mainAxisAlignment: MainAxisAlignment.${sduiWidget.mainAxisAlignment.toString().split('.').last},');
        if (sduiWidget.crossAxisAlignment != null) buffer.write('\n${indentStr}crossAxisAlignment: CrossAxisAlignment.${sduiWidget.crossAxisAlignment.toString().split('.').last},');
        buffer.write('\n${'  ' * (indent - 1)})');
        break;
      case 'SduiContainer':
        buffer.write('SduiContainer(');
        if (sduiWidget.width != null) buffer.write('\n${indentStr}width: ${sduiWidget.width},');
        if (sduiWidget.height != null) buffer.write('\n${indentStr}height: ${sduiWidget.height},');
        if (sduiWidget.color != null) buffer.write('\n${indentStr}color: Color(${sduiWidget.color.value}),');
        if (sduiWidget.child != null) buffer.write('\n${indentStr}child: ${_generateSduiWidgetCode(sduiWidget.child, indent + 1)},');
        buffer.write('\n${'  ' * (indent - 1)})');
        break;
      case 'SduiText':
        buffer.write('SduiText(');
        buffer.write("'${sduiWidget.text.replaceAll("'", "\\'")}'");
        if (sduiWidget.fontSize != null) buffer.write(', fontSize: ${sduiWidget.fontSize}');
        if (sduiWidget.color != null) buffer.write(', color: Color(${sduiWidget.color.value})');
        if (sduiWidget.textAlign != null) buffer.write(', textAlign: TextAlign.${sduiWidget.textAlign.toString().split('.').last}');
        buffer.write(')');
        break;
      case 'SduiImage':
        buffer.write('SduiImage(');
        buffer.write("'${sduiWidget.src}'");
        if (sduiWidget.width != null) buffer.write(', width: ${sduiWidget.width}');
        if (sduiWidget.height != null) buffer.write(', height: ${sduiWidget.height}');
        if (sduiWidget.fit != null) buffer.write(', fit: BoxFit.${sduiWidget.fit.toString().split('.').last}');
        buffer.write(')');
        break;
      case 'SduiIcon':
        buffer.write('SduiIcon(');
        if (sduiWidget.icon != null) buffer.write('icon: ${sduiWidget.icon},');
        if (sduiWidget.size != null) buffer.write('size: ${sduiWidget.size},');
        if (sduiWidget.color != null) buffer.write('color: Color(${sduiWidget.color.value}),');
        buffer.write(')');
        break;
      case 'SduiSpacer':
        buffer.write('SduiSpacer(');
        if (sduiWidget.flex != null) buffer.write('flex: ${sduiWidget.flex},');
        buffer.write(')');
        break;
      case 'SduiSizedBox':
        buffer.write('SduiSizedBox(');
        if (sduiWidget.width != null) buffer.write('width: ${sduiWidget.width},');
        if (sduiWidget.height != null) buffer.write('height: ${sduiWidget.height},');
        if (sduiWidget.child != null) buffer.write('child: ${_generateSduiWidgetCode(sduiWidget.child, indent + 1)},');
        buffer.write(')');
        break;
      case 'SduiAppBar':
        buffer.write('SduiAppBar(');
        if (sduiWidget.title != null) buffer.write("title: '${sduiWidget.title}',");
        if (sduiWidget.backgroundColor != null) buffer.write('backgroundColor: Color(${sduiWidget.backgroundColor.value}),');
        if (sduiWidget.foregroundColor != null) buffer.write('foregroundColor: Color(${sduiWidget.foregroundColor.value}),');
        if (sduiWidget.elevation != null) buffer.write('elevation: ${sduiWidget.elevation},');
        if (sduiWidget.centerTitle != null) buffer.write('centerTitle: ${sduiWidget.centerTitle},');
        if (sduiWidget.toolbarHeight != null) buffer.write('toolbarHeight: ${sduiWidget.toolbarHeight},');
        if (sduiWidget.leadingWidth != null) buffer.write('leadingWidth: ${sduiWidget.leadingWidth},');
        if (sduiWidget.automaticallyImplyLeading != null) buffer.write('automaticallyImplyLeading: ${sduiWidget.automaticallyImplyLeading},');
        if (sduiWidget.titleSpacing != null) buffer.write('titleSpacing: ${sduiWidget.titleSpacing},');
        if (sduiWidget.toolbarOpacity != null) buffer.write('toolbarOpacity: ${sduiWidget.toolbarOpacity},');
        if (sduiWidget.bottomOpacity != null) buffer.write('bottomOpacity: ${sduiWidget.bottomOpacity},');
        buffer.write(')');
        break;
      default:
        buffer.write('Container()');
    }
    return buffer.toString();
  }

  static String _generateWidgetCode(WidgetNode node, int indent, AppTheme theme) {
    final indentStr = '  ' * indent;
    final buffer = StringBuffer();
    
    switch (node.type) {
      case 'Scaffold':
        buffer.write('Scaffold(');
        if (node.properties['backgroundColor'] != null) {
          final color = node.properties['backgroundColor'].toString();
          buffer.write('\n${indentStr}  backgroundColor: Color(${color.replaceFirst('#', '0x')}),');
        }
        if (node.children.isNotEmpty) {
          buffer.write('\n${indentStr}  body: ${_generateWidgetCode(node.children.first, indent + 1, theme)},');
        }
        buffer.write('\n$indentStr)');
        break;
        
      case 'Container Widget':
        buffer.write('Container(');
        if (node.properties['width'] != null) {
          buffer.write('\n${indentStr}  width: ${node.properties['width']},');
        }
        if (node.properties['height'] != null) {
          buffer.write('\n${indentStr}  height: ${node.properties['height']},');
        }
        if (node.properties['padding'] != null && node.properties['padding'] > 0) {
          buffer.write('\n${indentStr}  padding: EdgeInsets.all(${node.properties['padding']}),');
        }
        if (node.properties['margin'] != null && node.properties['margin'] > 0) {
          buffer.write('\n${indentStr}  margin: EdgeInsets.all(${node.properties['margin']}),');
        }
        
        final hasDecoration = node.properties['color'] != null || 
                            node.properties['borderRadius'] != null ||
                            node.properties['borderWidth'] != null;
        if (hasDecoration) {
          buffer.write('\n${indentStr}  decoration: BoxDecoration(');
          if (node.properties['color'] != null) {
            final color = node.properties['color'].toString();
            buffer.write('\n${indentStr}    color: Color(${color.replaceFirst('#', '0x')}),');
          }
          if (node.properties['borderRadius'] != null) {
            buffer.write('\n${indentStr}    borderRadius: BorderRadius.circular(${node.properties['borderRadius']}),');
          }
          if (node.properties['borderWidth'] != null && node.properties['borderWidth'] > 0) {
            final borderColor = node.properties['borderColor']?.toString() ?? '#FF666666';
            buffer.write('\n${indentStr}    border: Border.all(');
            buffer.write('\n${indentStr}      color: Color(${borderColor.replaceFirst('#', '0x')}),');
            buffer.write('\n${indentStr}      width: ${node.properties['borderWidth']},');
            buffer.write('\n${indentStr}    ),');
          }
          buffer.write('\n${indentStr}  ),');
        }
        
        if (node.children.isNotEmpty) {
          buffer.write('\n${indentStr}  child: ${_generateWidgetCode(node.children.first, indent + 1, theme)},');
        }
        buffer.write('\n$indentStr)');
        break;
        
      case 'Row Widget':
        buffer.write('Row(');
        if (node.properties['mainAxisAlignment'] != null) {
          buffer.write('\n${indentStr}  mainAxisAlignment: MainAxisAlignment.${node.properties['mainAxisAlignment']},');
        }
        if (node.properties['crossAxisAlignment'] != null) {
          buffer.write('\n${indentStr}  crossAxisAlignment: CrossAxisAlignment.${node.properties['crossAxisAlignment']},');
        }
        if (node.children.isNotEmpty) {
          buffer.write('\n${indentStr}  children: [');
          for (final child in node.children) {
            buffer.write('\n${indentStr}    ${_generateWidgetCode(child, indent + 2, theme)},');
          }
          buffer.write('\n${indentStr}  ],');
        }
        buffer.write('\n$indentStr)');
        break;
        
      case 'Column Widget':
        buffer.write('Column(');
        if (node.properties['mainAxisAlignment'] != null) {
          buffer.write('\n${indentStr}  mainAxisAlignment: MainAxisAlignment.${node.properties['mainAxisAlignment']},');
        }
        if (node.properties['crossAxisAlignment'] != null) {
          buffer.write('\n${indentStr}  crossAxisAlignment: CrossAxisAlignment.${node.properties['crossAxisAlignment']},');
        }
        if (node.children.isNotEmpty) {
          buffer.write('\n${indentStr}  children: [');
          for (final child in node.children) {
            buffer.write('\n${indentStr}    ${_generateWidgetCode(child, indent + 2, theme)},');
          }
          buffer.write('\n${indentStr}  ],');
        }
        buffer.write('\n$indentStr)');
        break;
        
      case 'Text Widget':
        final text = node.properties['text']?.toString() ?? 'Text';
        buffer.write('Text(');
        buffer.write('\n${indentStr}  \'$text\',');
        buffer.write('\n${indentStr}  style: TextStyle(');
        if (node.properties['fontSize'] != null) {
          buffer.write('\n${indentStr}    fontSize: ${node.properties['fontSize']},');
        }
        if (node.properties['color'] != null) {
          final color = node.properties['color'].toString();
          buffer.write('\n${indentStr}    color: Color(${color.replaceFirst('#', '0x')}),');
        }
        if (node.properties['fontWeight'] != null && node.properties['fontWeight'] != 'normal') {
          buffer.write('\n${indentStr}    fontWeight: FontWeight.${node.properties['fontWeight']},');
        }
        buffer.write('\n${indentStr}  ),');
        if (node.properties['textAlign'] != null && node.properties['textAlign'] != 'left') {
          buffer.write('\n${indentStr}  textAlign: TextAlign.${node.properties['textAlign']},');
        }
        buffer.write('\n$indentStr)');
        break;
        
      case 'TextField Widget':
        buffer.write('TextField(');
        buffer.write('\n${indentStr}  decoration: InputDecoration(');
        if (node.properties['hintText'] != null) {
          buffer.write('\n${indentStr}    hintText: \'${node.properties['hintText']}\',');
        }
        if (node.properties['labelText'] != null) {
          buffer.write('\n${indentStr}    labelText: \'${node.properties['labelText']}\',');
        }
        buffer.write('\n${indentStr}  ),');
        if (node.properties['obscureText'] == true) {
          buffer.write('\n${indentStr}  obscureText: true,');
        }
        if (node.properties['maxLines'] != null && node.properties['maxLines'] != 1) {
          buffer.write('\n${indentStr}  maxLines: ${(node.properties['maxLines'] as double).toInt()},');
        }
        buffer.write('\n$indentStr)');
        break;
        
      default:
        buffer.write('Container()');
    }
    
    return buffer.toString();
  }

} 