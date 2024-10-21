// react-native-mindstate.podspec
require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-mindstate"
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.authors      = package['author']

  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/aurahealth/react-native-mindstate.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"

  # Specify minimum deployment target
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end

// ios/RNMindState-Bridging-Header.h
#import <React/RCTBridgeModule.h>

// ios/RNMindState.xcodeproj/project.pbxproj
// Basic Xcode project structure
{
  "objects": {
    "YOURPROJECTID": {
      "isa": "PBXProject",
      "attributes": {
        "LastUpgradeCheck": "1300",
        "ORGANIZATIONNAME": "YourOrganization"
      },
      "buildConfigurationList": "YOURCONFIGID",
      "compatibilityVersion": "Xcode 13.0",
      "developmentRegion": "en",
      "hasScannedForEncodings": 0,
      "knownRegions": [
        "en",
        "Base"
      ],
      "mainGroup": "YOURGROUPID",
      "productRefGroup": "YOURPRODUCTGROUPID",
      "projectDirPath": "",
      "projectRoot": "",
      "targets": [
        {
          "isa": "PBXNativeTarget",
          "name": "RNMindState",
          "productName": "RNMindState"
        }
      ]
    }
  }
}
