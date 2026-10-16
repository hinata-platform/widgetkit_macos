import SwiftUI
import WidgetKit

/// Reads the message the Flutter app stored with `saveWidgetData`.
struct MessageEntry: TimelineEntry {
  let date: Date
  let message: String
}

struct MessageProvider: TimelineProvider {
  /// The App Group in both targets' entitlements.
  private let defaults = UserDefaults(suiteName: "group.com.ahmadre.widgetkitMacosExample")

  private func entry() -> MessageEntry {
    MessageEntry(date: .now, message: defaults?.string(forKey: "message") ?? "Nothing sent yet")
  }

  func placeholder(in context: Context) -> MessageEntry {
    MessageEntry(date: .now, message: "Hello from Flutter")
  }

  func getSnapshot(in context: Context, completion: @escaping (MessageEntry) -> Void) {
    completion(entry())
  }

  // One entry and no refresh of its own: the app reloads the timeline after
  // each write.
  func getTimeline(in context: Context, completion: @escaping (Timeline<MessageEntry>) -> Void) {
    completion(Timeline(entries: [entry()], policy: .never))
  }
}

struct ExampleWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "ExampleWidget", provider: MessageProvider()) { entry in
      Text(entry.message)
        .font(.headline)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Example")
    .description("Shows the message the app sent last.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

@main
struct ExampleWidgets: WidgetBundle {
  var body: some Widget {
    ExampleWidget()
  }
}
