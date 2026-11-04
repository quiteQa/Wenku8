import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WenkuNativeGlass") else {
      return
    }
    let factory = NativeGlassFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "wenku8/native-glass")
  }
}

private final class NativeGlassFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let capabilityChannel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    capabilityChannel = FlutterMethodChannel(name: "wenku8/native-glass", binaryMessenger: messenger)
    super.init()
    capabilityChannel.setMethodCallHandler { call, result in
      if call.method == "capabilities" {
        var payload: [String: Any] = ["native": true]
        if #available(iOS 26.0, *) { payload["liquidGlass"] = true; payload["backend"] = "UIGlassEffect" }
        else { payload["liquidGlass"] = false; payload["backend"] = "UIBlurEffect" }
        #if WENKU_GLASS_VERIFICATION
        payload["captureScene"] = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--wenku-scene=") })?.components(separatedBy: "=").last ?? ""
        #endif
        result(payload); return
      }
      let kind: String
      switch call.method {
      case "showChoices": kind = "choices"
      case "showReadingSettings": kind = "reading"
      case "showPreferences": kind = "preferences"
      default: result(FlutterMethodNotImplemented); return
      }
      NativeGlassSheet.present(kind: kind, payload: call.arguments as? [String: Any] ?? [:], reply: result)
    }
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    let view = NativeGlassView(frame: frame, arguments: args as? [String: Any] ?? [:],
                               id: viewId, messenger: messenger)
    return view
  }
}

private final class NativeGlassView: NSObject, FlutterPlatformView {
  private let host: UIView
  private let effectView: UIVisualEffectView
  private let channel: FlutterMethodChannel
  var effectClass: String {
    guard let effect = effectView.effect else { return "none" }
    return String(describing: type(of: effect))
  }
  var isLiquidGlass: Bool {
    if #available(iOS 26.0, *) { return effectView.effect is UIGlassEffect }
    return false
  }

  init(frame: CGRect, arguments: [String: Any], id: Int64, messenger: FlutterBinaryMessenger) {
    host = UIView(frame: frame)
    host.backgroundColor = .clear
    host.isOpaque = false
    // Flutter owns foreground controls and their accessibility/hit targets.
    // The native view supplies only Apple's system material behind them.
    host.isUserInteractionEnabled = false
    let effect = NativeGlassMaterial.make("surface")
    effectView = UIVisualEffectView(effect: effect)
    effectView.backgroundColor = .clear
    effectView.translatesAutoresizingMaskIntoConstraints = false
    effectView.isUserInteractionEnabled = false
    channel = FlutterMethodChannel(name: "wenku8/native-glass/\(id)", binaryMessenger: messenger)
    super.init()
    host.addSubview(effectView)
    NSLayoutConstraint.activate([
      effectView.leadingAnchor.constraint(equalTo: host.leadingAnchor),
      effectView.trailingAnchor.constraint(equalTo: host.trailingAnchor),
      effectView.topAnchor.constraint(equalTo: host.topAnchor),
      effectView.bottomAnchor.constraint(equalTo: host.bottomAnchor)
    ])
    configure(arguments)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "configure", let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.configure(args)
      result(nil)
    }
  }

  private func configure(_ args: [String: Any]) {
    let radius = CGFloat((args["radius"] as? NSNumber)?.doubleValue ?? 28)
    effectView.layer.cornerRadius = radius
    effectView.layer.cornerCurve = .continuous
    effectView.clipsToBounds = true
    host.overrideUserInterfaceStyle = (args["dark"] as? Bool ?? false) ? .dark : .light
  }

  func view() -> UIView { host }

  deinit { channel.setMethodCallHandler(nil) }
}


