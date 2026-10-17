import FlutterMacOS
import Foundation
import WidgetKit

/// WidgetKit for Flutter on macOS: the App Group's `UserDefaults` and
/// `WidgetCenter`.
public final class WidgetkitMacosPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "widgetkit_macos", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(WidgetkitMacosPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    if call.method == "isSupported" {
      if #available(macOS 11.0, *) { result(true) } else { result(false) }
      return
    }
    guard #available(macOS 11.0, *) else {
      result(FlutterError(code: "unsupported", message: "WidgetKit needs macOS 11", details: nil))
      return
    }
    switch call.method {
    case "saveWidgetData":
      guard let defaults = Self.defaults(args, result), let key = args["key"] as? String else { return }
      // Null removes the key. Only plist scalars are stored: UserDefaults
      // throws on NSNull, and on anything nested that could carry one.
      switch args["value"] {
      case nil, is NSNull:
        defaults.removeObject(forKey: key)
      case let value as String:
        defaults.set(value, forKey: key)
      case let value as NSNumber:
        defaults.set(value, forKey: key)
      default:
        result(FlutterError(code: "bad-args", message: "value must be a scalar", details: nil))
        return
      }
      result(nil)
    case "getWidgetData":
      guard let defaults = Self.defaults(args, result), let key = args["key"] as? String else { return }
      result(defaults.object(forKey: key))
    case "reloadTimelines":
      guard let kind = args["kind"] as? String else {
        result(FlutterError(code: "bad-args", message: "kind is missing", details: nil))
        return
      }
      WidgetCenter.shared.reloadTimelines(ofKind: kind)
      result(nil)
    case "reloadAllTimelines":
      WidgetCenter.shared.reloadAllTimelines()
      result(nil)
    case "currentConfigurations":
      WidgetCenter.shared.getCurrentConfigurations { outcome in
        let answer: Any
        switch outcome {
        case .success(let infos):
          answer = infos.map { ["kind": $0.kind, "family": Self.name(of: $0.family)] }
        case .failure(let error):
          answer = FlutterError(
            code: "widgetcenter", message: error.localizedDescription, details: nil)
        }
        DispatchQueue.main.async { result(answer) }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// The App Group's defaults, or an error answered when there are none: the
  /// group is missing from the call or from the app's entitlements.
  private static func defaults(_ args: [String: Any], _ result: FlutterResult) -> UserDefaults? {
    guard let group = args["appGroup"] as? String, let defaults = UserDefaults(suiteName: group)
    else {
      result(FlutterError(code: "app-group", message: "No defaults for the App Group", details: nil))
      return nil
    }
    return defaults
  }

  @available(macOS 11.0, *)
  private static func name(of family: WidgetFamily) -> String {
    switch family {
    case .systemSmall: return "systemSmall"
    case .systemMedium: return "systemMedium"
    case .systemLarge: return "systemLarge"
    case .systemExtraLarge: return "systemExtraLarge"
    default: return "unknown"
    }
  }
}
