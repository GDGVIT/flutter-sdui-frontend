import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../models/app_theme.dart';

class PreviewCanvas extends StatelessWidget {
  final WidgetNode scaffoldWidget;
  final AppTheme appTheme;

  const PreviewCanvas({
    super.key,
    required this.scaffoldWidget,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Phone-like frame
    return Center(
      child: Container(
        width: 360,
        height: 640,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: appTheme.backgroundColor,
            child: _buildScaffoldPreview(scaffoldWidget),
          ),
        ),
      ),
    );
  }

  // Interpret the root as a Scaffold and render its children
  Widget _buildScaffoldPreview(WidgetNode node) {
    if (node.type != 'Scaffold') {
      return const Center(child: Text('Root must be a Scaffold'));
    }
    final appBarTitle = node.properties['appBarTitle']?.toString() ?? '';
    final appBarColor = _parseColor(node.properties['appBarColor']?.toString()) ?? Colors.black;
    final backgroundColor = _parseColor(node.properties['backgroundColor']?.toString()) ?? appTheme.backgroundColor;
    Widget? bodyWidget;
    if (node.children.isNotEmpty) {
      final firstChild = node.children.first;
      final isColOrRow = firstChild.type == 'Column Widget' || firstChild.type == 'Row Widget';
      final mainAxisSize = firstChild.properties['mainAxisSize']?.toString();
      if (isColOrRow && mainAxisSize == 'min') {
        // Render directly, let Column/Row shrink-wrap
        bodyWidget = _buildWidget(firstChild);
      } else {
        // Expand to fill available space
        bodyWidget = SizedBox.expand(child: _buildWidget(firstChild));
      }
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(appBarTitle.isNotEmpty ? appBarTitle : 'App Bar'),
        backgroundColor: appBarColor,
      ),
      body: bodyWidget,
    );
  }

  // Recursively interpret the widget tree
  Widget _buildWidget(WidgetNode node) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Only use explicit width/height if set in properties
        double? width;
        double? height;
        final widthPercent = node.properties['widthPercent'] as double?;
        final heightPercent = node.properties['heightPercent'] as double?;
        if (widthPercent != null) {
          width = constraints.maxWidth * (widthPercent / 100);
        } else if (node.properties['width'] != null) {
          width = node.properties['width'] as double?;
        }
        if (heightPercent != null) {
          height = constraints.maxHeight * (heightPercent / 100);
        } else if (node.properties['height'] != null) {
          height = node.properties['height'] as double?;
        }
        Widget child;
        switch (node.type) {
          case 'Container Widget':
            Widget? content = node.children.isNotEmpty ? _buildWidget(node.children.first) : null;
            final padding = (node.properties['padding'] as double?) ?? 0;
            if (padding > 0) {
              content = Padding(
                padding: EdgeInsets.all(padding),
                child: content,
              );
            }
            child = Container(
              width: width,
              height: height,
              color: _parseColor(node.properties['color']?.toString()) ?? appTheme.surfaceColor,
              margin: EdgeInsets.all((node.properties['margin'] as double?) ?? 0),
              child: content,
            );
            break;
          case 'Row Widget':
            final crossAxis = _parseCrossAxisAlignment(node.properties['crossAxisAlignment']?.toString());
            final mainAxis = _parseMainAxisAlignment(node.properties['mainAxisAlignment']?.toString());
            final mainAxisSize = _parseMainAxisSize(node.properties['mainAxisSize']?.toString());
            List<Widget> children = node.children.map(_buildWidget).toList();
            Widget row = Row(
              mainAxisAlignment: mainAxis,
              crossAxisAlignment: crossAxis,
              mainAxisSize: mainAxisSize,
              children: children,
            );
            final padding = (node.properties['padding'] as double?) ?? 0;
            if (padding > 0) {
              row = Padding(
                padding: EdgeInsets.all(padding),
                child: row,
              );
            }
            child = row;
            break;
          case 'Column Widget':
            final crossAxis = _parseCrossAxisAlignment(node.properties['crossAxisAlignment']?.toString());
            final mainAxis = _parseMainAxisAlignment(node.properties['mainAxisAlignment']?.toString());
            final mainAxisSize = _parseMainAxisSize(node.properties['mainAxisSize']?.toString());
            List<Widget> children = node.children.map(_buildWidget).toList();
            Widget column = Column(
              mainAxisAlignment: mainAxis,
              crossAxisAlignment: crossAxis,
              mainAxisSize: mainAxisSize,
              children: children,
            );
            final padding = (node.properties['padding'] as double?) ?? 0;
            if (padding > 0) {
              column = Padding(
                padding: EdgeInsets.all(padding),
                child: column,
              );
            }
            child = column;
            break;
          case 'Stack Widget':
            child = Stack(
              children: node.children.map(_buildWidget).toList(),
            );
            break;
          case 'Text Widget':
            child = Text(
              node.properties['text']?.toString() ?? '',
              style: TextStyle(
                color: _parseColor(node.properties['color']?.toString()) ?? appTheme.textColor,
                fontSize: (node.properties['fontSize'] as double?) ?? 16,
                fontWeight: _parseFontWeight(node.properties['fontWeight']?.toString()),
                fontFamily: node.properties['fontFamily']?.toString() ?? appTheme.fontFamily,
                letterSpacing: (node.properties['letterSpacing'] as double?) ?? 0,
                height: (node.properties['lineHeight'] as double?) ?? 1.0,
              ),
              textAlign: _parseTextAlign(node.properties['textAlign']?.toString()),
              maxLines: (node.properties['maxLines'] as int?) ?? null,
              overflow: _parseTextOverflow(node.properties['overflow']?.toString()),
            );
            break;
          case 'TextField Widget':
            child = TextField(
              decoration: InputDecoration(
                hintText: node.properties['hintText']?.toString(),
                labelText: node.properties['labelText']?.toString(),
                filled: node.properties['filled'] == true,
                fillColor: _parseColor(node.properties['fillColor']?.toString()) ?? appTheme.surfaceColor,
              ),
              obscureText: node.properties['obscureText'] == true,
              enabled: node.properties['enabled'] != false,
              maxLines: (node.properties['maxLines'] as int?) ?? 1,
            );
            break;
          default:
            child = const SizedBox();
        }
        // Only wrap in SizedBox if width/height is set
        if (width != null || height != null) {
          return SizedBox(
            width: width,
            height: height,
            child: child,
          );
        } else {
          return child;
        }
      },
    );
  }

  // --- Helpers for property parsing ---
  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0x')));
    } catch (e) {
      return null;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(String? alignment) {
    switch (alignment) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default:
        debugPrint('Unknown mainAxisAlignment: $alignment, defaulting to center');
        return MainAxisAlignment.center;
    }
  }

  MainAxisSize _parseMainAxisSize(String? size) {
    switch (size) {
      case 'min': return MainAxisSize.min;
      case 'max': return MainAxisSize.max;
      default: return MainAxisSize.max;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String? alignment) {
    switch (alignment) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return CrossAxisAlignment.center;
    }
  }

  FontWeight? _parseFontWeight(String? weight) {
    switch (weight) {
      case 'bold': return FontWeight.bold;
      case 'normal': return FontWeight.normal;
      case 'w100': return FontWeight.w100;
      case 'w200': return FontWeight.w200;
      case 'w300': return FontWeight.w300;
      case 'w400': return FontWeight.w400;
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700;
      case 'w800': return FontWeight.w800;
      case 'w900': return FontWeight.w900;
      default: return null;
    }
  }

  TextAlign? _parseTextAlign(String? align) {
    switch (align) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      default: return null;
    }
  }

  TextOverflow? _parseTextOverflow(String? overflow) {
    switch (overflow) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'visible': return TextOverflow.visible;
      default: return null;
    }
  }
} 