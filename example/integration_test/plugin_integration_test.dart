import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:widgetkit_macos/widgetkit_macos.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('round-trips a value through the App Group', (tester) async {
    final kit = WidgetKitMacos(
      appGroup: 'group.com.ahmadre.widgetkitMacosExample',
    );
    expect(await kit.isSupported(), isTrue);
    await kit.saveWidgetData('message', 'hello');
    expect(await kit.getWidgetData<String>('message'), 'hello');
    await kit.saveWidgetData('message', null);
    expect(await kit.getWidgetData<String>('message'), isNull);
    await kit.reloadAllTimelines();
  });
}
