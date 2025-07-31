import 'package:flutter/material.dart';
import 'package:flutter_sdui/flutter_sdui.dart';
import '../models/widget_node.dart';
import '../models/widget_registry.dart';

class SduiConversionService {
  static SduiWidget widgetNodeToSduiWidget(WidgetNode node) {
    final children = node.children.map(widgetNodeToSduiWidget).toList();
    switch (node.type) {
      case 'SduiColumn':
        return SduiColumn(
          children: children,
          mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']),
          mainAxisSize: _parseMainAxisSize(node.properties['mainAxisSize']),
          crossAxisAlignment: _parseCrossAxisAlignment(node.properties['crossAxisAlignment']),
          textDirection: _parseTextDirection(node.properties['textDirection']),
          verticalDirection: _parseVerticalDirection(node.properties['verticalDirection']),
          textBaseline: _parseTextBaseline(node.properties['textBaseline']),
        );
      case 'SduiRow':
        return SduiRow(
          children: children,
          mainAxisAlignment: _parseMainAxisAlignment(node.properties['mainAxisAlignment']),
          mainAxisSize: _parseMainAxisSize(node.properties['mainAxisSize']),
          crossAxisAlignment: _parseCrossAxisAlignment(node.properties['crossAxisAlignment']),
          textDirection: _parseTextDirection(node.properties['textDirection']),
          verticalDirection: _parseVerticalDirection(node.properties['verticalDirection']),
          textBaseline: _parseTextBaseline(node.properties['textBaseline']),
        );
      case 'SduiContainer':
        return SduiContainer(
          child: children.isNotEmpty ? children.first : null,
          width: _parseDouble(node.properties['width']),
          height: _parseDouble(node.properties['height']),
          color: _parseColor(node.properties['color']),
          alignment: _parseAlignment(node.properties['alignment']),
          padding: _parseEdgeInsets(node.properties['padding']),
          margin: _parseEdgeInsets(node.properties['margin']),
          decoration: _parseBoxDecoration(node.properties),
          constraints: null,
          transform: null,
          transformAlignment: null,
          clipBehavior: _parseClip(node.properties['clipBehavior']),
        );
      case 'SduiText':
        return SduiText(
          node.properties['text']?.toString() ?? '',
          fontSize: _parseDouble(node.properties['fontSize']),
          fontWeight: _parseFontWeight(node.properties['fontWeight']),
          color: _parseColor(node.properties['color']),
          textAlign: _parseTextAlign(node.properties['textAlign']),
          fontFamily: node.properties['fontFamily']?.toString(),
          letterSpacing: _parseDouble(node.properties['letterSpacing']),
          wordSpacing: _parseDouble(node.properties['wordSpacing']),
          height: _parseDouble(node.properties['height']),
          maxLines: _parseInt(node.properties['maxLines']),
          overflow: _parseTextOverflow(node.properties['overflow']),
          softWrap: node.properties['softWrap'] as bool?,
          decoration: _parseTextDecoration(node.properties['decoration']),
          textDirection: _parseTextDirection(node.properties['textDirection']),
        );
      case 'SduiImage':
        return SduiImage(
          node.properties['src']?.toString() ?? '',
          width: _parseDouble(node.properties['width']),
          height: _parseDouble(node.properties['height']),
          fit: _parseBoxFit(node.properties['fit']),
          alignment: _parseAlignment(node.properties['alignment']),
          repeat: _parseImageRepeat(node.properties['repeat']),
          color: _parseColor(node.properties['color']),
          colorBlendMode: _parseBlendMode(node.properties['colorBlendMode']),
          centerSlice: null,
          matchTextDirection: node.properties['matchTextDirection'] as bool? ?? false,
          gaplessPlayback: node.properties['gaplessPlayback'] as bool? ?? false,
          filterQuality: _parseFilterQuality(node.properties['filterQuality']),
          cacheWidth: _parseInt(node.properties['cacheWidth']),
          cacheHeight: _parseInt(node.properties['cacheHeight']),
          scale: _parseDouble(node.properties['scale']) ?? 1.0,
          semanticLabel: node.properties['semanticLabel']?.toString(),
        );
      case 'SduiIcon':
        return SduiIcon(
          icon: null,
          size: _parseDouble(node.properties['size']),
          color: _parseColor(node.properties['color']),
          semanticLabel: node.properties['semanticLabel']?.toString(),
          textDirection: _parseTextDirection(node.properties['textDirection']),
          opacity: _parseDouble(node.properties['opacity']),
          applyTextScaling: node.properties['applyTextScaling'] as bool?,
          shadows: null,
        );
      case 'SduiSpacer':
        return SduiSpacer(flex: _parseInt(node.properties['flex']) ?? 1);
      case 'SduiSizedBox':
        return SduiSizedBox(
          width: _parseDouble(node.properties['width']),
          height: _parseDouble(node.properties['height']),
          child: children.isNotEmpty ? children.first : null,
        );
      case 'SduiScaffold':
        return SduiScaffold(
          backgroundColor: _parseColor(node.properties['backgroundColor']),
          resizeToAvoidBottomInset: node.properties['resizeToAvoidBottomInset'] as bool?,
          primary: node.properties['primary'] as bool? ?? true,
          floatingActionButtonLocation: null,
          extendBody: node.properties['extendBody'] as bool? ?? false,
          extendBodyBehindAppBar: node.properties['extendBodyBehindAppBar'] as bool? ?? false,
          drawerScrimColor: _parseColor(node.properties['drawerScrimColor']),
          drawerEdgeDragWidth: _parseDouble(node.properties['drawerEdgeDragWidth']),
          drawerEnableOpenDragGesture: node.properties['drawerEnableOpenDragGesture'] as bool? ?? true,
          endDrawerEnableOpenDragGesture: node.properties['endDrawerEnableOpenDragGesture'] as bool? ?? true,
          body: children.isNotEmpty ? children.first : null,
        );
      default:
        return SduiContainer();
    }
  }

