// Shelf projection and render objects adapted from the original Wenku8
// archive_wave.dart. Geometry, extraction wave, occlusion order and hit testing
// are retained; this adapter only supplies demo data and Cupertino scrolling.
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'archive_shelf_geometry.dart';
import 'glass_material.dart';

abstract final class ShelfInk {
  static const milk = Color(0xFFFEFDF8);
  static const darkMilk = Color(0xFFF6F6F6);
  static const darkRaised = Color(0xFF2D2D2D);
  static const darkRaisedHigh = Color(0xFF3A3A3A);
}
abstract interface class PaperCoverOcclusionSource {
  Path? coverOcclusion(RenderBox face);
}
class ShelfBook {
  const ShelfBook(this.title, this.author, this.code);
  final String title, author, code;
}
class ArchivePreviewShelf extends StatefulWidget {
  const ArchivePreviewShelf({super.key, required this.books,
    required this.onOpen, required this.coverBuilder});
  final List<ShelfBook> books;
  final ValueChanged<int> onOpen;
  final Widget Function(int, double, bool) coverBuilder;
  @override
  State<ArchivePreviewShelf> createState() => _ArchivePreviewShelfState();
}
class _ArchivePreviewShelfState extends State<ArchivePreviewShelf> {
  late final _WavePose pose = _WavePose(widget.books.length);
  final scroll = ScrollController();
  int active = 0;
  bool reduced = false;
  @override
  void initState() {
    super.initState();
    scroll.addListener(moved);
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
  }
  void moved() {
    if (!scroll.hasClients) return;
    pose.move(scroll.offset / pose.pitch);
    final next = pose.logicalFocus.round() % widget.books.length;
    if (next != active) {
      setState(() => active = next);
      HapticFeedback.selectionClick();
    }
  }
  void centre(int logical) {
    final target = logical * pose.pitch;
    if (reduced) {
      scroll.jumpTo(target);
    } else {
      scroll.animateTo(target, duration: const Duration(milliseconds: 380),
        curve: const Cubic(.22, 1, .36, 1));
    }
  }
  void tap(int slot) {
    if ((pose.focus - slot).abs() < .03 && !scroll.position.isScrollingNotifier.value) {
      widget.onOpen(pose.bookIndex(slot));
    } else {
      centre(pose.logicalLane(slot));
    }
  }
  @override
  void dispose() {
    scroll.removeListener(moved);
    scroll.dispose(); pose.dispose(); super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const SizedBox.shrink();
    if (reduced) {
      return SizedBox(height: 330, child: PageView.builder(
        itemCount: widget.books.length,
        onPageChanged: (index) => setState(() => active = index),
        itemBuilder: (context, index) => Center(child: GestureDetector(
          onTap: () => widget.onOpen(index),
          child: Semantics(button: true, label: widget.books[index].title,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              widget.coverBuilder(index, 128, active == index),
              const SizedBox(height: 20),
              Text(widget.books[index].title, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('${index + 1} / ${widget.books.length}', style: const TextStyle(fontSize: 12)),
            ])),
        )),
      ));
    }
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final ink = dark ? const Color(0xFFF2F2F2) : const Color(0xFF242424);
    final spineFill = dark ? ShelfInk.darkRaised : const Color(0xFFF2F0E9);
    return Column(children: [
      Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520),
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final spine = ArchiveShelfGeometry.spineFor(width);
          final cover = ArchiveShelfGeometry.coverFor(width);
          final height = ArchiveShelfGeometry.bodyHeight(cover);
          pose.configure(width, ArchiveShelfGeometry.pitchFor(width));
          return SizedBox(height: ArchiveShelfGeometry.rowHeight(cover, height),
            child: Scrollable(
              controller: scroll, axisDirection: AxisDirection.right,
              physics: const _ShelfSnapPhysics(parent: BouncingScrollPhysics()),
              viewportBuilder: (context, offset) => _ShelfRow(
                offset: offset, pose: pose, spine: spine, cover: cover,
                height: height, dark: dark,
                children: [for (var slot = 0; slot < pose.poolCount; slot++)
                  _BookVolume(
                    key: ValueKey(slot), pose: pose, index: slot, spine: spine,
                    cover: cover, height: height, dark: dark,
                    label: widget.books[pose.bookIndex(slot)].title,
                    direction: Directionality.of(context), onTap: () => tap(slot),
                    children: [
                      ExcludeSemantics(child: GestureDetector(onTap: () => tap(slot),
                        child: Container(color: spineFill,
                          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 9),
                          child: MediaQuery.withNoTextScaling(child: Column(children: [
                            FittedBox(child: Text((pose.bookIndex(slot) + 1).toString().padLeft(2, '0'),
                              style: TextStyle(fontSize: 8, color: ink))),
                            const SizedBox(height: 10),
                            Expanded(child: Center(child: FittedBox(child: Text(
                              widget.books[pose.bookIndex(slot)].title.characters.join('\n'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 9, height: 1.08, fontWeight: FontWeight.w600, color: ink),
                            )))),
                            Text('○', style: TextStyle(fontSize: 7, color: ink)),
                          ])),
                        ),
                      )),
                      ExcludeSemantics(child: GestureDetector(onTap: () => tap(slot),
                        child: Container(
                          color: dark ? const Color(0xFF242424) : ShelfInk.milk,
                          padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            Text('NO.${(pose.bookIndex(slot) + 1).toString().padLeft(3, '0')}',
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(fontSize: 8, letterSpacing: .6, color: ink)),
                            const SizedBox(height: 7),
                            Expanded(child: FittedBox(child: widget.coverBuilder(
                              pose.bookIndex(slot), cover - 20, slot == pose.focus.round()))),
                            const SizedBox(height: 5),
                            FittedBox(alignment: Alignment.centerLeft, child: Text(
                              widget.books[pose.bookIndex(slot)].code,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(fontSize: 8, letterSpacing: .5, color: ink))),
                          ]),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      )),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ReferenceGlass(radius: 23, padding: const EdgeInsets.fromLTRB(16, 11, 10, 11),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.books[active].title, style: TextStyle(fontSize: 20, height: 1.15, color: ink, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text('${widget.books[active].author} · 演示档案', style: TextStyle(fontSize: 13, color: ink.withValues(alpha: .65))),
            ])),
            GestureDetector(onTap: () => widget.onOpen(active),
              child: Semantics(button: true, label: '打开当前书籍',
                child: ReferenceGlass(radius: 23, child: SizedBox(width: 44, height: 44,
                  child: Icon(CupertinoIcons.arrow_up_right, color: ink, size: 23))))),
          ]),
        )),
      Padding(padding: const EdgeInsets.only(right: 20, top: 12),
        child: Align(alignment: Alignment.centerRight,
          child: ReferenceGlass(radius: 23, child: Row(mainAxisSize: MainAxisSize.min, children: [
            CupertinoButton(padding: EdgeInsets.zero,
              onPressed: widget.books.length > 1 ? () => centre(pose.logicalFocus.round() - 1) : null,
              child: Icon(CupertinoIcons.chevron_left, color: ink, size: 14)),
            Text('${(active + 1).toString().padLeft(2, '0')} / ${widget.books.length.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 11, letterSpacing: 1, color: ink)),
            CupertinoButton(padding: EdgeInsets.zero,
              onPressed: widget.books.length > 1 ? () => centre(pose.logicalFocus.round() + 1) : null,
              child: Icon(CupertinoIcons.chevron_right, color: ink, size: 14)),
          ])))),

    ]);
  }
}
class _ShelfSnapPhysics extends ScrollPhysics {
  const _ShelfSnapPhysics({super.parent});
  @override
  _ShelfSnapPhysics applyTo(ScrollPhysics? ancestor) => _ShelfSnapPhysics(parent: buildParent(ancestor));
  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final pitch = ArchiveShelfGeometry.pitchFor(position.viewportDimension);
    final predicted = position.pixels / pitch + (velocity / 1700).clamp(-3.0, 3.0);
    final target = predicted.round() * pitch;
    if ((target - position.pixels).abs() < .1 && velocity.abs() < 1) return null;
    return ScrollSpringSimulation(const SpringDescription(mass: 1, stiffness: 330, damping: 32),
      position.pixels, target, velocity, tolerance: toleranceFor(position));
  }
}
class _WavePose extends ChangeNotifier {
  _WavePose(this.count);
  final int count;
  final repeatFill = true;
  int revision = 0, edgeSlots = 15;
  double logicalFocus = 0, viewport = 340, pitch = ArchiveShelfGeometry.pitchFor(340);
  double get focus => count < 2 ? 0 : edgeSlots + logicalFocus % count;
  int get poolCount => count < 2 ? count : count + edgeSlots * 2;
  int bookIndex(int slot) => count < 2 ? 0 : (slot - edgeSlots) % count;
  int logicalLane(int slot) => (logicalFocus / count).floor() * count + slot - edgeSlots;
  double loadingLift(int index) => 0;
  static const depthX = ArchiveShelfGeometry.depthX, depthY = ArchiveShelfGeometry.depthY;
  static double footprint(double spine, double cover) => ArchiveShelfGeometry.footprint(spine, cover);
  static double pullDistance(double cover) => ArchiveShelfGeometry.pullDistance(cover);
  static double baseY(double cover, double height) => ArchiveShelfGeometry.baseY(cover, height);
  void configure(double width, double nextPitch) {
    if (viewport == width && pitch == nextPitch) return;
    viewport = width; pitch = nextPitch;
    final cover = ArchiveShelfGeometry.coverFor(width);
    edgeSlots = ((width / 2 + footprint(ArchiveShelfGeometry.spineFor(width), cover)
      + pullDistance(cover) * depthX) / pitch).ceil() + 2;
    revision++;
  }
  void move(double next, {bool notify = true}) {
    if (count < 2) next = 0;
    if ((logicalFocus - next).abs() < .000001) return;
    logicalFocus = next; revision++;
    if (notify) notifyListeners();
  }
  double railY(int slot) => ArchiveShelfGeometry.railY(slot - focus);
  double weight(int index) {
    final distance = (index - focus).abs();
    if (distance >= 1.48) return 0;
    final value = math.cos(distance / 1.48 * math.pi / 2);
    return value * value;
  }
}

