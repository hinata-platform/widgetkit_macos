// swift-tools-version: 6.0
// Tools 6.0, not 5.9: under the CI's Xcode a 5.9 manifest did not resolve, and
// Flutter fell back to CocoaPods without saying so. Swift 5 language mode:
// FlutterMacOS exports FlutterMethodNotImplemented as a mutable global, which
// Swift 6 refuses to read.

import PackageDescription

let package = Package(
  name: "widgetkit_macos",
  platforms: [
    .macOS("10.15")
  ],
  products: [
    .library(name: "widgetkit-macos", targets: ["widgetkit_macos"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    .target(
      name: "widgetkit_macos",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework")
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    )
  ],
  swiftLanguageModes: [.v5]
)
