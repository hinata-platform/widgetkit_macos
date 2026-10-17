Pod::Spec.new do |s|
  s.name             = 'widgetkit_macos'
  s.version          = '0.1.1'
  s.summary          = 'WidgetKit for Flutter on macOS.'
  s.description      = <<-DESC
Share data with a macOS widget extension through an App Group and reload its
timelines through WidgetCenter.
                       DESC
  s.homepage         = 'https://github.com/hinata-platform/widgetkit_macos'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rebar Ahmad' => 'rebar.ahmad@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'widgetkit_macos/Sources/widgetkit_macos/**/*.swift'
  s.resource_bundles = { 'widgetkit_macos_privacy' => ['widgetkit_macos/Sources/widgetkit_macos/PrivacyInfo.xcprivacy'] }
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.15'
  # WidgetKit exists from macOS 11 on; below that the plugin answers "unsupported".
  s.weak_frameworks = 'WidgetKit'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
