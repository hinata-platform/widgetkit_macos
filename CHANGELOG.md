## 0.1.1

- Below macOS 11 every call is the no-op the documentation promised, instead
  of a `PlatformException`. `isSupported` is asked once.
- The native side stores only strings, numbers and booleans and refuses
  anything else with `bad-args`, so nothing nested can carry an `NSNull` into
  `UserDefaults`.
- The example's native tests check the removal on null and the refusals.
- Publishing: the OIDC token exists only in the publish step.

## 0.1.0

- Share data with a macOS widget extension through an App Group:
  `saveWidgetData` (null removes the key) and `getWidgetData`.
- Reload widgets through WidgetCenter: `reloadTimelines` and
  `reloadAllTimelines`.
- List the placed widgets: `currentConfigurations`.
- Swift Package Manager and CocoaPods; macOS 10.15 and later, WidgetKit from
  macOS 11 on (`isSupported`).
