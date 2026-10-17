import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetkit_macos/widgetkit_macos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('widgetkit_macos');
  final calls = <MethodCall>[];
  Object? Function(MethodCall call) answer = (_) => null;
  bool? supported = true;

  setUp(() {
    calls.clear();
    answer = (_) => null;
    // macOS 11 or later unless a test says otherwise.
    supported = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isSupported') return supported;
          calls.add(call);
          return answer(call);
        });
  });

  WidgetKitMacos kit({bool isMacOS = true}) =>
      WidgetKitMacos(appGroup: 'group.test', isMacOS: isMacOS);

  test('every call names the App Group', () async {
    await kit().saveWidgetData('record', 'value');
    await kit().getWidgetData<String>('record');
    await kit().reloadTimelines('TimerWidget');
    await kit().reloadAllTimelines();

    expect(calls.map((c) => c.method), [
      'saveWidgetData',
      'getWidgetData',
      'reloadTimelines',
      'reloadAllTimelines',
    ]);
    expect(
      calls.map((c) => (c.arguments as Map)['appGroup']),
      everyElement('group.test'),
    );
    expect(calls.first.arguments, {
      'appGroup': 'group.test',
      'key': 'record',
      'value': 'value',
    });
    expect((calls[2].arguments as Map)['kind'], 'TimerWidget');
  });

  test('null is sent as a removal, not stored', () async {
    await kit().saveWidgetData('record', null);

    expect((calls.single.arguments as Map)['value'], isNull);
  });

  test('only plist scalars are accepted', () async {
    for (final value in ['a', true, 1, 1.5]) {
      await kit().saveWidgetData('k', value);
    }
    expect(
      () => kit().saveWidgetData('k', const <String>['a']),
      throwsArgumentError,
    );
    expect(calls, hasLength(4));
  });

  test('reads back what the platform answers', () async {
    answer = (_) => 'stored';

    expect(await kit().getWidgetData<String>('record'), 'stored');
  });

  test('parses the placed widgets, unknown families included', () async {
    answer = (_) => [
      {'kind': 'TimerWidget', 'family': 'systemSmall'},
      {'kind': 'TimerWidget', 'family': 'accessoryCorner'},
      {'family': 'systemMedium'},
    ];

    expect(await kit().currentConfigurations(), const [
      WidgetConfiguration(
        kind: 'TimerWidget',
        family: WidgetFamily.systemSmall,
      ),
      WidgetConfiguration(kind: 'TimerWidget', family: WidgetFamily.unknown),
    ]);
  });

  test('off macOS nothing reaches the platform', () async {
    final other = kit(isMacOS: false);

    expect(await other.isSupported(), isFalse);
    await other.saveWidgetData('record', 'value');
    await other.reloadAllTimelines();
    expect(await other.getWidgetData<String>('record'), isNull);
    expect(await other.currentConfigurations(), isEmpty);
    expect(calls, isEmpty);
  });

  test('below macOS 11 every call is a no-op, as off macOS', () async {
    supported = false;
    final old = kit();

    expect(await old.isSupported(), isFalse);
    await old.saveWidgetData('record', 'value');
    await old.reloadTimelines('TimerWidget');
    expect(await old.currentConfigurations(), isEmpty);
    expect(calls, isEmpty);
  });
}
