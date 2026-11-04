# 文库 · 原生液态玻璃预览（0.5）

保留原作者的档案式排版、立体抽取书架、编号、细线和「发现 / 书架 / 本地 / 我的」四个入口。移除自绘玻璃描边、多层高光、光晕、棱彩背景和导航内叠加的第二层玻璃。

## 原生材质

`ios/AppDelegate.swift` 注册 Flutter 原生视图，每个玻璃区域由 UIKit 的 `UIVisualEffectView` 承载：iOS 26 使用 `UIGlassEffect(style: .regular)`，不设置自定义 tint、边缘光或透明度；更早的系统使用 `UIBlurEffect(.systemThinMaterial)` 兼容。iOS 26 的系统玻璃自行适配环境和系统辅助功能。

Flutter 继续管理文字、图标、点击、手势、无障碍和书架，不把书架改成另一个阅读器。原生视图只提供背景材质，禁止截获前景点击。深浅色及圆角通过独立通道同步。导航选择态使用低对比度标记，避免重复叠加两层玻璃。背景仅保留淡色纸张和细网格。

布局和阅读流程的 widget 测试使用无 UIKit 环境下的平面背景，不能证明原生材质。原生验证另在 iOS 26 模拟器执行：实际创建玻璃视图后，显式启用 WENKU_GLASS_VERIFICATION 的 Debug 校验构建输出仅含效果类型、系统版本和创建数量的校验记录；脚本要求 实际效果通过 Swift 的 `is UIGlassEffect` 类型检查（`liquidGlass == true`） 且创建数量大于零，再保存真实截图。Release 中不写该记录。同时检查真机 Release 可执行文件引用 UIGlassEffect。

## Sheet 与操作控件

分类、题材、书架模式、目录、阅读设置与外观设置通过 Flutter 通道打开 UIKit 原生 pageSheet，使用系统中/大 detent、拖拽指示器与原生呈现/关闭动画。面板内部采用 UIGlassEffect，按钮使用 iOS 26 UIButton.Configuration.glass()，字号、纸张、深色和减少动态效果分别使用 UISlider、UISegmentedControl、UISwitch。选择立即返回；设置点「完成」提交，下拉关闭放弃本次编辑。

详情和阅读导航栏、开始阅读/收藏按钮、阅读底部工具栏统一使用原生材质。阅读正文保留实色纸张保证可读性。iOS 26 模拟器分别启动首页、浏览选择 Sheet 和阅读设置 Sheet，保存真实截图与按角色区分的玻璃类型检查记录。

## 构建与交付

需要 Xcode 26、iOS 26 SDK、Flutter 3.41.5、CocoaPods。GitHub Actions 选择执行器中已安装的 Xcode 26，生成隔离 iOS 宿主，复制本目录的 Swift 入口和 Dart 界面，执行分析、交互检查和真机 Release 编译。

```sh
bash preview/tool/build_ios.sh
```

结果位于 `preview/dist/`。用户直接取得提取并校验过的未签名 IPA，自行签名安装；原生液态玻璃需要 iOS 26，旧系统的兼容模糊不是液态玻璃。独立 Bundle ID，不覆盖原应用。

## 预览范围

支持书架五种浏览方式、搜索、分类和题材筛选、收藏、详情、目录与示例阅读器。演示数量按当前集合计算；书架高度根据屏幕和安全区适配，使信息卡和页码保持在导航上方。

书架几何与渲染改编自根工程 `archive_shelf_geometry.dart` / `archive_wave.dart`，遵循根目录 LICENSE 和 NOTICE。书籍、封面与正文均为原创演示内容，四本书共用三章示例，数据仅在本次运行内保存。没有联网书库、账号、实际文件导入、同步、听书和小组件。根工程仍是不完整源码快照。
