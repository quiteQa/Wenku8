# 文库 · iOS 界面预览

这是独立的 Flutter 预览应用，用于体验 Apple 风格的界面与动效，不依赖根工程缺失的 Dart / Swift 模块。它复用了本轮改版的配色、圆角、标题层级和克制动效方向；不是完整阅读器，也未复用根工程需要原生插件的液态玻璃折射效果。导航使用原生风格 Cupertino 过渡，浮动栏使用系统模糊材质。

## 可以体验

- 发现页与演示书籍搜索、封面到详情的 Hero 过渡。
- 加入 / 移出书架，在读筛选、目录跳转与左右滑动章节。
- 阅读字号、暖色纸张、深色外观与减少动态效果。
- 书籍、封面和正文均为原创演示内容，四本书共用三章示例正文。数据只在本次运行内保存。

不含联网书库、账号、导入、同步、听书与桌面小组件。Bundle ID 独立于原应用，不覆盖正式阅读器。

## 构建与下载

GitHub Actions 的 **Build iOS UI preview** 工作流在 `codex/ios-preview` 分支推送预览代码时构建。Fork 仓库如禁用了 Actions，仓库所有者需先在 Actions 页面启用，再推送该分支的新提交。工作流未合入默认分支前，通常不会显示手动运行按钮。

构建成功后，从该次运行的 Artifacts 下载 `Wenku8-Preview-unsigned`，解压即可取得 `Wenku8-Preview-unsigned.ipa`、SHA256 校验文件和安装说明。工作流会检查 Flutter 分析结果、编译真机 Release 二进制、确认 iOS 平台并验证 ZIP 结构；产物保留 14 天。

IPA 没有 Apple 分发签名，不能直接点击安装；需通过自己的签名工具与 Apple 身份完成签名。不是 App Store 或 TestFlight 包。

## 在 Mac 上构建

需要完整 Xcode、已完成初始化的 iOS SDK、Flutter 3.41.5（Dart 3.11）和 CocoaPods，以及可下载依赖的网络。

```sh
bash preview/tool/build_ios.sh
```

脚本在临时目录生成全新的 iOS 宿主，复制本目录的入口与依赖，运行分析和 `flutter build ios --release --no-codesign`，将真机 Runner.app 放进 Payload 后打包。结果位于 `preview/dist/`。本目录不会修改根工程的 iOS 宿主，也不需要签名证书或仓库密钥。

本地交互检查可在本目录执行 `flutter pub get`，然后执行 `flutter run -d <设备ID>`；如果尚无平台宿主，先在临时副本运行 `flutter create --platforms=ios --no-pub .`。

遵循根目录 LICENSE 与 NOTICE 中适用的许可说明。
