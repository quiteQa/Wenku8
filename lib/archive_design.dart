import 'package:flutter/material.dart';
import 'app_language.dart';

import 'archive_motion.dart';
import 'library_reflow.dart';

/// Shared neutral surfaces and geometry for the application chrome.
abstract final class ArchiveDesign {
  static const background = Color(0xFFF2F2F7);
  static const surface = Color(0xFFFFFFFF);
  static const milk = Color(0xFFFAFAFC);
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkRaised = Color(0xFF2C2C2E);
  static const darkRaisedHigh = Color(0xFF3A3A3C);
  static const darkOutline = Color(0xFF38383A);
  static const darkInk = Color(0xFFF2F2F2);
  static const darkMuted = Color(0xFFAEAEB2);
  static const darkMilk = Color(0xFFF6F6F6);
  static const panelRadius = 20.0;
  static const coverRadius = 10.0;

  /// A thin neutral milk layer, not a white opaque sheet or another blur pass.
  static Color glassTint(Brightness brightness, {required double opacity}) =>
      brightness == Brightness.dark
      // Keep white labels legible even at the user's opaque endpoint.
      ? Color.lerp(darkMilk, darkSurface, opacity.clamp(0.0, 1.0))!
      : milk;

  static TextStyle codeStyle(BuildContext context, {Color? color}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: 9,
    height: 1.35,
    letterSpacing: 1.05,
    fontWeight: FontWeight.w500,
    color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static String fileCode(int id) => 'WK-${id.toString().padLeft(5, '0')}';
}

class ArchiveMasthead extends StatelessWidget {
  const ArchiveMasthead({
    super.key,
    required this.title,
    required this.code,
    this.brand = false,
  });
  final String title;
  final String code;
  final bool brand;

  @override
  Widget build(BuildContext context) => LibraryReflowPart(
    child: Row(
      children: [
        if (brand) ...[
          ExcludeSemantics(
            child: SizedBox(
              width: 30,
              height: 34,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/branding/app-icon.png',
                    key: const ValueKey('discovery-app-icon'),
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    cacheWidth: (30 * MediaQuery.devicePixelRatioOf(context))
                        .ceil(),
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          // Keep the fixed 56 px toolbar usable with large system text, without
          // shrinking any reading content or enlarging its pinned hitbox plane.
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Keep the navigation landmark readable in the fixed toolbar.
                  AppText(
                    title,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                      shadows: [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class ArchiveCode extends StatelessWidget {
  const ArchiveCode(this.text, {super.key, this.inverse = false, this.color});
  final String text;
  final bool inverse;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = AppText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.noScaling,
      style: ArchiveDesign.codeStyle(
        context,
        color: color ?? (inverse ? scheme.surface : null),
      ),
    );
    return ExcludeSemantics(
      child: inverse
          ? ColoredBox(
              color: scheme.onSurface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: label,
              ),
            )
          : label,
    );
  }
}

class ArchiveSection extends StatelessWidget {
  const ArchiveSection({
    super.key,
    required this.title,
    required this.code,
    this.subtitle = '',
  });
  final String title;
  final String code;
  final String subtitle;

  @override
  Widget build(BuildContext context) => LibraryReflowPart(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ArchivePart(
          start: .16,
          end: .82,
          child: AppText(
            title,
            style: const TextStyle(
              fontSize: 22,
              height: 1.25,
              fontWeight: FontWeight.w700,
              letterSpacing: -.3,
            ),
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          AppText(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Compact navigation title; metadata stays with the book content.
class ArchiveRouteTitle extends StatelessWidget {
  const ArchiveRouteTitle({super.key, required this.title, required this.code});
  final String title;
  final String code;

  @override
  Widget build(BuildContext context) => AppText(
    title,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
  );
}

/// Compatibility wrapper: content panels now use a rounded surface.
class ArchiveRegistration extends StatelessWidget {
  const ArchiveRegistration({super.key, required this.child, this.inset = 0});
  final Widget child;
  final double inset;

  @override
  Widget build(BuildContext context) => child;
}

/// Keep the background quiet so that covers and floating controls carry depth.
class ArchiveBackdrop extends StatelessWidget {
  const ArchiveBackdrop({super.key, this.filmColor = ArchiveDesign.milk});
  final Color filmColor;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
