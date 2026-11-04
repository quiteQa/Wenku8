import 'package:flutter/cupertino.dart';
import 'glass_material.dart';

Future<int?> showGlassChoices(BuildContext context, {required String title,
    required List<String> choices, int? selected}) async {
  if (NativeGlassSupport.available) {
    return NativeGlassSupport.channel.invokeMethod<int>('showChoices', {
      'title': title, 'choices': choices, 'selected': selected ?? -1,
      'dark': CupertinoTheme.brightnessOf(context) == Brightness.dark,
      'reduceMotion': MediaQuery.disableAnimationsOf(context),
    });
  }
  return showCupertinoModalPopup<int>(context: context, builder: (sheetContext) =>
    GlassSheetFrame(title: title, child: Column(mainAxisSize: MainAxisSize.min, children: [
      for (final entry in choices.indexed)
        CupertinoButton(onPressed: () => Navigator.pop(sheetContext, entry.$1), child: Row(children: [
          Expanded(child: Text(entry.$2, style: const TextStyle(fontSize: 16))),
          if (selected == entry.$1) const Icon(CupertinoIcons.check_mark, size: 18),
        ])),
    ])));
}

Future<Map<String, dynamic>?> showGlassPreferences(BuildContext context,
    {required bool dark, required bool reduceMotion}) async {
  if (NativeGlassSupport.available) {
    return NativeGlassSupport.channel.invokeMapMethod<String, dynamic>('showPreferences', {
      'dark': dark, 'reduceMotion': reduceMotion,
    });
  }
  return showCupertinoModalPopup<Map<String, dynamic>>(context: context,
    builder: (sheetContext) => _PreferencesSheet(dark: dark, reduceMotion: reduceMotion));
}

Future<Map<String, dynamic>?> showGlassReadingSettings(BuildContext context,
    {required double fontSize, required bool sepia}) async {
  if (NativeGlassSupport.available) {
    return NativeGlassSupport.channel.invokeMapMethod<String, dynamic>('showReadingSettings', {
      'fontSize': fontSize, 'sepia': sepia,
      'dark': CupertinoTheme.brightnessOf(context) == Brightness.dark,
      'reduceMotion': MediaQuery.disableAnimationsOf(context),
    });
  }
  return showCupertinoModalPopup<Map<String, dynamic>>(context: context,
    builder: (sheetContext) => _ReadingSheet(fontSize: fontSize, sepia: sepia));
}

class GlassSheetFrame extends StatelessWidget {
  const GlassSheetFrame({super.key, required this.title, required this.child, this.onDone});
  final String title;
  final Widget child;
  final VoidCallback? onDone;
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(
    padding: const EdgeInsets.all(14),
    child: ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .78),
      child: ReferenceGlass(key: const ValueKey('glass-sheet'), radius: 30,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 34, height: 4, margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: CupertinoColors.systemGrey3, borderRadius: BorderRadius.circular(3))),
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
            CupertinoButton(onPressed: onDone ?? () => Navigator.pop(context), child: Text(onDone == null ? '取消' : '完成')),
          ]),
          Flexible(child: SingleChildScrollView(child: child)),
        ]),
      ),
    ),
  ));
}

class _PreferencesSheet extends StatefulWidget {
  const _PreferencesSheet({required this.dark, required this.reduceMotion});
  final bool dark, reduceMotion;
  @override
  State<_PreferencesSheet> createState() => _PreferencesSheetState();
}
class _PreferencesSheetState extends State<_PreferencesSheet> {
  late bool dark = widget.dark, reduced = widget.reduceMotion;
  @override
  Widget build(BuildContext context) => GlassSheetFrame(title: '外观设置',
    onDone: () => Navigator.pop(context, {'dark': dark, 'reduceMotion': reduced}),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [const Expanded(child: Text('深色外观')), CupertinoSwitch(value: dark, onChanged: (v) => setState(() => dark = v))]),
      const SizedBox(height: 20),
      Row(children: [const Expanded(child: Text('减少动态效果')), CupertinoSwitch(value: reduced, onChanged: (v) => setState(() => reduced = v))]),
      const SizedBox(height: 18),
    ]));
}
class _ReadingSheet extends StatefulWidget {
  const _ReadingSheet({required this.fontSize, required this.sepia});
  final double fontSize;
  final bool sepia;
  @override
  State<_ReadingSheet> createState() => _ReadingSheetState();
}
class _ReadingSheetState extends State<_ReadingSheet> {
  late double fontSize = widget.fontSize;
  late bool sepia = widget.sepia;
  @override
  Widget build(BuildContext context) => GlassSheetFrame(title: '阅读设置',
    onDone: () => Navigator.pop(context, {'fontSize': fontSize, 'sepia': sepia}),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('字号 ${fontSize.round()}', style: const TextStyle(fontSize: 17)),
      CupertinoSlider(value: fontSize, min: 16, max: 26, divisions: 10, onChanged: (v) => setState(() => fontSize = v)),
      const SizedBox(height: 20),
      const Text('纸张', style: TextStyle(fontSize: 17)), const SizedBox(height: 12),
      CupertinoSlidingSegmentedControl<bool>(groupValue: sepia,
        children: const {false: Text('默认'), true: Text('暖色')},
        onValueChanged: (v) { if (v != null) setState(() => sepia = v); }),
      const SizedBox(height: 20),
    ]));
}

class GlassNavigationBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const GlassNavigationBar({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Size get preferredSize => const Size.fromHeight(44);
  @override
  bool shouldFullyObstruct(BuildContext context) => false;
  @override
  Widget build(BuildContext context) => ReferenceGlass(radius: 0,
    padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
    child: SizedBox(height: 44, child: Row(children: [
      CupertinoButton(padding: const EdgeInsets.symmetric(horizontal: 16),
        onPressed: () => Navigator.maybePop(context), child: const Icon(CupertinoIcons.chevron_back, size: 23)),
      Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
      trailing ?? const SizedBox(width: 55),
    ])));
}

class GlassAction extends StatelessWidget {
  const GlassAction({super.key, required this.onPressed, required this.child, this.radius = 24});
  final VoidCallback? onPressed;
  final Widget child;
  final double radius;
  @override
  Widget build(BuildContext context) => ReferenceGlass(radius: radius,
    child: CupertinoButton(onPressed: onPressed, child: child));
}
