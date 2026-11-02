import 'glass_material.dart';
import 'archive_shelf_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const WenkuPreview());

class PreviewRoute<T> extends CupertinoPageRoute<T> {
  PreviewRoute({required super.builder, required this.reduced});
  final bool reduced;
  @override
  Duration get transitionDuration => reduced ? Duration.zero : const Duration(milliseconds: 360);
  @override
  Duration get reverseTransitionDuration => reduced ? Duration.zero : const Duration(milliseconds: 280);
}

// Match the shared UI changes in the parent application. This standalone entry
// has no dependency on the incomplete reader snapshot or its native plugins.
const blue = Color(0xFF0066CC);
const pageColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFF3F3F7), darkColor: Color(0xFF191B22),
);
const panelColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFDFCFA), darkColor: Color(0xFF242424),
);
const mutedColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366), darkColor: Color(0xFFAEAEB2),
);
Color resolved(BuildContext context, Color value) =>
    CupertinoDynamicColor.resolve(value, context);
Color ink(BuildContext context) => resolved(context, CupertinoColors.label);
Color muted(BuildContext context) => resolved(context, mutedColor);
Duration motion(BuildContext context, [int milliseconds = 360]) =>
    MediaQuery.disableAnimationsOf(context)
        ? Duration.zero : Duration(milliseconds: milliseconds);

class DemoBook {
  const DemoBook(this.id, this.title, this.subtitle, this.author,
      this.colors, this.genre, this.description);
  final int id;
  final String title, subtitle, author, genre, description;
  final List<Color> colors;
}

const books = [
  DemoBook(0, '风经过的地方', 'WHERE THE WIND GOES', '青禾',
    [Color(0xFF234F4C), Color(0xFF9FB7A5)], '旅行 · 日常',
    '沿着海岸线，一封没有收件人的信，带她回到记忆里的小镇。关于出发、相遇，以及慢慢找到自己的故事。'),
  DemoBook(1, '夜航星图', 'ATLAS OF THE NIGHT', '远山',
    [Color(0xFF252D52), Color(0xFF707DA2)], '幻想 · 冒险',
    '在一座没有夜晚的城市，少年收藏着关于星空的传说。某天，一幅会发光的地图出现在他的窗前。'),
  DemoBook(2, '雨停之后', 'AFTER THE RAIN', '林间',
    [Color(0xFF8D5445), Color(0xFFD8AC8C)], '青春 · 治愈',
    '一间旧书店，一只总在雨天出现的猫。平常的日子里，也藏着值得认真倾听的小小奇迹。'),
  DemoBook(3, '森林来信', 'LETTERS FROM THE WOODS', '木野',
    [Color(0xFF505D39), Color(0xFFBAC49A)], '自然 · 生活',
    '离开喧嚣，住进森林边的小屋。写给四季的十二封信，记录那些曾被匆忙忽略的美好。'),
];

const chapterTitles = ['第一章 · 风从海上来', '第二章 · 午后的书店', '第三章 · 下一站'];
const passages = [
  '清晨的海边还没有人。\n\n风从远处赶来，把路边的野草吹向同一个方向。她站在车站的屋檐下，看着手中的信封。纸张有一点泛黄，边角却被仔细抚平。\n\n“到了就慢慢走。”信上只有这么一句话。\n\n她把信收进口袋，沿着石板路向海的方向走去。阳光落在白色围墙上，一只猫从墙头探出脑袋，安静地看着她。\n\n有些旅程不需要一个确定的目的地。只要愿意迈出第一步，风就会告诉你，接下来该往哪里去。\n\n她停下脚步，听见远处传来的汽笛声。那声音很轻，像是某个许久未见的人，在温柔地喊她的名字。',
  '书店藏在巷子的尽头。\n\n门口挂着一块小木牌，上面写着：欢迎慢慢阅读。她推开门，风铃响了两声，空气里有纸张和咖啡混在一起的气味。\n\n老板从书架后探出头来，指了指窗边的位置。那里放着一把椅子，一盏灯，还有一本刚刚翻开的书。\n\n“外面的雨还要下一会儿。”\n\n她这才注意到，窗玻璃上已经落满细小的水珠。她坐下来，读完了第一页。然后是第二页。\n\n时间好像突然变得宽裕。那些原本追在身后的事情，暂时都停在了门外。',
  '第二天，她没有赶最早的那班车。\n\n她在海边坐了一会儿，看见潮水缓缓退去，露出湿润的沙滩。有人牵着狗经过，有人弯腰拾起一枚贝壳。\n\n她终于给那封信写了回信。没有长篇的解释，也没有郑重的许诺。她只写下：这里的风很好，我想再多待一天。\n\n把信投进邮筒的时候，阳光正好从云层里露出来。\n\n旅程还没有结束。但她已经知道，下一次出发的时候，自己会带着怎样的心情。\n\n她转过身，向着有光的街道走去。',
];