class _ShelfRow extends MultiChildRenderObjectWidget {
  const _ShelfRow({
    required this.offset,
    required this.pose,
    required this.spine,
    required this.cover,
    required this.height,
    required this.dark,
    required super.children,
  });
  final ViewportOffset offset;
  final _WavePose pose;
  final double spine, cover, height;
  final bool dark;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      ArchiveShelfSceneRender._(offset, pose, spine, cover, height, dark);
  @override
  void updateRenderObject(
    BuildContext context,
    ArchiveShelfSceneRender renderObject,
  ) => renderObject._update(offset, pose, spine, cover, height, dark);
}

class _ShelfParentData extends ContainerBoxParentData<RenderBox> {}

/// Parallel x-separated solids have a fixed occlusion order. Sorting by lift or
/// selected index causes impossible intersections and mid-scroll order pops.
class ArchiveShelfSceneRender extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ShelfParentData>
    implements PaperCoverOcclusionSource {
  ArchiveShelfSceneRender._(
    this._scrollOffset,
    this._pose,
    this._spine,
    this._cover,
    this._height,
    this._dark,
  );
  ViewportOffset _scrollOffset;
  _WavePose _pose;
  double _spine, _cover, _height;
  bool _dark;
  final _boxes = <RenderBox>[];
  final _x = <double>[];
  final _clipLayer = LayerHandle<ClipRectLayer>();
  int debugLayoutCount = 0;

  /// Static shadow ink is shared by every translated volume in this scene.
  int debugFloorShaderBuildCount = 0;
  Path? _floorPath;
  Paint? _floorPaint;

  /// Number of visibility projections, shared by paint, touch and cover flight.
  int debugVisibilityCount = 0;
  int _visibleRevision = -1;
  List<int> _visibleSlots = const [];
  double get debugFocus => _pose.logicalFocus;
  int get debugCentreSlot => _pose.focus.round();
  int get debugPoolCount => _pose.poolCount;
  double get debugPitch => _pose.pitch;
  List<int> get debugPaintOrder => _visible;
  @override
  Path? coverOcclusion(RenderBox face) {
    RenderObject? volume = face;
    while (volume != null && volume.parent != this) {
      volume = volume.parent;
    }
    if (volume is! RenderBox) return null;
    final slot = _boxes.indexOf(volume);
    if (slot < 0) return null;
    final faceBounds = MatrixUtils.transformRect(
      face.getTransformTo(null),
      Offset.zero & face.size,
    );
    var mask = Path();
    var occluded = false;
    for (final i in _visible.where((i) => i > slot)) {
      final box = _boxes[i] as ArchiveBoxDepthRender;
      final path = box._solidPath.transform(box.getTransformTo(null).storage);
      if (!path.getBounds().overlaps(faceBounds)) continue;
      // Top and side faces have opposite winding. A mere addPath can cancel
      // overlapping foreground silhouettes and expose holes in the flight.
      mask = Path.combine(PathOperation.union, mask, path);
      occluded = true;
    }
    return occluded ? mask : null;
  }

  Rect get _viewport => Offset.zero & size;
  Offset _offset(int i) =>
      Offset(_x[i] - _pose.focus * _pose.pitch, _pose.railY(i));
  List<int> get _visible {
    if (_visibleRevision == _pose.revision) return _visibleSlots;
    _visibleRevision = _pose.revision;
    debugVisibilityCount++;
    return _visibleSlots = [
      for (var i = 0; i < _boxes.length; i++)
        if (_viewport.overlaps(_boxes[i].paintBounds.shift(_offset(i)))) i,
    ];
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ShelfParentData) {
      child.parentData = _ShelfParentData();
    }
  }

  void _update(
    ViewportOffset offset,
    _WavePose pose,
    double spine,
    double cover,
    double height,
    bool dark,
  ) {
    final geometryChanged =
        _scrollOffset != offset ||
        _pose != pose ||
        _spine != spine ||
        _cover != cover ||
        _height != height;
    final inkChanged = _dark != dark;
    final surfaceChanged = _spine != spine || _cover != cover || inkChanged;
    _scrollOffset = offset;
    if (_pose != pose) {
      if (attached) _pose.removeListener(_changed);
      _pose = pose;
      if (attached) _pose.addListener(_changed);
    }
    _spine = spine;
    _cover = cover;
    _height = height;
    _dark = dark;
    if (surfaceChanged) {
      _floorPath = null;
      _floorPaint = null;
    }
    if (geometryChanged) {
      _visibleRevision = -1;
      markNeedsLayout();
    } else if (inkChanged) {
      markNeedsPaint();
    }
  }

  void _changed() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _pose.addListener(_changed);
  }

  @override
  void detach() {
    _pose.removeListener(_changed);
    super.detach();
  }

  @override
  void performLayout() {
    _visibleRevision = -1;
    size = constraints.biggest;
    _scrollOffset.applyViewportDimension(size.width);
    // A resized viewport may correct its pixels on the first attempt. Accept
    // the new dimensions before deriving the pool's fractional lane.
    for (var attempt = 0; attempt < 3; attempt++) {
      if (_scrollOffset.applyContentDimensions(
        _pose.count < 2 || !_pose.repeatFill ? 0 : double.negativeInfinity,
        _pose.count < 2
            ? 0
            : _pose.repeatFill
            ? double.infinity
            : (_pose.count - 1) * _pose.pitch,
      )) {
        break;
      }
    }
    _pose.move(_scrollOffset.pixels / _pose.pitch, notify: false);
    _boxes.clear();
    _x.clear();
    final start =
        _pose.viewport / 2 -
        _WavePose.footprint(_spine, _cover) / 2 +
        _WavePose.pullDistance(_cover) * _WavePose.depthX;
    var child = firstChild;
    while (child != null) {
      child.layout(BoxConstraints.tight(Size(_spine + _cover, size.height)));
      _x.add(start + _boxes.length * _pose.pitch);
      _boxes.add(child);
      child = childAfter(child);
    }
    debugLayoutCount++;
  }

  void _floor(Canvas canvas, Offset offset, List<int> visible) {
    if (_floorPath == null) {
      final depth = Offset(
        _cover * _WavePose.depthX,
        _cover * _WavePose.depthY,
      );
      const tail = Offset(-10, 10);
      final front = Offset(_spine, 1.4);
      _floorPath = Path()
        ..addPolygon([
          Offset.zero,
          front,
          front + depth,
          depth,
          depth + tail,
          tail,
        ], true);
      final ink = _dark ? ShelfInk.milk : const Color(0xFF8A806B);
      _floorPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [ink.withValues(alpha: .10), ink.withValues(alpha: 0)],
        ).createShader(_floorPath!.getBounds());
      debugFloorShaderBuildCount++;
    }
    for (final i in visible) {
      final origin =
          offset +
          _offset(i) +
          Offset(0, _WavePose.baseY(_cover, _height) + _height);
      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.drawPath(_floorPath!, _floorPaint!);
      canvas.restore();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final visible = _visible;
    _clipLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      _viewport,
      (context, offset) {
        _floor(context.canvas, offset, visible);
        for (final i in visible) {
          context.paintChild(_boxes[i], offset + _offset(i));
        }
      },
      oldLayer: _clipLayer.layer,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final i in _visible.reversed) {
      if (result.addWithPaintOffset(
        offset: _offset(i),
        position: position,
        hitTest: (result, position) =>
            _boxes[i].hitTest(result, position: position),
      )) {
        return true;
      }
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final offset = _offset(_boxes.indexOf(child));
    transform.translateByDouble(offset.dx, offset.dy, 0, 1);
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) => _viewport;

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }
}

