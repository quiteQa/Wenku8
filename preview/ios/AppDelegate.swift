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
  private static var createdCount = 0

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    capabilityChannel = FlutterMethodChannel(name: "wenku8/native-glass", binaryMessenger: messenger)
    super.init()
    capabilityChannel.setMethodCallHandler { call, result in
      guard call.method == "capabilities" else {
        result(FlutterMethodNotImplemented)
        return
      }
      if #available(iOS 26.0, *) {
        result(["native": true, "liquidGlass": true, "backend": "UIGlassEffect"])
      } else {
        result(["native": true, "liquidGlass": false, "backend": "UIBlurEffect"])
      }
    }
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
    let view = NativeGlassView(frame: frame, arguments: args as? [String: Any] ?? [:],
                               id: viewId, messenger: messenger)
    Self.createdCount += 1
    #if WENKU_GLASS_VERIFICATION
    // A build-only receipt proves the screenshot used the real UIKit effect.
    // It contains no book content or user data and is absent in Release.
    let receipt: [String: Any] = [
      "effectClass": view.effectClass,
      "liquidGlass": view.isLiquidGlass,
      "createdViews": Self.createdCount,
      "systemVersion": UIDevice.current.systemVersion,
      "reduceTransparency": UIAccessibility.isReduceTransparencyEnabled
    ]
    if let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
       let data = try? JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys]) {
      try? data.write(to: directory.appendingPathComponent("native-glass-verification.json"), options: .atomic)
    }
    #endif
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
    let effect: UIVisualEffect
    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.isInteractive = false
      effect = glass
    } else {
      effect = UIBlurEffect(style: .systemThinMaterial)
    }
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