class WenkuPreview extends StatefulWidget {
  const WenkuPreview({super.key});
  @override
  State<WenkuPreview> createState() => _WenkuPreviewState();
}

class _WenkuPreviewState extends State<WenkuPreview> {
  bool dark = false, reduceMotion = false;
  final saved = <int>{0, 1};
  final progress = <int, int>{};
  @override
  Widget build(BuildContext context) => CupertinoApp(
    title: '文库 · 界面预览',
    debugShowCheckedModeBanner: false,
    locale: const Locale('zh', 'CN'),
    supportedLocales: const [Locale('zh', 'CN')],
    localizationsDelegates: GlobalCupertinoLocalizations.delegates,
    theme: CupertinoThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      primaryColor: dark ? const Color(0xFFF2F3F8) : const Color(0xFF18191D),
      scaffoldBackgroundColor: pageColor,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reduceMotion || MediaQuery.disableAnimationsOf(context),
      ),
      child: child!,
    ),
    home: HomePage(
      saved: saved, progress: progress, dark: dark, reduceMotion: reduceMotion,
      onDark: (value) => setState(() => dark = value),
      onMotion: (value) => setState(() => reduceMotion = value),
      onSave: (id) => setState(() {
        if (!saved.add(id)) saved.remove(id);
      }),
      onProgress: (id, chapter) => setState(() => progress[id] = chapter),
    ),
  );
}

class Press extends StatefulWidget {
  const Press({super.key, required this.child, required this.onTap, this.label});
  final Widget child;
  final VoidCallback onTap;
  final String? label;
  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true, label: widget.label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => pressed = true),
      onTapCancel: () => setState(() => pressed = false),
      onTapUp: (_) => setState(() => pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressed && !MediaQuery.disableAnimationsOf(context) ? .985 : 1,
        duration: motion(context, pressed ? 100 : 280),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: resolved(context, panelColor), borderRadius: BorderRadius.circular(8),
    ),
    child: child,
  );
}

class BookCover extends StatelessWidget {
  const BookCover(this.book, {super.key, this.width = 120, this.tag});
  final DemoBook book;
  final double width;
  final String? tag;
  @override
  Widget build(BuildContext context) {
    final cover = Semantics(
      image: true, label: '${book.title}，演示封面',
      child: SizedBox(
        width: width, height: width * 1.43,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: CustomPaint(
            painter: CoverArt(book),
            child: Padding(
              padding: EdgeInsets.all(width * .11),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WENKU / ORIGINAL', textScaler: TextScaler.noScaling,
                  style: TextStyle(color: const Color(0xDFFFFFFF),
                    fontSize: width * .052, letterSpacing: width * .008)),
                SizedBox(height: width * .16),
                Text(book.title, textScaler: TextScaler.noScaling,
                  style: TextStyle(color: CupertinoColors.white, fontSize: width * .16,
                    fontWeight: FontWeight.w600, height: 1.35)),
                SizedBox(height: width * .055),
                Text(book.subtitle, textScaler: TextScaler.noScaling,
                  style: TextStyle(color: const Color(0xCFFFFFFF),
                    fontSize: width * .048, letterSpacing: width * .005)),
                const Spacer(),
                Text('${book.author} 著', textScaler: TextScaler.noScaling,
                  style: TextStyle(color: CupertinoColors.white, fontSize: width * .065)),
              ]),
            ),
          ),
        ),
      ),
    );
    return tag == null ? cover : Hero(
      tag: tag!,
      // Scale a retained book face during flight. Reflowing the large
      // destination typography inside the small source rect causes overflow.
      flightShuttleBuilder: (context, animation, direction, from, to) =>
          FittedBox(fit: BoxFit.fill, child: cover),
      child: cover,
    );
  }
}