class _BookVolume extends MultiChildRenderObjectWidget {
  const _BookVolume({
    super.key,
    required this.pose,
    required this.index,
    required this.spine,
    required this.cover,
    required this.height,
    required this.dark,
    required this.label,
    required this.direction,
    required this.onTap,
    required super.children,
  });
  final _WavePose pose;
  final int index;
  final double spine, cover, height;
  final bool dark;
  final String label;
  final TextDirection direction;
  final VoidCallback onTap;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      ArchiveBoxDepthRender._(
        pose,
        index,
        spine,
        cover,
        height,
        dark,
        label,
        direction,
        onTap,
      );
  @override
  void updateRenderObject(
    BuildContext context,
    ArchiveBoxDepthRender renderObject,
  ) => renderObject._update(
    pose,
    index,
    spine,
    cover,
    height,
    dark,
    label,
    direction,
    onTap,
  );
}

class _ArchiveCapHitEntry extends BoxHitTestEntry {
  _ArchiveCapHitEntry(super.target, super.localPosition);
}

/// The top, front and projected side share exactly the same physical vertices.
class ArchiveBoxDepthRender extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, _ShelfParentData> {
  ArchiveBoxDepthRender._(
    this._pose,
    this._index,
    this._spine,
    this._cover,
    this._height,
    this._dark,
    this._label,
    this._direction,
    this._onTap,
  ) {
    _capTap = TapGestureRecognizer(debugOwner: this)
      ..onTap = () {
        _onTap();
      };
  }
  _WavePose _pose;
  int _index;
  double _spine, _cover, _height;
  bool _dark;
  String _label;
  TextDirection _direction;
  VoidCallback _onTap;
  late final TapGestureRecognizer _capTap;
  final _spineLayer = LayerHandle<TransformLayer>();
  final _coverLayer = LayerHandle<TransformLayer>();
  int debugLayoutCount = 0;

