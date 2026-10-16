import 'package:flutter/material.dart';
import 'package:widgetkit_macos/widgetkit_macos.dart';

/// The App Group in the entitlements of both the app and `ExampleWidgets`.
const appGroup = 'group.com.ahmadre.widgetkitMacosExample';

/// The `kind` of the example widget in `ExampleWidgets/ExampleWidget.swift`.
const widgetKind = 'ExampleWidget';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'widgetkit_macos',
    theme: ThemeData(colorSchemeSeed: Colors.amber),
    home: const ExamplePage(),
  );
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _kit = WidgetKitMacos(appGroup: appGroup);
  final _message = TextEditingController(text: 'Hello from Flutter');
  String _placed = '';

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    await _kit.saveWidgetData('message', _message.text);
    await _kit.reloadTimelines(widgetKind);
    final placed = await _kit.currentConfigurations();
    setState(() {
      _placed = placed.isEmpty
          ? 'No widget placed yet. Add "Example" from the widget gallery.'
          : placed.map((c) => '${c.kind} (${c.family.name})').join(', ');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('widgetkit_macos')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _message,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _send,
            child: const Text('Send to the widget'),
          ),
          const SizedBox(height: 16),
          Text(_placed),
        ],
      ),
    ),
  );
}