  static WidgetNode widgetNodeFromSduiWidget(dynamic sduiWidget) {
    if (sduiWidget == null) {
      throw Exception('Tried to convert a null SDUI widget');
    }
    String type = sduiWidget.runtimeType.toString();
    String label = WidgetRegistry.getLabel(type);
    IconData icon = WidgetRegistry.getIcon(type);
    Offset position = const Offset(10, 10);
    Size size = const Size(200, 100);
    List<WidgetNode> children = [];
    if (sduiWidget is SduiColumn || sduiWidget is SduiRow) {
      if (sduiWidget.children != null) {
        children = (sduiWidget.children as List)
            .where((child) => child != null)
            .map((child) => widgetNodeFromSduiWidget(child))
            .toList();
      }
    } else if (sduiWidget is SduiContainer && sduiWidget.child != null) {
      children = [widgetNodeFromSduiWidget(sduiWidget.child!)];
    } else if (sduiWidget is SduiScaffold && sduiWidget.body != null) {
      children = [widgetNodeFromSduiWidget(sduiWidget.body!)];
    } else if (sduiWidget is SduiSizedBox && sduiWidget.child != null) {
      children = [widgetNodeFromSduiWidget(sduiWidget.child!)];
    }
    Map<String, dynamic> properties = {};
    if (sduiWidget is SduiContainer) {
      if (sduiWidget.width != null) properties['width'] = sduiWidget.width;
      if (sduiWidget.height != null) properties['height'] = sduiWidget.height;
      if (sduiWidget.alignment != null) properties['alignment'] = sduiWidget.alignment.toString();
      if (sduiWidget.color != null) {
        properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      }
      if (sduiWidget.padding != null) properties['padding'] = sduiWidget.padding;
      if (sduiWidget.margin != null) properties['margin'] = sduiWidget.margin;
      if (sduiWidget.decoration != null) {
        final BoxDecoration decoration = sduiWidget.decoration!;
        if (decoration.borderRadius != null && decoration.borderRadius is BorderRadius) {
          final BorderRadius br = decoration.borderRadius as BorderRadius;
          if (br.topLeft == br.topRight && br.topLeft == br.bottomLeft && br.topLeft == br.bottomRight) {
            properties['borderRadius'] = br.topLeft.x;
          }
        }
        if (decoration.border != null && decoration.border is Border) {
          final Border border = decoration.border as Border;
          if (border.top.width == border.right.width && border.top.width == border.bottom.width && border.top.width == border.left.width) {
            properties['borderWidth'] = border.top.width;
          }
          if (border.top.color == border.right.color && border.top.color == border.bottom.color && border.top.color == border.left.color) {
            properties['borderColor'] = '#${border.top.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
          }
        }
        if (decoration.color != null) {
          properties['color'] = '#${decoration.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        }
      }
      if (sduiWidget.clipBehavior != null) properties['clipBehavior'] = sduiWidget.clipBehavior.toString();
    } else if (sduiWidget is SduiRow || sduiWidget is SduiColumn) {
      if (sduiWidget.mainAxisAlignment != null) properties['mainAxisAlignment'] = sduiWidget.mainAxisAlignment.toString().split('.').last;
      if (sduiWidget.mainAxisSize != null) properties['mainAxisSize'] = sduiWidget.mainAxisSize.toString().split('.').last;
      if (sduiWidget.crossAxisAlignment != null) properties['crossAxisAlignment'] = sduiWidget.crossAxisAlignment.toString().split('.').last;
      if (sduiWidget.textDirection != null) properties['textDirection'] = sduiWidget.textDirection.toString().split('.').last;
      if (sduiWidget.verticalDirection != null) properties['verticalDirection'] = sduiWidget.verticalDirection.toString().split('.').last;
      if (sduiWidget.textBaseline != null) properties['textBaseline'] = sduiWidget.textBaseline.toString().split('.').last;
    }
    if (sduiWidget is SduiScaffold) {
      if (sduiWidget.backgroundColor != null) {
        properties['backgroundColor'] = '#${sduiWidget.backgroundColor!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      }
      if (sduiWidget.primary != null) properties['primary'] = sduiWidget.primary;
      if (sduiWidget.extendBody != null) properties['extendBody'] = sduiWidget.extendBody;
      if (sduiWidget.extendBodyBehindAppBar != null) properties['extendBodyBehindAppBar'] = sduiWidget.extendBodyBehindAppBar;
      if (sduiWidget.drawerEnableOpenDragGesture != null) properties['drawerEnableOpenDragGesture'] = sduiWidget.drawerEnableOpenDragGesture;
      if (sduiWidget.endDrawerEnableOpenDragGesture != null) properties['endDrawerEnableOpenDragGesture'] = sduiWidget.endDrawerEnableOpenDragGesture;
    }
    if (sduiWidget is SduiText) {
      properties['text'] = sduiWidget.text;
      properties['textAlign'] = sduiWidget.textAlign?.toString();
      properties['fontFamily'] = sduiWidget.fontFamily;
      if (sduiWidget.color != null) {
        properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      }
    }
    if (sduiWidget is SduiImage) {
      if (sduiWidget.src != null) properties['src'] = sduiWidget.src;
      if (sduiWidget.width != null) properties['width'] = sduiWidget.width;
      if (sduiWidget.height != null) properties['height'] = sduiWidget.height;
      if (sduiWidget.fit != null) properties['fit'] = sduiWidget.fit.toString();
      if (sduiWidget.alignment != null) properties['alignment'] = sduiWidget.alignment.toString();
      if (sduiWidget.repeat != null) properties['repeat'] = sduiWidget.repeat.toString();
      if (sduiWidget.color != null) {
        properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      }
      if (sduiWidget.filterQuality != null) properties['filterQuality'] = sduiWidget.filterQuality.toString();
      if (sduiWidget.scale != null) properties['scale'] = sduiWidget.scale;
    }
    if (sduiWidget is SduiIcon) {
      if (sduiWidget.icon != null) properties['icon'] = sduiWidget.icon.toString();
      if (sduiWidget.size != null) properties['size'] = sduiWidget.size;
      if (sduiWidget.color != null) {
        properties['color'] = '#${sduiWidget.color!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      }
    }
    return WidgetNode(
      uid: UniqueKey().toString(),
      type: type,
      label: label,
      icon: icon,
      position: position,
      size: size,
      children: children,
      properties: properties,
    );
  }

  // --- Property parsing helpers (move all _parse* helpers here as static methods) ---
  static MainAxisAlignment? _parseMainAxisAlignment(dynamic value) {
    switch (value) {
      case 'start': return MainAxisAlignment.start;
      case 'end': return MainAxisAlignment.end;
      case 'center': return MainAxisAlignment.center;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return null;
    }
  }
  static MainAxisSize? _parseMainAxisSize(dynamic value) {
    switch (value) {
      case 'min': return MainAxisSize.min;
      case 'max': return MainAxisSize.max;
      default: return null;
    }
  }
  static CrossAxisAlignment? _parseCrossAxisAlignment(dynamic value) {
    switch (value) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'center': return CrossAxisAlignment.center;
      case 'stretch': return CrossAxisAlignment.stretch;
      case 'baseline': return CrossAxisAlignment.baseline;
      default: return null;
    }
  }
  static TextDirection? _parseTextDirection(dynamic value) {
    switch (value) {
      case 'ltr': return TextDirection.ltr;
      case 'rtl': return TextDirection.rtl;
      default: return null;
    }
  }
  static VerticalDirection? _parseVerticalDirection(dynamic value) {
    switch (value) {
      case 'down': return VerticalDirection.down;
      case 'up': return VerticalDirection.up;
      default: return null;
    }
  }
  static TextBaseline? _parseTextBaseline(dynamic value) {
    switch (value) {
      case 'alphabetic': return TextBaseline.alphabetic;
      case 'ideographic': return TextBaseline.ideographic;
      default: return null;
    }
  }
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }
  static Color? _parseColor(dynamic value) {
    if (value == null || value == '') return null;
    try {
      if (value is Color) return value;
      if (value is String && value.startsWith('#')) {
        return Color(int.parse(value.replaceFirst('#', '0x')));
      }
    } catch (_) {}
    return null;
  }
  static Alignment? _parseAlignment(dynamic value) {
    switch (value) {
      case 'topLeft': return Alignment.topLeft;
      case 'topCenter': return Alignment.topCenter;
      case 'topRight': return Alignment.topRight;
      case 'centerLeft': return Alignment.centerLeft;
      case 'center': return Alignment.center;
      case 'centerRight': return Alignment.centerRight;
      case 'bottomLeft': return Alignment.bottomLeft;
      case 'bottomCenter': return Alignment.bottomCenter;
      case 'bottomRight': return Alignment.bottomRight;
      default: return null;
    }
  }
  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is double) return EdgeInsets.all(value);
    if (value is int) return EdgeInsets.all(value.toDouble());
    return null;
  }
  static BoxDecoration? _parseBoxDecoration(Map<String, dynamic> props) {
    final color = _parseColor(props['color']);
    final borderRadius = _parseDouble(props['borderRadius']);
    final borderWidth = _parseDouble(props['borderWidth']);
    final borderColor = _parseColor(props['borderColor']);
    if (color == null && borderRadius == null && borderWidth == null) return null;
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius) : null,
      border: borderWidth != null && borderWidth > 0
          ? Border.all(color: borderColor ?? const Color(0xFF666666), width: borderWidth)
          : null,
    );
  }
  static Clip? _parseClip(dynamic value) {
    switch (value) {
      case 'none': return Clip.none;
      case 'hardEdge': return Clip.hardEdge;
      case 'antiAlias': return Clip.antiAlias;
      case 'antiAliasWithSaveLayer': return Clip.antiAliasWithSaveLayer;
      default: return null;
    }
  }
  static FontWeight? _parseFontWeight(dynamic value) {
    switch (value) {
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
  static TextAlign? _parseTextAlign(dynamic value) {
    switch (value) {
      case 'left': return TextAlign.left;
      case 'right': return TextAlign.right;
      case 'center': return TextAlign.center;
      case 'justify': return TextAlign.justify;
      default: return null;
    }
  }
  static TextOverflow? _parseTextOverflow(dynamic value) {
    switch (value) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'visible': return TextOverflow.visible;
      default: return null;
    }
  }
  static TextDecoration? _parseTextDecoration(dynamic value) {
    switch (value) {
      case 'underline': return TextDecoration.underline;
      case 'overline': return TextDecoration.overline;
      case 'lineThrough': return TextDecoration.lineThrough;
      default: return TextDecoration.none;
    }
  }
  static BoxFit? _parseBoxFit(dynamic value) {
    switch (value) {
      case 'fill': return BoxFit.fill;
      case 'contain': return BoxFit.contain;
      case 'cover': return BoxFit.cover;
      case 'fitWidth': return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      case 'scaleDown': return BoxFit.scaleDown;
      default: return null;
    }
  }
  static ImageRepeat? _parseImageRepeat(dynamic value) {
    switch (value) {
      case 'repeat': return ImageRepeat.repeat;
      case 'repeatX': return ImageRepeat.repeatX;
      case 'repeatY': return ImageRepeat.repeatY;
      case 'noRepeat': return ImageRepeat.noRepeat;
      default: return null;
    }
  }
  static BlendMode? _parseBlendMode(dynamic value) {
    if (value == null) return null;
    try {
      return BlendMode.values.firstWhere((e) => e.name == value);
    } catch (_) {}
    return null;
  }
  static FilterQuality? _parseFilterQuality(dynamic value) {
    switch (value) {
      case 'none': return FilterQuality.none;
      case 'low': return FilterQuality.low;
      case 'medium': return FilterQuality.medium;
      case 'high': return FilterQuality.high;
      default: return null;
    }
  }
} 