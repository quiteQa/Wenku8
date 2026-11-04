import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;

/// iOS surfaces come from UIKit, never a Dart shader, border or glow painter.
abstract final class NativeGlassSupport {
  static const channel = MethodChannel('wenku8/native-glass');
  static String captureScene = '';
  static bool available = false;
  static bool liquidGlass = false;
  static Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    try {
      final result = await channel.invokeMapMethod<String, dynamic>('capabilities');
      available = result?['native'] == true;
      captureScene = result?['captureScene'] as String? ?? '';
      liquidGlass = result?['liquidGlass'] == true;
      debugPrint('WENKU_GLASS_BACKEND ${result?['backend']}');
    } on MissingPluginException {
      // Headless widget tests have no UIKit engine. The flat surface below
      // verifies layout; native screenshots separately verify UIGlassEffect.
      available = false;
    }
  }
}

class ReferenceGlass extends StatefulWidget {
  const ReferenceGlass({super.key, required this.child, this.radius = 28,
    this.padding = EdgeInsets.zero, this.emphasized = false});
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool emphasized;
  @override
  State<ReferenceGlass> createState() => _ReferenceGlassState();
}
class _ReferenceGlassState extends State<ReferenceGlass> {
  MethodChannel? viewChannel;
  bool? lastDark;
  double? lastRadius;
  Map<String, Object> configuration(bool dark) => {'radius': widget.radius, 'dark': dark};

  void configure(int id) {
    viewChannel = MethodChannel('wenku8/native-glass/$id');
    updateNative();
  }
  void updateNative() {
    if (!mounted || viewChannel == null) return;
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    if (lastDark == dark && lastRadius == widget.radius) return;
    lastDark = dark;
    lastRadius = widget.radius;
    viewChannel!.invokeMethod<void>('configure', configuration(dark));
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateNative();
  }
  @override
  void didUpdateWidget(ReferenceGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateNative();
  }
  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Stack(fit: StackFit.passthrough, children: [
      Positioned.fill(child: IgnorePointer(child: ExcludeSemantics(
        child: NativeGlassSupport.available
          ? UiKitView(
              viewType: 'wenku8/native-glass',
              creationParams: configuration(dark),
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: configure,
              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
            )
          : DecoratedBox(decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemGroupedBackground, context),
              borderRadius: BorderRadius.circular(widget.radius),
            )),
      ))),
      Padding(padding: widget.padding, child: widget.child),
    ]);
  }
}

/// Quiet archive paper with a faint grid. All spectral ribbons are removed.
class ArchiveBackdrop extends CustomPainter {
  const ArchiveBackdrop({required this.dark});
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
      Paint()..color = Color(dark ? 0xFF191919 : 0xFFF7F5F2));
    final grid = Paint()..color = Color(dark ? 0x08FFFFFF : 0x058A8E9C)..strokeWidth = .5;
    for (var x = 24.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 14.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }
  @override
  bool shouldRepaint(ArchiveBackdrop old) => dark != old.dark;
}
