/// WidgetKit for Flutter on macOS: share data with a widget extension through
/// an App Group and ask WidgetKit to redraw it.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The size class of a widget on the desktop or in Notification Center.
enum WidgetFamily {
  systemSmall,
  systemMedium,
  systemLarge,
  systemExtraLarge,

  /// A family this version of the plugin does not know yet.
  unknown;

  static WidgetFamily _parse(Object? name) =>
      values.firstWhere((family) => family.name == name, orElse: () => unknown);
}

/// One widget the person has placed, as WidgetKit reports it.
@immutable
class WidgetConfiguration {
  const WidgetConfiguration({required this.kind, required this.family});

  /// The `kind` string of the widget's `WidgetConfiguration` in Swift.
  final String kind;
  final WidgetFamily family;

  @override
  bool operator ==(Object other) =>
      other is WidgetConfiguration &&
      other.kind == kind &&
      other.family == family;

  @override
  int get hashCode => Object.hash(kind, family);

  @override
  String toString() => 'WidgetConfiguration($kind, ${family.name})';
}

/// The bridge to WidgetKit for one App Group.
///
/// The app writes values into the App Group's `UserDefaults`, which the widget
/// extension reads in its timeline provider, and then reloads the widget's
/// timelines. Both the app and the extension need the App Group in their
/// entitlements, and the extension needs the App Sandbox.
///
/// Every call is a no-op answering null or empty when [isSupported] is false:
/// on any platform but macOS, and below macOS 11.
class WidgetKitMacos {
  WidgetKitMacos({
    required this.appGroup,
    @visibleForTesting MethodChannel? channel,
    @visibleForTesting bool? isMacOS,
  }) : _channel = channel ?? const MethodChannel('widgetkit_macos'),
       _isMacOS =
           isMacOS ??
           (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS);

  /// The App Group both the app and the widget extension belong to, such as
  /// `group.com.example.app`.
  final String appGroup;

  final MethodChannel _channel;
  final bool _isMacOS;

  /// Whether WidgetKit is there: macOS 11 or later.
  Future<bool> isSupported() async {
    if (!_isMacOS) return false;
    return await _channel.invokeMethod<bool>('isSupported') ?? false;
  }

  /// Stores [value] under [key] in the App Group's `UserDefaults`.
  ///
  /// [value] is a `String`, `bool`, `int` or `double`. Null removes the key,
  /// so the extension reads nothing rather than a null object.
  Future<void> saveWidgetData(String key, Object? value) async {
    if (value != null &&
        value is! String &&
        value is! bool &&
        value is! int &&
        value is! double) {
      throw ArgumentError.value(
        value,
        'value',
        'must be a String, bool, int or double',
      );
    }
    await _invoke<void>('saveWidgetData', {'key': key, 'value': value});
  }

  /// The value stored under [key], or null when there is none.
  Future<T?> getWidgetData<T>(String key) =>
      _invoke<T>('getWidgetData', {'key': key});

  /// Asks WidgetKit to redraw the widgets of one [kind].
  Future<void> reloadTimelines(String kind) =>
      _invoke<void>('reloadTimelines', {'kind': kind});

  /// Asks WidgetKit to redraw every widget of the app.
  Future<void> reloadAllTimelines() => _invoke<void>('reloadAllTimelines');

  /// The widgets of the app the person has placed. Empty until a widget is on
  /// the desktop or in Notification Center.
  Future<List<WidgetConfiguration>> currentConfigurations() async {
    final raw = await _invoke<List<Object?>>('currentConfigurations');
    return [
      for (final entry in raw ?? const <Object?>[])
        if (entry case {'kind': final String kind, 'family': final family})
          WidgetConfiguration(kind: kind, family: WidgetFamily._parse(family)),
    ];
  }

  Future<T?> _invoke<T>(String method, [Map<String, Object?>? args]) async {
    if (!_isMacOS) return null;
    return _channel.invokeMethod<T>(method, {'appGroup': appGroup, ...?args});
  }
}
