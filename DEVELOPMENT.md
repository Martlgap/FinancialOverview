````markdown
## Build Instructions

### For iOS Simulator:

**Deploy to Simulator:**
```shell
./deploy_to_simulator.sh
```

**Manual commands:**
1. List available simulators:
```shell
xcrun simctl list devices
```

2. Open the simulator for iPhone SE (or any other device you prefer):
```shell
open -a Simulator --args -CurrentDeviceUDID E48587B5-1D7D-4D30-BD82-9BEC32AD232D
```

3. Build for ios Simulator:
```shell
xcodebuild -project FinancialOverview.xcodeproj -scheme FinancialOverview -destination 'platform=iOS Simulator,name=iPhone SE,OS=26.0' build
```

3. Install on Simulator:
```shell
xcrun simctl install "iPhone SE" ~/Library/Developer/Xcode/DerivedData/FinancialOverview-axycpsnnawmogygxvgpnjlrywwqw/Build/Products/Debug-iphonesimulator/FinancialOverview.app
```

4. Launch on Simulator:
```shell
xcrun simctl launch "iPhone SE" MK.FinancialOverview
```

### For Physical iPhone Device:

**Deploy to iPhone:**
```shell
./deploy_to_iphone.sh
```

**Manual commands:**
1. Check connected devices:
   ```shell
   xcrun xctrace list devices
   ```

2. Build for iPhone:
   ```shell
   xcodebuild -project FinancialOverview.xcodeproj -scheme FinancialOverview -destination 'platform=iOS,id=00008110-0012031C1110401E' -configuration Debug build
   ```

3. Install on iPhone:
   ```shell
   xcrun devicectl device install app --device 00008110-0012031C1110401E "/Users/martinknoche/Library/Developer/Xcode/DerivedData/FinancialOverview-axycpsnnawmogygxvgpnjlrywwqw/Build/Products/Debug-iphoneos/FinancialOverview.app"
   ```