class CoverArt extends CustomPainter {
  CoverArt(this.book);
  final DemoBook book;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: book.colors,
    ).createShader(rect));
    final paint = Paint()..color = const Color(0x38FFFFFF);
    canvas.drawCircle(Offset(size.width * .8, size.height * .65), size.width * .32, paint);
    paint.color = const Color(0x20FFFFFF);
    for (var i = 0; i < 5; i++) {
      final y = size.height * (.64 + i * .055);
      canvas.drawPath(Path()..moveTo(0, y)
        ..quadraticBezierTo(size.width * .4, y - size.height * .12, size.width, y + size.height * .04)
        ..lineTo(size.width, size.height)..lineTo(0, size.height)..close(), paint);
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * .025, size.height),
      Paint()..color = const Color(0x28000000));
  }
  @override
  bool shouldRepaint(CoverArt oldDelegate) => oldDelegate.book.id != book.id;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.saved, required this.progress,
    required this.dark, required this.reduceMotion, required this.onDark,
    required this.onMotion, required this.onSave, required this.onProgress});
  final Set<int> saved;
  final Map<int, int> progress;
  final bool dark, reduceMotion;
  final ValueChanged<bool> onDark, onMotion;
  final ValueChanged<int> onSave;
  final void Function(int, int) onProgress;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0, presentation = 4;
  String category = '最近更新', genre = '全部题材';
  String query = '';
  bool onlyReading = false, searching = false;
  void open(DemoBook book, String tag) => Navigator.of(context).push<void>(
    PreviewRoute<void>(reduced: MediaQuery.disableAnimationsOf(context), builder: (_) => DetailPage(
      book: book, tag: tag, isSaved: widget.saved.contains(book.id),
      chapter: widget.progress[book.id] ?? 0,
      onSave: () => widget.onSave(book.id),
      onProgress: (page) => widget.onProgress(book.id, page),
    )),
  );
  void choosePresentation() => showCupertinoModalPopup<void>(
    context: context, builder: (sheetContext) => CupertinoActionSheet(
      title: const Text('书库浏览方式'),
      actions: [for (final entry in const ['立体书架 + 列表', '立体书架 + 宫格', '纯列表', '纯宫格'].indexed)
        CupertinoActionSheetAction(onPressed: () {
          setState(() => presentation = entry.$1);
          Navigator.pop(sheetContext);
        }, child: Text(entry.$2)),
      ],
      cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(sheetContext), child: const Text('取消')),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return CupertinoPageScaffold(child: Stack(children: [
      Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: PrismaticBackdrop(dark: widget.dark)))),
      Positioned.fill(child: AnimatedSwitcher(
        duration: motion(context, 320), switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation,
          child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .012), end: Offset.zero).animate(animation), child: child)),
        child: CustomScrollView(key: ValueKey(tab), physics: const BouncingScrollPhysics(),
          slivers: [SliverSafeArea(bottom: false, sliver: SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, bottom + 100),
            sliver: SliverToBoxAdapter(child: switch (tab) {
              0 => discover(context), 1 => shelf(context),
              2 => local(context), _ => settings(context),
            }),
          ))],
        ),
      )),
      Positioned(left: 20, right: 20, bottom: bottom,
        child: Row(children: [
          Expanded(child: ArchiveDock(selected: tab, onSelected: (value) => setState(() => tab = value))),
          const SizedBox(width: 10),
          Press(key: const ValueKey('reference-search'), label: '搜索书籍',
            onTap: () => setState(() { tab = 0; searching = !searching; if (!searching) query = ''; }),
            child: ReferenceGlass(radius: 29, child: SizedBox(width: 58, height: 58,
              child: Icon(searching && tab == 0 ? CupertinoIcons.xmark : CupertinoIcons.search, color: ink(context), size: 27)))),
        ])),
    ]));
  }
  Widget heading(String title, String subtitle, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(children: [
      if (tab == 0) ...[
        ReferenceGlass(radius: 14, padding: const EdgeInsets.all(4),
          child: ClipRRect(borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/app-icon.png', width: 36, height: 36))),
        const SizedBox(width: 10),
      ],
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 23, height: 1.18, fontWeight: FontWeight.w800, letterSpacing: -.6)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: muted(context), fontSize: 9, letterSpacing: 1.05)),
      ])),
      if (trailing != null) trailing,
    ]),
  );
  Widget section(String title, String code, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(code, style: TextStyle(fontSize: 9, color: muted(context), letterSpacing: 1)),
          const SizedBox(width: 10), Expanded(child: Container(height: .5, color: muted(context).withValues(alpha: .22))),
          const SizedBox(width: 5), Container(width: 3, height: 3, color: muted(context)),
        ]),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
      ])),
      if (trailing != null) trailing,
    ]),
  );
  Widget collection(List<DemoBook> items, String origin) => Column(children: [
    if ((presentation < 2 || presentation == 4) && items.isNotEmpty) ArchivePreviewShelf(
      key: ValueKey('$origin-${items.map((b) => b.id).join('-')}'),
      sceneHeight: (MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).vertical - 378).clamp(340.0, 440.0),
      books: [for (final book in items) ShelfBook(book.title, book.author, 'WK-${(book.id + 1).toString().padLeft(5, '0')}')],
      onOpen: (index) => open(items[index], '$origin-archive-${items[index].id}'),
      coverBuilder: (index, width, selected) => BookCover(items[index], width: width,
        tag: selected ? '$origin-archive-${items[index].id}' : null),
    ),
    if (presentation == 1 || presentation == 3)
      Padding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: LayoutBuilder(builder: (context, constraints) {
          final width = (constraints.maxWidth - 32) / 3;
          return Wrap(spacing: 16, runSpacing: 20, children: [for (final book in items)
            SizedBox(width: width, child: Press(onTap: () => open(book, '$origin-grid-${book.id}'),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                BookCover(book, width: width, tag: '$origin-grid-${book.id}'),
                const SizedBox(height: 9),
                Text(book.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(book.author, style: TextStyle(fontSize: 11, color: muted(context))),
              ]))),
          ]);
        })),
    if (presentation == 0 || presentation == 2)
      Padding(padding: const EdgeInsets.fromLTRB(24, 18, 24, 0), child: Column(children: [
        for (final book in items) Press(onTap: () => open(book, '$origin-list-${book.id}'),
          child: Container(padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: .5, color: muted(context).withValues(alpha: .18)))),
            child: Row(children: [
              BookCover(book, width: 52, tag: '$origin-list-${book.id}'),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6), Text('${book.author} · ${book.genre}', style: TextStyle(fontSize: 12, color: muted(context))),
                const SizedBox(height: 7), Text('WK-${(book.id + 1).toString().padLeft(5, '0')}',
                  style: TextStyle(fontSize: 9, letterSpacing: .8, color: muted(context))),
              ])),
              Icon(CupertinoIcons.arrow_up_right, size: 17, color: ink(context)),
            ]),
          )),
      ])),
    if (items.isEmpty) Padding(padding: const EdgeInsets.all(32),
      child: Text('这里还没有档案', style: TextStyle(fontSize: 14, color: muted(context)))),
    if (presentation != 4) ...[
      const SizedBox(height: 32),
      Text('已经到底了', style: TextStyle(fontSize: 12, color: muted(context))),
      const SizedBox(height: 18),
    ],
  ]);
  void chooseCategory() => showCupertinoModalPopup<void>(context: context,
    builder: (sheetContext) => CupertinoActionSheet(title: const Text('浏览分类'),
      actions: [for (final label in const ['最近更新', '最近阅读', '已收藏'])
        CupertinoActionSheetAction(onPressed: () {
          setState(() => category = label); Navigator.pop(sheetContext);
        }, child: Text(label))],
      cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(sheetContext), child: const Text('取消'))));
  void chooseGenre() => showCupertinoModalPopup<void>(context: context,
    builder: (sheetContext) => CupertinoActionSheet(title: const Text('题材筛选'),
      actions: [for (final label in ['全部题材', ...books.map((b) => b.genre)])
        CupertinoActionSheetAction(onPressed: () {
          setState(() => genre = label); Navigator.pop(sheetContext);
        }, child: Text(label))],
      cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(sheetContext), child: const Text('取消'))));
  Widget toolbar(int count) => Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(children: [
      Expanded(child: Press(key: const ValueKey('region-options'), onTap: chooseCategory,
        child: ReferenceGlass(radius: 26, emphasized: true, padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(height: 44, child: Row(children: [
            Icon(CupertinoIcons.folder, size: 19, color: ink(context)), const SizedBox(width: 8),
            Expanded(child: FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown,
              child: Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            const SizedBox(width: 5), Icon(CupertinoIcons.chevron_down, size: 11, color: ink(context)),
          ]))))),
      const SizedBox(width: 8),
      ReferenceGlass(radius: 24, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 11),
        child: SizedBox(height: 44, child: Center(child: Text('$count 本', style: TextStyle(fontSize: 14, color: muted(context))))))),
      const SizedBox(width: 8),
      Press(key: const ValueKey('genre-options'), label: '筛选题材', onTap: chooseGenre,
        child: ReferenceGlass(radius: 24, child: SizedBox(width: 44, height: 44,
          child: Icon(CupertinoIcons.slider_horizontal_3, size: 23, color: ink(context))))),
      const SizedBox(width: 8),
      Press(key: const ValueKey('view-options'), label: '书库浏览方式', onTap: choosePresentation,
        child: ReferenceGlass(radius: 24, child: SizedBox(width: 44, height: 44,
          child: Icon(CupertinoIcons.square_grid_2x2, size: 22, color: ink(context))))),
    ]));
  Widget discover(BuildContext context) {
    final results = books.where((b) => '${b.title}${b.author}${b.genre}'.contains(query)
      && (genre == '全部题材' || b.genre == genre)
      && (category != '已收藏' || widget.saved.contains(b.id))
      && (category != '最近阅读' || widget.progress.containsKey(b.id))).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heading('轻小说文库', 'WENKU8 / READING ARCHIVE'),
      section('发现', 'COLLECTION / REGION'),
      toolbar(results.length),
      if (searching) Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: ReferenceGlass(radius: 24, padding: const EdgeInsets.symmetric(horizontal: 7),
          child: CupertinoSearchTextField(placeholder: '搜索演示书籍、作者', autofocus: true,
            onChanged: (value) => setState(() => query = value.trim()),
            backgroundColor: const Color(0x00000000),
            style: TextStyle(color: ink(context), fontSize: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)))),
      collection(results, 'discovery'),
    ]);
  }
  Widget shelf(BuildContext context) {
    final items = books.where((b) => widget.saved.contains(b.id) &&
      (!onlyReading || widget.progress.containsKey(b.id))).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heading('书架', '02 / PERSONAL ARCHIVE', trailing: CupertinoButton(onPressed: choosePresentation,
        child: Icon(CupertinoIcons.line_horizontal_3_decrease, color: ink(context), size: 20))),
      Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: CupertinoSlidingSegmentedControl<bool>(groupValue: onlyReading,
          children: const {false: Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('全部')), true: Text('在读')},
          onValueChanged: (value) { if (value != null) setState(() => onlyReading = value); })),
      section('我的收藏', 'SHELF / ${items.length.toString().padLeft(2, '0')}'),
      collection(items, 'personal'),
    ]);
  }
  Widget local(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    heading('本地', '03 / LOCAL ARCHIVE'),
    section('本地书库', 'LOCAL / DEMO'),
    Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), child: Panel(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(CupertinoIcons.folder, color: ink(context)), const SizedBox(width: 12),
          const Text('演示本地档案', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 14),
        Text('保留原作独立的本地书库入口。这个预览使用演示档案，不提供实际文件导入。',
          style: TextStyle(fontSize: 13, height: 1.6, color: muted(context))),
      ]))),
    collection([books[3]], 'local'),
  ]);
  Widget settings(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    heading('我的', '04 / PERSONAL PROFILE'),
    section('外观与体验', '01 / APPEARANCE'),
    Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), child: Panel(child: Column(children: [
      preference(context, CupertinoIcons.moon, '深色外观', widget.dark, widget.onDark),
      const SizedBox(height: 20),
      preference(context, CupertinoIcons.wind, '减少动态效果', widget.reduceMotion, widget.onMotion),
    ]))),
    section('关于这个预览', '02 / ABOUT'),
    Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), child: Panel(child: Text(
      '沿用原作的档案排版、立体抽取书架、奶白色纸张和四个导航入口。采用 Cupertino 控件、模糊玻璃、弹簧吸附和手势返回实现 Apple 风格的反馈与过渡。\n\n全部书籍和正文为原创演示内容；书架及位置仅在本次运行内保留，不提供在线书库、导入、同步和听书。',
      style: TextStyle(fontSize: 14, height: 1.7, color: muted(context))))),
  ]);
}

