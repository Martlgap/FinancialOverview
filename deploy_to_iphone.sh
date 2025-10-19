#!/bin/bash

<<<<<<< HEAD
# Deploy PortfolioOverview app to iPhone
=======
# Deploy FinancialOverview app to iPhone
>>>>>>> fdb7472 (Working State)
# Make sure your iPhone is connected and trusted

DEVICE_ID="00008110-0012031C1110401E"

<<<<<<< HEAD
echo "🏗️ Building PortfolioOverview for iPhone..."

# Build the project for iPhone
xcodebuild -project PortfolioOverview.xcodeproj \
           -scheme PortfolioOverview \
=======
echo "🏗️ Building FinancialOverview for iPhone..."

# Build the project for iPhone
xcodebuild -project FinancialOverview.xcodeproj \
           -scheme FinancialOverview \
>>>>>>> fdb7472 (Working State)
           -destination "platform=iOS,id=$DEVICE_ID" \
           -configuration Debug \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    echo "📱 Installing app on iPhone..."
    
    # Get the build products directory from xcodebuild
    BUILD_DIR=$(xcodebuild -project FinancialOverview.xcodeproj -scheme FinancialOverview -destination "platform=iOS,id=$DEVICE_ID" -showBuildSettings | grep -m 1 "BUILT_PRODUCTS_DIR" | awk '{print $3}')
    
    # Install the app on the connected iPhone
    xcrun devicectl device install app \
        --device $DEVICE_ID \
<<<<<<< HEAD
<<<<<<< HEAD
        "/Users/martinknoche/Library/Developer/Xcode/DerivedData/PortfolioOverview-axycpsnnawmogygxvgpnjlrywwqw/Build/Products/Debug-iphoneos/PortfolioOverview.app"
    
    if [ $? -eq 0 ]; then
        echo "🎉 App successfully deployed to iPhone!"
        echo "💡 You can now launch 'PortfolioOverview' on your iPhone"
=======
        "/Users/martinknoche/Library/Developer/Xcode/DerivedData/FinancialOverview-axycpsnnawmogygxvgpnjlrywwqw/Build/Products/Debug-iphoneos/FinancialOverview.app"
=======
        "$BUILD_DIR/FinancialOverview.app"
>>>>>>> f056bee (Nice and clean state)
    
    if [ $? -eq 0 ]; then
        echo "🎉 App successfully deployed to iPhone!"
        echo "💡 You can now launch 'FinancialOverview' on your iPhone"
>>>>>>> fdb7472 (Working State)
    else
        echo "❌ Failed to install app on iPhone"
        exit 1
    fi
else
    echo "❌ Build failed"
    exit 1
<<<<<<< HEAD
fi
=======
fi 
>>>>>>> fdb7472 (Working State)
