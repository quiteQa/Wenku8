import 'dart:ui';
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
  color: Color(0xFFF2F2F7), darkColor: Color(0xFF000000),
);
const panelColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFFFFFF), darkColor: Color(0xFF1C1C1E),
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
      primaryColor: dark ? const Color(0xFF409CFF) : blue,
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
      color: resolved(context, panelColor), borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(10),
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
    return tag == null ? cover : Hero(tag: tag!, child: cover);
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
  int tab = 0;
  String query = '';
  bool onlyReading = false;
  void open(DemoBook book, String tag) => Navigator.of(context).push<void>(
    PreviewRoute<void>(reduced: MediaQuery.disableAnimationsOf(context), builder: (_) => DetailPage(
      book: book, tag: tag, isSaved: widget.saved.contains(book.id),
      chapter: widget.progress[book.id] ?? 0,
      onSave: () => widget.onSave(book.id),
      onProgress: (page) => widget.onProgress(book.id, page),
    )),
  );
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return CupertinoPageScaffold(
      child: Stack(children: [
        Positioned.fill(child: AnimatedSwitcher(
          duration: motion(context),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(position: Tween<Offset>(
              begin: const Offset(0, .015), end: Offset.zero,
            ).animate(animation), child: child),
          ),
          child: CustomScrollView(
            key: ValueKey(tab),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [SliverSafeArea(
              bottom: false,
              sliver: SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 22, 24, bottom + 118),
                sliver: SliverToBoxAdapter(child: switch (tab) {
                  0 => discover(context),
                  1 => shelf(context),
                  _ => settings(context),
                }),
              ),
            )],
          ),
        )),
        Positioned(left: 40, right: 40, bottom: bottom + 14,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: resolved(context, panelColor).withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: resolved(context, CupertinoColors.separator).withValues(alpha: .18)),
                ),
                padding: const EdgeInsets.all(5),
                child: Row(children: [
                  nav(0, CupertinoIcons.compass, '发现'),
                  nav(1, CupertinoIcons.book, '书架'),
                  nav(2, CupertinoIcons.person_crop_circle, '我的'),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
  Widget nav(int index, IconData icon, String title) => Expanded(
    child: Semantics(selected: tab == index,
      child: Press(label: title, onTap: () => setState(() => tab = index),
        child: AnimatedContainer(
          duration: motion(context, 280),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: tab == index ? CupertinoTheme.of(context).primaryColor.withValues(alpha: .1) : const Color(0x00000000),
            borderRadius: BorderRadius.circular(27),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 23, color: tab == index ? CupertinoTheme.of(context).primaryColor : muted(context)),
            const SizedBox(height: 3),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: tab == index ? CupertinoTheme.of(context).primaryColor : muted(context))),
          ]),
        ),
      ),
    ),
  );
  Widget heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(subtitle, style: TextStyle(color: muted(context), fontSize: 13, letterSpacing: .8)),
      const SizedBox(height: 7),
      Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -.9)),
      const SizedBox(height: 24),
    ],
  );
  Widget discover(BuildContext context) {
    final results = books.where((b) => '${b.title}${b.author}${b.genre}'.contains(query)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heading('发现好故事', 'WENKU · 阅读此刻'),
      CupertinoSearchTextField(
        placeholder: '搜索演示书籍、作者',
        onChanged: (value) => setState(() => query = value.trim()),
        style: TextStyle(color: ink(context), fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        borderRadius: BorderRadius.circular(16),
      ),
      const SizedBox(height: 24),
      if (query.isEmpty) ...[
        Press(onTap: () => open(books[0], 'featured-0'),
          label: '本周精选，风经过的地方',
          child: Panel(child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('本周精选', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CupertinoTheme.of(context).primaryColor)),
              const SizedBox(height: 14),
              const Text('让阅读\n慢下来。', style: TextStyle(fontSize: 27, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -.7)),
              const SizedBox(height: 12),
              Text('在故事里，\n找到自己的节奏。', style: TextStyle(fontSize: 13, height: 1.6, color: muted(context))),
              const SizedBox(height: 16),
              Text('探索故事  →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CupertinoTheme.of(context).primaryColor)),
            ])),
            const SizedBox(width: 12),
            BookCover(books[0], width: 112, tag: 'featured-0'),
          ])),
        ),
        const SizedBox(height: 30),
      ],
      Text(query.isEmpty ? '为你精选' : '搜索结果',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -.4)),
      const SizedBox(height: 7),
      Text(query.isEmpty ? '下一段旅程，从翻开一页开始' : '找到 ${results.length} 本演示书籍',
        style: TextStyle(color: muted(context), fontSize: 14)),
      const SizedBox(height: 20),
      if (results.isEmpty) Panel(child: Center(child: Text('没有匹配的演示书籍', style: TextStyle(color: muted(context)))))
      else LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
        return Wrap(spacing: 20, runSpacing: 24, children: [for (final book in results)
          SizedBox(width: width, child: Press(
            label: '查看${book.title}', onTap: () => open(book, 'discover-${book.id}'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BookCover(book, width: width, tag: 'discover-${book.id}'),
              const SizedBox(height: 11),
              Text(book.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${book.author} · ${book.genre}', style: TextStyle(fontSize: 12, color: muted(context))),
            ]),
          )),
        ]);
      }),
      const SizedBox(height: 28),
      previewNote(context),
    ]);
  }
  Widget shelf(BuildContext context) {
    final items = books.where((b) => widget.saved.contains(b.id) &&
      (!onlyReading || widget.progress.containsKey(b.id))).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      heading('我的书架', 'LIBRARY · 留给喜欢的故事'),
      CupertinoSlidingSegmentedControl<bool>(
        groupValue: onlyReading,
        children: const {false: Padding(padding: EdgeInsets.symmetric(horizontal: 22), child: Text('全部')), true: Text('在读')},
        onValueChanged: (value) { if (value != null) setState(() => onlyReading = value); },
      ),
      const SizedBox(height: 24),
      if (items.isEmpty) Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(CupertinoIcons.book, size: 32), const SizedBox(height: 16),
        Text(onlyReading ? '还没有开始阅读' : '把喜欢的故事放在这里', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('前往发现页，打开书籍详情即可加入书架。', style: TextStyle(fontSize: 14, height: 1.5, color: muted(context))),
      ])),
      for (final book in items) ...[
        Press(onTap: () => open(book, 'shelf-${book.id}'),
          child: Panel(child: Row(children: [
            BookCover(book, width: 78, tag: 'shelf-${book.id}'),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(book.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              Text(book.author, style: TextStyle(fontSize: 13, color: muted(context))),
              const SizedBox(height: 18),
              Text(widget.progress.containsKey(book.id) ? '读到第 ${widget.progress[book.id]! + 1} 章' : '尚未开始 · 3 章演示',
                style: TextStyle(fontSize: 12, color: CupertinoTheme.of(context).primaryColor)),
            ])),
            Icon(CupertinoIcons.chevron_right, size: 15, color: muted(context)),
          ])),
        ), const SizedBox(height: 14),
      ],
      const SizedBox(height: 14), previewNote(context),
    ]);
  }
  Widget settings(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    heading('阅读，随你', 'PERSONAL · 你的阅读空间'),
    Panel(child: Row(children: [
      Container(width: 54, height: 54,
        decoration: BoxDecoration(color: CupertinoTheme.of(context).primaryColor.withValues(alpha: .1), borderRadius: BorderRadius.circular(18)),
        child: Icon(CupertinoIcons.book_fill, color: CupertinoTheme.of(context).primaryColor, size: 26)),
      const SizedBox(width: 16),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('文库 · 界面预览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        SizedBox(height: 5), Text('让故事成为日常', style: TextStyle(fontSize: 13)),
      ])),
    ])),
    const SizedBox(height: 28),
    const Text('外观与体验', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
    const SizedBox(height: 16),
    Panel(child: Column(children: [
      preference(context, CupertinoIcons.moon, '深色外观', widget.dark, widget.onDark),
      const SizedBox(height: 20),
      preference(context, CupertinoIcons.wind, '减少动态效果', widget.reduceMotion, widget.onMotion),
    ])),
    const SizedBox(height: 24),
    Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('关于这个预览', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Text('展示发现、搜索、书架、详情、翻页和阅读设置。书籍、封面及正文均为原创演示内容。\n\n书架和阅读位置仅在本次运行内保存；不连接在线书库，不提供登录、导入、同步与听书功能。',
        style: TextStyle(fontSize: 14, height: 1.6, color: muted(context))),
    ])),
  ]);
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