  /// Translation does not change a book's cap geometry or gradient.
  int debugTopShaderBuildCount = 0;
  Path? _capPath;
  Paint? _capFill, _capStroke;

  /// Culling, paint and accessibility reuse one exact pose per wave revision.
  int debugGeometryCount = 0;
  int _geometryRevision = -1;
  Offset _resolvedOrigin = Offset.zero;
  Matrix4? _resolvedBase, _resolvedCover;
  Path? _resolvedTop;
  double get debugOpenFraction => _pose.weight(_index);
  bool get debugSelected => _pose.focus.round() == _index;
  Matrix4 get debugTransform => _coverTransform.clone();
  Matrix4 get debugSpineTransform => _base.clone();
  double get debugFootprint => _WavePose.footprint(_spine, _cover);
  Offset get _origin {
    if (_geometryRevision != _pose.revision) {
      _geometryRevision = _pose.revision;
      debugGeometryCount++;
      _resolvedBase = null;
      _resolvedCover = null;
      _resolvedTop = null;
      _resolvedOrigin =
          ArchiveShelfGeometry.origin(_cover, _height, debugOpenFraction) +
          Offset(0, _pose.loadingLift(_index));
    }
    return _resolvedOrigin;
  }

  Matrix4 get _base {
    final origin = _origin;
    return _resolvedBase ??= Matrix4.identity()
      ..setEntry(0, 2, _WavePose.depthX)
      ..setEntry(1, 2, _WavePose.depthY)
      ..setEntry(1, 0, .10)
      ..setEntry(0, 3, origin.dx)
      ..setEntry(1, 3, origin.dy);
  }