private enum NativeGlassMaterial {
  #if WENKU_GLASS_VERIFICATION
  private static var count = 0
  private static var roles = Set<String>()
  #endif
  static func make(_ role: String) -> UIVisualEffect {
    let effect: UIVisualEffect
    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.isInteractive = false
      effect = glass
    } else {
      effect = UIBlurEffect(style: .systemThinMaterial)
    }
    #if WENKU_GLASS_VERIFICATION
    count += 1
    roles.insert(role)
    let native: Bool
    if #available(iOS 26.0, *) { native = effect is UIGlassEffect } else { native = false }
    let receipt: [String: Any] = ["effectClass": String(describing: type(of: effect)),
      "liquidGlass": native, "createdViews": count, "roles": roles.sorted(),
      "systemVersion": UIDevice.current.systemVersion]
    if let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
       let data = try? JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys]) {
      try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      try? data.write(to: directory.appendingPathComponent("native-glass-verification.json"), options: .atomic)
    }
    #endif
    return effect
  }
}

private final class NativeGlassSheet: UIViewController, UIAdaptivePresentationControllerDelegate {
  private let kind: String
  private let payload: [String: Any]
  private var reply: FlutterResult?
  private let fontSlider = UISlider()
  private let paper = UISegmentedControl(items: ["默认", "暖色"])
  private let darkSwitch = UISwitch()
  private let motionSwitch = UISwitch()
  private let fontLabel = UILabel()

