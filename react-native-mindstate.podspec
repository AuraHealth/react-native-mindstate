# react-native-mindstate.podspec

require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-mindstate"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.authors      = { "Your Name" => "your.email@example.com" }
  s.homepage     = "https://github.com/aurahealth/react-native-mindstate"
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com/aurahealth/react-native-mindstate.git", :tag => "v#{s.version}" }
  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true

  s.dependency "React-Core"

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_VERSION' => '5.0'
  }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  # Add HealthKit framework
  s.frameworks = 'HealthKit'
end