  Matrix4 get _coverTransform {
    final origin = _origin;
    return _resolvedCover ??= Matrix4.identity()
      ..setEntry(0, 0, _WavePose.depthX)
      ..setEntry(1, 0, _WavePose.depthY)
      ..setEntry(0, 3, origin.dx + _spine)
      ..setEntry(1, 3, origin.dy + _spine * .10);
  }

  Path get _topPath {
    final origin = _origin;
    final front = Offset(_spine, _spine * .10);
    final depth = Offset(_cover * _WavePose.depthX, _cover * _WavePose.depthY);
    return _resolvedTop ??= Path()
      ..addPolygon([
        origin,
        origin + front,
        origin + front + depth,
        origin + depth,
      ], true);
  }

  Path get _solidPath {
    List<Offset> face(Matrix4 matrix, double width) => [
      for (final point in [
        Offset.zero,
        Offset(width, 0),
        Offset(width, _height),
        Offset(0, _height),
      ])
        MatrixUtils.transformPoint(matrix, point),
    ];
    return Path()
      ..addPath(_topPath, Offset.zero)
      ..addPolygon(face(_base, _spine), true)
      ..addPolygon(face(_coverTransform, _cover), true);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ShelfParentData) {
      child.parentData = _ShelfParentData();
    }
  }

  void _update(
    _WavePose pose,
    int index,
    double spine,
    double cover,
    double height,
    bool dark,
    String label,
    TextDirection direction,
    VoidCallback onTap,
  ) {
    _geometryRevision = -1;
    if (_spine != spine || _cover != cover || _dark != dark) {
      _capPath = null;
      _capFill = null;
      _capStroke = null;
    }
    if (_pose != pose) {
      if (attached) _pose.removeListener(_changed);
      _pose = pose;
      if (attached) _pose.addListener(_changed);
    }
    if (_spine != spine || _cover != cover || _height != height) {
      _spine = spine;
      _cover = cover;
      _height = height;
      markNeedsLayout();
    }
    _index = index;
    _dark = dark;
    _label = label;
    _direction = direction;
    _onTap = onTap;
    _changed();
  }

  void _changed() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _pose.addListener(_changed);
  }

  @override
  void detach() {
    _pose.removeListener(_changed);
    _spineLayer.layer = null;
    _coverLayer.layer = null;
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    firstChild!.layout(BoxConstraints.tight(Size(_spine, _height)));
    lastChild!.layout(BoxConstraints.tight(Size(_cover, _height)));
    debugLayoutCount++;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _coverLayer.layer = context.pushTransform(
      needsCompositing,
      offset,
      _coverTransform,
      (context, offset) => context.paintChild(lastChild!, offset),
      oldLayer: _coverLayer.layer,
    );
    if (_capPath == null) {
      final front = Offset(_spine, _spine * .10);
      final depth = Offset(
        _cover * _WavePose.depthX,
        _cover * _WavePose.depthY,
      );
      _capPath = Path()
        ..addPolygon([Offset.zero, front, front + depth, depth], true);
      _capFill = Paint()
        ..shader = LinearGradient(
          colors: _dark
              ? [ShelfInk.darkRaisedHigh, ShelfInk.darkRaised]
              : [const Color(0xFFE3DFD3), ShelfInk.milk],
        ).createShader(_capPath!.getBounds());
      _capStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .4
        ..color = (_dark ? ShelfInk.darkMilk : const Color(0xFF9A927F))
            .withValues(alpha: .24);
      debugTopShaderBuildCount++;
    }
    final canvas = context.canvas;
    final origin = offset + _origin;
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.drawPath(_capPath!, _capFill!);
    canvas.drawPath(_capPath!, _capStroke!);
    canvas.restore();
    _spineLayer.layer = context.pushTransform(
      needsCompositing,
      offset,
      _base,
      (context, offset) => context.paintChild(firstChild!, offset),
      oldLayer: _spineLayer.layer,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintTransform(
        transform: _base,
        position: position,
        hitTest: (result, position) =>
            firstChild!.hitTest(result, position: position),
      ) ||
      result.addWithPaintTransform(
        transform: _coverTransform,
        position: position,
        hitTest: (result, position) =>
            lastChild!.hitTest(result, position: position),
      );
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!paintBounds.contains(position)) return false;
    if (hitTestChildren(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    if (_topPath.contains(position)) {
      result.add(_ArchiveCapHitEntry(this, position));
      return true;
    }
    return false;
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    if (entry is _ArchiveCapHitEntry && event is PointerDownEvent) {
      _capTap.addPointer(event);
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) =>
      transform.multiply(child == firstChild ? _base : _coverTransform);
  @override
  Rect get paintBounds => semanticBounds.inflate(.5);
  @override
  Rect get semanticBounds {
    // Exact projected solid bounds without allocating matrices/paths for every
    // offscreen volume during each culling pass.
    final origin = _origin;
    return Rect.fromLTRB(
      origin.dx,
      origin.dy + _cover * _WavePose.depthY,
      origin.dx + debugFootprint,
      origin.dy + _height + _spine * .10,
    );
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    config.isButton = true;
    config.isSelected = debugSelected;
    config.label = _label;
    config.textDirection = _direction;
    config.onTap = _onTap;
    config.hint = debugSelected ? '中心档案，点按打开书籍' : '点按滚动到中心';
  }

  @override
  void dispose() {
    _capTap.dispose();
    _spineLayer.layer = null;
    _coverLayer.layer = null;
    super.dispose();
  }
}
