import 'dart:ui';
import 'package:flutter/cupertino.dart';

/// Static, bounded glass: one clipped backdrop pass, a readable milk film,
/// and separate optical rims. No idle shimmer or full-screen blur ticker.
class ReferenceGlass extends StatelessWidget {
  const ReferenceGlass({super.key, required this.child, this.radius = 28,
    this.padding = EdgeInsets.zero, this.emphasized = false});
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool emphasized;
  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final rounding = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: rounding, boxShadow: [
        BoxShadow(color: const Color(0xFF272D43).withValues(alpha: dark ? .15 : .07),
          blurRadius: 14, offset: const Offset(0, 6)),
        BoxShadow(color: const Color(0xFFABBAE6).withValues(alpha: dark ? .04 : .12),
          blurRadius: 5, spreadRadius: 1),
      ]),
      child: ClipRRect(borderRadius: rounding,
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: CustomPaint(foregroundPainter: _GlassRim(radius, dark),
            child: DecoratedBox(decoration: BoxDecoration(
              borderRadius: rounding,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: dark
                  ? [const Color(0xB03A3D46), const Color(0xBB20232B)]
                  : [Color(emphasized ? 0xCCFFFFFF : 0x99FFFFFF), const Color(0x44F0F2F7), const Color(0xA6FFFFFF)],
                stops: dark ? null : const [0, .58, 1]),
            ), child: Padding(padding: padding, child: child)),
          ),
        ),
      ),
    );
  }
}
class _GlassRim extends CustomPainter {
  const _GlassRim(this.radius, this.dark);
  final double radius;
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(.8);
    final rim = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.35;
    paint.shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: dark ? const [Color(0x88FFFFFF), Color(0x226D86A7), Color(0x55FFFFFF)]
        : const [Color(0xFFFFFFFF), Color(0xA6AFC8F4), Color(0xDFFFFFFF), Color(0x88ECD8E4), Color(0xF0FFFFFF)],
    ).createShader(rect);
    canvas.drawRRect(rim, paint);
    paint..shader = null..strokeWidth = .65
      ..color = Color(dark ? 0x22FFFFFF : 0xDDFFFFFF);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(2.2), Radius.circular(radius - 2.2)), paint);
    final highlight = rect.deflate(4.4);
    paint..strokeWidth = 1.4..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Color(dark ? 0x18FFFFFF : 0xDFFFFFFF), const Color(0x00FFFFFF)],
    ).createShader(highlight);
    canvas.drawRRect(RRect.fromRectAndRadius(highlight, Radius.circular(radius - 4.4)), paint);
  }
  @override
  bool shouldRepaint(_GlassRim old) => radius != old.radius || dark != old.dark;
}

class PrismaticBackdrop extends CustomPainter {
  const PrismaticBackdrop({required this.dark});
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: dark ? const [Color(0xFF202229), Color(0xFF16181E), Color(0xFF24252E)]
        : const [Color(0xFFF1F2F7), Color(0xFFFAF8F5), Color(0xFFF0F2F7)],
    ).createShader(rect));
    final grid = Paint()..color = Color(dark ? 0x0CFFFFFF : 0x078A8E9C)..strokeWidth = .6;
    for (var x = 24.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 14.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Broad, low-opacity spectral reflections follow the reference's light.
    // They are static paint strokes; controls supply their own bounded blur.
    final rainbow = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: dark ? const [Color(0x003D5E83), Color(0x144C72BD), Color(0x12796B89), Color(0x005E6B83)]
        : const [Color(0x00FFFFFF), Color(0x40B8D3FF), Color(0x30FFFFFF), Color(0x3AF3D8D1), Color(0x36F7EDC5), Color(0x00FFFFFF)],
    ).createShader(rect);
    final ribbon = Paint()..shader = rainbow..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .085..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(Path()..moveTo(-size.width * .2, size.height * .08)
      ..cubicTo(size.width * .2, size.height * .55, size.width * .9, size.height * .32, size.width * 1.2, size.height * .7), ribbon);
    canvas.drawPath(Path()..moveTo(size.width * 1.12, size.height * .02)
      ..cubicTo(size.width * .65, size.height * .43, size.width * .38, size.height * .83, -size.width * .2, size.height * .94), ribbon);
    ribbon..strokeWidth = size.width * .07..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(Path()..moveTo(-40, size.height * .9)
      ..quadraticBezierTo(size.width * .4, size.height * .78, size.width * 1.1, size.height * .94), ribbon);
  }
  @override
  bool shouldRepaint(PrismaticBackdrop old) => dark != old.dark;
}
