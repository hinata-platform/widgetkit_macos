# widgetkit_macos

[WidgetKit](https://developer.apple.com/documentation/widgetkit) for Flutter
on macOS: share data with your widget extension through an App Group and ask
WidgetKit to redraw it. The widgets live on the desktop (macOS 14 and later)
and in Notification Center (macOS 11 and later).

[home_widget](https://pub.dev/packages/home_widget) covers iOS and Android;
this plugin is the macOS half, with the same idea: the app writes, the widget
reads.

```dart
final kit = WidgetKitMacos(appGroup: 'group.com.example.app');
if (await kit.isSupported()) {
  await kit.saveWidgetData('message', 'Hello from Flutter');
  await kit.reloadTimelines('MessageWidget');
}
```

| Call | What it does |
| --- | --- |
| `saveWidgetData(key, value)` | Stores a `String`, `bool`, `int` or `double` in the App Group's `UserDefaults`. Null removes the key. |
| `getWidgetData<T>(key)` | Reads a value back, or null. |
| `reloadTimelines(kind)` | Redraws the widgets of one kind. |
| `reloadAllTimelines()` | Redraws every widget of the app. |
| `currentConfigurations()` | The widgets the person has placed, with their kind and family. |

On any other platform, and below macOS 11, `isSupported()` is false and every
other call does nothing.

## Setup

1. **Add a widget extension** in Xcode: open `macos/Runner.xcworkspace`, File →
   New → Target → macOS → Widget Extension. Set its deployment target to the
   oldest macOS you want widgets on (14 for the desktop).
2. **Give the extension the App Sandbox.** Without it macOS never lists the
   widget in the gallery.
3. **Add the same App Group to both targets**, the Runner and the extension
   (Signing & Capabilities → App Groups), in `DebugProfile.entitlements`,
   `Release.entitlements` and the extension's entitlements. A `group.` App
   Group needs a provisioning profile that contains it; ad-hoc signing
   ("Sign to Run Locally") cannot carry one.
4. **Read the value in the widget's timeline provider:**

```swift
let defaults = UserDefaults(suiteName: "group.com.example.app")
let message = defaults?.string(forKey: "message") ?? ""
```

The widget appears in the gallery only after the app has been launched once.

`example/` has a complete app with its extension (`example/macos/ExampleWidgets`).
Set your team on both targets to run it; CI builds it without signing.

## Privacy

The plugin reads and writes only the App Group you name. Its privacy manifest
declares `UserDefaults` with reason `1C8F.1`; your extension needs the same
entry in its own manifest.
