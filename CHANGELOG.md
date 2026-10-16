## 0.1.0

- Share data with a macOS widget extension through an App Group:
  `saveWidgetData` (null removes the key) and `getWidgetData`.
- Reload widgets through WidgetCenter: `reloadTimelines` and
  `reloadAllTimelines`.
- List the placed widgets: `currentConfigurations`.
- Swift Package Manager and CocoaPods; macOS 10.15 and later, WidgetKit from
  macOS 11 on (`isSupported`).
