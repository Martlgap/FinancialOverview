#!/bin/bash

# Deploy FinancialOverview app to iOS Simulator
# This script will build and install the app on the iOS Simulator

SIMULATOR_NAME="iPhone SE"
OS_VERSION="18.6"

echo "🏗️ Building FinancialOverview for iOS Simulator..."

# Build the project for iOS Simulator
xcodebuild -project FinancialOverview.xcodeproj \
           -scheme FinancialOverview \
           -destination "platform=iOS Simulator,name=$SIMULATOR_NAME",OS=$OS_VERSION \
           -configuration Debug \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    echo "📱 Starting iOS Simulator..."
    
    # Boot the simulator (if not already running)
    xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
    
    # Open Simulator app
    open -a Simulator
    
    # Wait a moment for simulator to be ready
    sleep 2
    
    echo "📲 Installing app on iOS Simulator..."
    
    # Get the build products directory from xcodebuild
    BUILD_DIR=$(xcodebuild -project FinancialOverview.xcodeproj -scheme FinancialOverview -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$OS_VERSION" -showBuildSettings | grep -m 1 "BUILT_PRODUCTS_DIR" | awk '{print $3}')
    
    # Install the app on the simulator
    xcrun simctl install "$SIMULATOR_NAME" "$BUILD_DIR/FinancialOverview.app"
    
    if [ $? -eq 0 ]; then
        echo "🎉 App successfully deployed to iOS Simulator!"
        
        # Optional: Launch the app automatically
        echo "🚀 Launching FinancialOverview..."
        xcrun simctl launch "$SIMULATOR_NAME" MK.FinancialOverview 2>/dev/null || {
            echo "💡 App installed successfully. You can now launch 'FinancialOverview' manually from the simulator."
        }
    else
        echo "❌ Failed to install app on iOS Simulator"
        exit 1
    fi
else
    echo "❌ Build failed"
    exit 1
fi