  static func present(kind: String, payload: [String: Any], reply: @escaping FlutterResult) {
    let windows = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive }.flatMap { $0.windows }
    guard var presenter = windows.first(where: { $0.isKeyWindow })?.rootViewController else {
      reply(FlutterError(code: "NO_WINDOW", message: "No active presentation window", details: nil)); return
    }
    while let presented = presenter.presentedViewController { presenter = presented }
    guard !(presenter is NativeGlassSheet) else { reply(nil); return }
    let controller = NativeGlassSheet(kind: kind, payload: payload, reply: reply)
    controller.modalPresentationStyle = .pageSheet
    if #available(iOS 15.0, *), let sheet = controller.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.prefersGrabberVisible = true
      sheet.preferredCornerRadius = 30
      sheet.prefersEdgeAttachedInCompactHeight = true
      sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }
    controller.presentationController?.delegate = controller
    presenter.present(controller, animated: !UIAccessibility.isReduceMotionEnabled && !(payload["reduceMotion"] as? Bool ?? false))
  }

  init(kind: String, payload: [String: Any], reply: @escaping FlutterResult) {
    self.kind = kind; self.payload = payload; self.reply = reply
    super.init(nibName: nil, bundle: nil)
    overrideUserInterfaceStyle = (payload["dark"] as? Bool ?? false) ? .dark : .light
  }
  required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    let effect = UIVisualEffectView(effect: NativeGlassMaterial.make(kind))
    effect.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(effect)
    NSLayoutConstraint.activate([
      effect.leadingAnchor.constraint(equalTo: view.leadingAnchor), effect.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      effect.topAnchor.constraint(equalTo: view.topAnchor), effect.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    effect.contentView.addSubview(scroll)
    let stack = UIStackView()
    stack.axis = .vertical; stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false
    scroll.addSubview(stack)
    NSLayoutConstraint.activate([
      scroll.leadingAnchor.constraint(equalTo: effect.contentView.leadingAnchor, constant: 22),
      scroll.trailingAnchor.constraint(equalTo: effect.contentView.trailingAnchor, constant: -22),
      scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
      stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
      stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
      stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
    ])
    let title = UILabel()
    title.text = payload["title"] as? String ?? (kind == "reading" ? "阅读设置" : "外观设置")
    title.font = .preferredFont(forTextStyle: .title2); title.adjustsFontForContentSizeCategory = true
    title.numberOfLines = 0
    let close = button(kind == "choices" ? "取消" : "完成") { [weak self] in self?.done() }
    let header = UIStackView(arrangedSubviews: [title, close])
    header.spacing = 12; header.alignment = .center
    close.setContentHuggingPriority(.required, for: .horizontal)
    close.setContentCompressionResistancePriority(.required, for: .horizontal)
    stack.addArrangedSubview(header)
    if kind == "choices" {
      let choices = payload["choices"] as? [String] ?? []
      let selected = (payload["selected"] as? NSNumber)?.intValue ?? -1
      for (index, label) in choices.prefix(64).enumerated() {
        let item = button(label, selected: selected == index) { [weak self] in self?.finish(index) }
        item.accessibilityTraits = selected == index ? [.button, .selected] : [.button]
        stack.addArrangedSubview(item)
      }
    } else if kind == "reading" {
      fontSlider.minimumValue = 16; fontSlider.maximumValue = 26
      fontSlider.value = (payload["fontSize"] as? NSNumber)?.floatValue ?? 19
      fontSlider.accessibilityLabel = "字号"
      fontSlider.addTarget(self, action: #selector(fontChanged), for: .valueChanged)
      fontLabel.font = .preferredFont(forTextStyle: .body); fontChanged()
      stack.addArrangedSubview(fontLabel); stack.addArrangedSubview(fontSlider)
      let label = UILabel(); label.text = "纸张"; label.font = .preferredFont(forTextStyle: .body)
      stack.addArrangedSubview(label)
      paper.selectedSegmentIndex = (payload["sepia"] as? Bool ?? false) ? 1 : 0
      paper.accessibilityLabel = "纸张颜色"
      stack.addArrangedSubview(paper)
    } else {
      darkSwitch.isOn = payload["dark"] as? Bool ?? false
      motionSwitch.isOn = payload["reduceMotion"] as? Bool ?? false
      stack.addArrangedSubview(toggleRow("深色外观", darkSwitch))
      stack.addArrangedSubview(toggleRow("减少动态效果", motionSwitch))
    }
  }

  private func button(_ title: String, selected: Bool = false, action: @escaping () -> Void) -> UIButton {
    let result = NativeSheetButton(type: .system)
    if #available(iOS 15.0, *) {
      var configuration: UIButton.Configuration
      if #available(iOS 26.0, *) { configuration = .glass() } else { configuration = .tinted() }
      configuration.title = title
      configuration.baseForegroundColor = .label
      configuration.cornerStyle = .capsule
      configuration.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
      if selected { configuration.image = UIImage(systemName: "checkmark"); configuration.imagePlacement = .trailing; configuration.imagePadding = 10 }
      result.configuration = configuration
    } else { result.setTitle(title, for: .normal) }
    result.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    result.handler = action
    result.addTarget(result, action: #selector(NativeSheetButton.trigger), for: .touchUpInside)
    return result
  }
  private func toggleRow(_ title: String, _ control: UISwitch) -> UIView {
    let label = UILabel(); label.text = title; label.font = .preferredFont(forTextStyle: .body)
    label.adjustsFontForContentSizeCategory = true; label.numberOfLines = 0
    control.accessibilityLabel = title
    let row = UIStackView(arrangedSubviews: [label, control]); row.spacing = 16; row.alignment = .center
    row.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
    return row
  }
  @objc private func fontChanged() {
    fontSlider.value = fontSlider.value.rounded()
    fontLabel.text = "字号 \(Int(fontSlider.value))"
  }
  private func done() {
    if kind == "reading" { finish(["fontSize": Int(fontSlider.value), "sepia": paper.selectedSegmentIndex == 1]) }
    else if kind == "preferences" { finish(["dark": darkSwitch.isOn, "reduceMotion": motionSwitch.isOn]) }
    else { finish(nil) }
  }
  private func finish(_ value: Any?) {
    guard let callback = reply else { return }
    reply = nil
    dismiss(animated: !UIAccessibility.isReduceMotionEnabled && !(payload["reduceMotion"] as? Bool ?? false)) { callback(value) }
  }
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    guard let callback = reply else { return }; reply = nil; callback(nil)
  }
}

private final class NativeSheetButton: UIButton {
  var handler: (() -> Void)?
  @objc func trigger() { handler?() }
}