class ArchiveDock extends StatefulWidget {
  const ArchiveDock({super.key, required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  State<ArchiveDock> createState() => _ArchiveDockState();
}
class _ArchiveDockState extends State<ArchiveDock> {
  int? hovered;
  int get active => hovered ?? widget.selected;
  @override
  Widget build(BuildContext context) => ReferenceGlass(radius: 32,
    padding: const EdgeInsets.all(4),
    child: LayoutBuilder(builder: (context, constraints) {
      final lane = constraints.maxWidth / 4;
      return GestureDetector(
        onHorizontalDragStart: (event) => setState(() => hovered = (event.localPosition.dx / lane).floor().clamp(0, 3)),
        onHorizontalDragUpdate: (event) => setState(() => hovered = (event.localPosition.dx / lane).floor().clamp(0, 3)),
        onHorizontalDragCancel: () => setState(() => hovered = null),
        onHorizontalDragEnd: (_) { widget.onSelected(active); setState(() => hovered = null); },
        child: Stack(children: [
          AnimatedPositioned(duration: motion(context, 320), curve: const Cubic(.22, 1, .36, 1),
            left: active * lane, width: lane, top: 0, bottom: 0,
            child: const ReferenceGlass(radius: 27, emphasized: true, child: SizedBox.expand())),
          Row(children: [for (final entry in const [
            (CupertinoIcons.square_pencil, '发现'), (CupertinoIcons.book, '书架'),
            (CupertinoIcons.folder, '本地'), (CupertinoIcons.person_crop_rectangle, '我的'),
          ].indexed) Expanded(child: Semantics(selected: widget.selected == entry.$1,
            child: Press(onTap: () => widget.onSelected(entry.$1), child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7), child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(entry.$2.$1, size: 22, color: active == entry.$1 ? ink(context) : muted(context)),
                const SizedBox(height: 3),
                Text(entry.$2.$2, style: TextStyle(fontSize: 10, fontWeight: active == entry.$1 ? FontWeight.w700 : FontWeight.w400,
                  color: active == entry.$1 ? ink(context) : muted(context))),
                const SizedBox(height: 4),
                Container(width: 12, height: 1.3, color: active == entry.$1 ? ink(context) : const Color(0x00000000)),
              ])),
            ))),
          ]),
        ]),
      );
    }),
  );
}


