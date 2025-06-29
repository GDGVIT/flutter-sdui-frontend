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
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.black, width: 4),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 360,
              height: 640,
              child: Material(
                color: appTheme.backgroundColor,
                child: _buildWidget(scaffoldWidget),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidget(WidgetNode node) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double? width;
        double? height;
        final widthPercent = node.properties['widthPercent'] as double?;
        final heightPercent = node.properties['heightPercent'] as double?;
        if (widthPercent != null) {
          width = constraints.maxWidth * (widthPercent / 100);
        } else if (node.size.width > 0) {
          width = node.size.width;
        }
        if (heightPercent != null) {
          height = constraints.maxHeight * (heightPercent / 100);
        } else if (node.size.height > 0) {
          height = node.size.height;
        }
        Widget child;
        switch (node.type) {
          case 'Scaffold':
            final appBarTitle = node.properties['appBarTitle']?.toString() ?? '';
            final appBarColor = _parseColor(node.properties['appBarColor']?.toString()) ?? Colors.black;
            child = Scaffold(
              backgroundColor: _parseColor(node.properties['backgroundColor']?.toString()) ?? appTheme.backgroundColor,
              appBar: AppBar(
                title: Text(appBarTitle.isNotEmpty ? appBarTitle : 'App Bar'),
                backgroundColor: appBarColor,
              ),
              body: node.children.isNotEmpty ? _buildWidget(node.children.first) : null,
            );
            break;
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
            List<Widget> children = node.children.map(_buildWidget).toList();
            if (crossAxis == CrossAxisAlignment.stretch) {
              children = children
                  .map((c) => Expanded(child: c))
                  .toList();
            }
            Widget row = Row(
              mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']?.toString()),
              crossAxisAlignment: crossAxis,
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
            List<Widget> children = node.children.map(_buildWidget).toList();
            if (crossAxis == CrossAxisAlignment.stretch) {
              children = children
                  .map((c) => Expanded(child: c))
                  .toList();
            }
            Widget column = Column(
              mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']?.toString()),
              crossAxisAlignment: crossAxis,
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
      default: return MainAxisAlignment.start;
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