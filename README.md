# Installation

Install the package:
`npm install react-native-mindstate` or
`yarn add react-native-mindstate`

# For iOS, add the required privacy description to your Info.plist:

```xml
<key>NSHealthShareUsageDescription</key>
<string>We need access to your health data to track your state of mind</string>
```

# Link the native module (for React Native < 0.60):

`react-native link react-native-mindstate`

# For iOS, install pods:

`cd ios && pod install`

# Example Usage

```js
import MindState from "react-native-mindstate";

// Check availability
const checkAvailability = async () => {
  try {
    const isAvailable = await MindState.isAvailable();
    console.log("Mind State tracking available:", isAvailable);
  } catch (error) {
    console.error("Error checking availability:", error);
  }
};

// Request authorization
const requestAuth = async () => {
  try {
    const authorized = await MindState.requestAuthorization();
    console.log("Authorization granted:", authorized);
  } catch (error) {
    console.error("Error requesting authorization:", error);
  }
};

// Query mind states
const queryStates = async () => {
  try {
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 7); // Last 7 days

    const mindStates = await MindState.queryMindStates({
      startDate,
      endDate,
      mood: "great", // Optional mood filter
      limit: 10, // Optional limit
    });

    console.log("Mind states:", mindStates);
  } catch (error) {
    console.error("Error querying mind states:", error);
  }
};
```

# If you encounter build issues

```sh
# Clean and reinstall pods
cd ios
pod deintegrate
pod cache clean --all
rm -rf ~/Library/Developer/Xcode/DerivedData/*
pod install

# If using M1 Mac
arch -x86_64 pod install
```

# For Swift version mismatches, add to your Podfile:

```sh
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
```