Widget preference(BuildContext context, IconData icon, String title,
    bool value, ValueChanged<bool> onChanged) => Row(children: [
  Icon(icon, size: 21, color: CupertinoTheme.of(context).primaryColor),
  const SizedBox(width: 12),
  Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
  CupertinoSwitch(value: value, onChanged: onChanged),
]);
Widget previewNote(BuildContext context) => Text(
  '界面预览 · 原创演示书籍 · 数据仅在本次运行内保留',
  style: TextStyle(fontSize: 12, height: 1.5, color: muted(context)),
);

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.book, required this.tag,
    required this.isSaved, required this.chapter, required this.onSave, required this.onProgress});
  final DemoBook book;
  final String tag;
  final bool isSaved;
  final int chapter;
  final VoidCallback onSave;
  final ValueChanged<int> onProgress;
  @override
  State<DetailPage> createState() => _DetailPageState();
}
class _DetailPageState extends State<DetailPage> {
  late bool saved = widget.isSaved;
  late int chapter = widget.chapter;
  void read([int? page]) {
    final initial = page ?? chapter;
    widget.onProgress(initial);
    Navigator.of(context).push<void>(PreviewRoute<void>(reduced: MediaQuery.disableAnimationsOf(context), builder: (_) => ReaderPage(
      book: widget.book, initialPage: initial,
      onProgress: (value) {
        setState(() => chapter = value);
        widget.onProgress(value);
      },
    )));
  }
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: const Text('书籍详情'), previousPageTitle: '返回',
      backgroundColor: resolved(context, pageColor).withValues(alpha: .88),
      border: null,
    ),
    child: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 36),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: BookCover(widget.book, width: 176, tag: widget.tag)),
        const SizedBox(height: 28),
        Center(child: Text(widget.book.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -.6))),
        const SizedBox(height: 8),
        Center(child: Text('${widget.book.author} · ${widget.book.genre}', style: TextStyle(fontSize: 14, color: muted(context)))),
        const SizedBox(height: 26),
        SizedBox(width: double.infinity, child: CupertinoButton.filled(
          borderRadius: BorderRadius.circular(24), onPressed: () => read(),
          child: const Text('开始阅读', style: TextStyle(fontWeight: FontWeight.w600)),
        )),
        const SizedBox(height: 10),
        Center(child: CupertinoButton(onPressed: () {
          widget.onSave(); setState(() => saved = !saved);
        }, child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(saved ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.plus_circle, size: 19),
          const SizedBox(width: 8), Text(saved ? '已加入书架' : '加入书架'),
        ]))),
        const SizedBox(height: 16),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('关于故事', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Text(widget.book.description, style: TextStyle(fontSize: 16, height: 1.7, color: muted(context))),
          const SizedBox(height: 14),
          Text('原创演示内容 · 3 章', style: TextStyle(fontSize: 12, color: CupertinoTheme.of(context).primaryColor)),
        ])),
        const SizedBox(height: 20),
        Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('目录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          for (var i = 0; i < chapterTitles.length; i++)
            CupertinoButton(padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: () => read(i), child: Row(children: [
                Expanded(child: Text(chapterTitles[i], style: TextStyle(fontSize: 15, color: ink(context)))),
                Icon(CupertinoIcons.chevron_right, size: 13, color: muted(context)),
              ])),
        ])),
        const SizedBox(height: 20), previewNote(context),
      ]),
    )),
  );
}

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, required this.book, required this.initialPage, required this.onProgress});
  final DemoBook book;
  final int initialPage;
  final ValueChanged<int> onProgress;
  @override
  State<ReaderPage> createState() => _ReaderPageState();
}
class _ReaderPageState extends State<ReaderPage> {
  late final PageController controller = PageController(initialPage: widget.initialPage);
  late int page = widget.initialPage;
  double fontSize = 19;
  bool sepia = false;
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  void go(int index) {
    if (index < 0 || index >= passages.length) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpToPage(index);
    } else {
      controller.animateToPage(index, duration: motion(context, 360), curve: Curves.easeOutCubic);
    }
  }
  @override
  Widget build(BuildContext context) {
    final paper = sepia ? const Color(0xFFF6EFDF) : resolved(context, panelColor);
    final textColor = sepia ? const Color(0xFF39342B) : ink(context);
    return CupertinoPageScaffold(
      backgroundColor: paper,
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.book.title), previousPageTitle: '详情', border: null,
        backgroundColor: paper.withValues(alpha: .92),
      ),
      child: SafeArea(child: Column(children: [
        Expanded(child: PageView.builder(
          controller: controller, itemCount: passages.length,
          onPageChanged: (value) { setState(() => page = value); widget.onProgress(value); },
          itemBuilder: (context, index) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('原创演示 · 左右滑动切换章节', style: TextStyle(fontSize: 12, color: sepia ? const Color(0xFF69604E) : muted(context))),
                const SizedBox(height: 24),
                Text(chapterTitles[index], style: TextStyle(fontSize: 25, height: 1.5, fontWeight: FontWeight.w600, color: textColor)),
                const SizedBox(height: 28),
                Text(passages[index], style: TextStyle(fontSize: fontSize, height: 1.9, letterSpacing: .5, color: textColor)),
              ]),
            )),
          ),
        )),
        Container(padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
          color: paper,
          child: Column(children: [
            Row(children: [
              CupertinoButton(onPressed: page > 0 ? () => go(page - 1) : null,
                child: const Icon(CupertinoIcons.chevron_left, semanticLabel: '上一章', size: 18)),
              Expanded(child: Text('第 ${page + 1} / ${passages.length} 章', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textColor))),
              CupertinoButton(onPressed: page < passages.length - 1 ? () => go(page + 1) : null,
                child: const Icon(CupertinoIcons.chevron_right, semanticLabel: '下一章', size: 18)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CupertinoButton(onPressed: fontSize > 16 ? () => setState(() => fontSize -= 1) : null,
                child: const Text('A−', semanticsLabel: '减小字号')),
              Text('${fontSize.round()}', style: TextStyle(fontSize: 13, color: textColor)),
              CupertinoButton(onPressed: fontSize < 26 ? () => setState(() => fontSize += 1) : null,
                child: const Text('A+', semanticsLabel: '增大字号')),
              CupertinoButton(onPressed: () => setState(() => sepia = !sepia),
                child: Text(sepia ? '默认纸色' : '暖色纸张', style: const TextStyle(fontSize: 13))),
            ]),
          ]),
        ),
      ])),
    );
  }
}
