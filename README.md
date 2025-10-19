# FinancialOverview

## Overview
A SwiftUI-based iOS portfolio tracking application that helps users manage and monitor their financial assets across multiple categories including cryptocurrencies, stocks, ETFs, and raw materials. The app provides real-time price updates, portfolio analytics, and data management features with a modern dark theme interface.

## ✅ Implemented Features

### 📱 User Interface
- **Two-tab interface**: Overview and Settings
- **Dark theme design** with gradient accents and modern styling
- **Responsive layout** with smart decimal formatting for asset amounts
- **Pull-to-refresh** functionality for manual price updates
- **Expandable sections** for better organization

### 📊 Overview Tab
- **Total portfolio value display** with prominent gradient styling
- **Asset categorization** by class (Raw Materials, Cryptocurrencies, Stocks, ETFs)
- **Expandable asset class sections** showing totals, percentages, and individual assets
- **Asset management** with tap-to-edit functionality
- **Add new assets** with comprehensive form
- **Delete assets** with swipe-to-delete gesture
- **Visual indicators** with appropriate icons for each asset class

### ⚙️ Settings Tab
- **Currency selection** (USD/EUR) with segmented picker
- **CSV Import/Export** functionality for portfolio data
- **Version information** display
- **Data management** with file picker integration

### 🏗️ Data Architecture
- **Local persistence** using UserDefaults with JSON encoding
- **MVVM architecture** with Observable view models
- **Real-time updates** using async/await patterns
- **Complete asset replacement** during import (overwrites existing data)
- **Sample data** provided for new users

### 💰 Asset Management
- **Four asset classes** supported:
  - Raw Materials (e.g., Gold - XAU, Silver - XAG)
  - Cryptocurrencies (e.g., BTC, ETH)
  - Stocks (using ISIN codes)
  - ETFs (using ISIN codes)
- **Flexible quantity tracking** with smart decimal display
- **Real-time price fetching** from multiple API sources
- **Asset deduplication** when adding existing assets

### 🌐 API Integration
- **CryptoCompare API** for cryptocurrency prices
- **JustETF API** for ETF and stock pricing via ISIN
- **SwissQuote API** for raw material prices
- **Multi-currency support** (USD/EUR)
- **Error-resilient** network requests with proper error handling

### 📊 Data Import/Export
- **CSV Export** with proper formatting and quotes
- **CSV Import** with validation and error handling
- **Asset replacement** during import (overwrites all existing assets)
- **File picker integration** for iOS document handling

### 🛠️ Technical Implementation
- **SwiftUI** with modern @Observable pattern
- **Async/await** for all network operations
- **Type-safe** models with Codable support
- **Error handling** throughout the application
- **iOS 17+** compatibility with latest SwiftUI features

## 📁 Project Structure

```
FinancialOverview/
├── FinancialOverviewApp.swift     # App entry point
├── ContentView.swift              # Main tab container
├── Models/
│   ├── Asset.swift                # Core asset data model
│   ├── AssetClass.swift           # Asset category enumeration
│   └── Currency.swift             # Currency enumeration
├── Services/
│   └── APIService.swift           # Network service for price fetching
├── ViewModels/
│   └── AssetViewModel.swift       # Main app state management
└── Views/
    ├── OverviewView.swift         # Portfolio overview interface
    ├── SettingsView.swift         # Settings and data management
    └── AssetEditView.swift        # Asset creation/editing form
```

## 🚀 Build & Run Instructions

### Using Xcode (Recommended)
1. Open `FinancialOverview.xcodeproj` in Xcode 15.0+
2. Select your target device (iPhone simulator or physical device)
3. Build and run: ⌘+R

### Using Command Line
The project includes automated deployment scripts:

**For iOS Simulator:**
```bash
./deploy_to_simulator.sh
```

**For Physical iPhone:**
```bash
./deploy_to_iphone.sh
```

**Build and Install Script:**
```bash
./build_and_install.sh
```

## 🧪 Testing

The project includes API testing functionality:

**Run API Tests:**
```bash
./test_api_services.sh
```

Or compile and run the test runner:
```bash
swift APIServiceTests.swift
```

## � Data Management

### CSV Format
The app supports CSV import/export with the following format:
```csv
Asset Class,Code,Name,Amount
"Cryptocurrencies","BTC","Bitcoin",0.5
"Stocks","US0378331005","Apple",100
"ETFs","IE00B5BMR087","iShares Core MSCI World",50
"Raw Materials","XAU","Gold",2
```

### Sample Data
New installations include sample data:
- Bitcoin (0.5 BTC)
- Ethereum (10 ETH)
- Apple Stock (100 shares)
- iShares Core MSCI World ETF (50 shares)
- Gold (2 ounces)

## 🔮 Future Enhancements

- **Advanced portfolio analytics** with performance charts
- **Price alerts** and notifications
- **More asset classes** (bonds, real estate, etc.)
- **Portfolio diversification analysis**
- **Historical price charts**
- **Advanced filtering and search**
- **Cloud sync** capabilities
- **Multiple portfolio support**

## �️ Development Setup

### Requirements
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### API Configuration
The app currently uses public APIs:
- **CryptoCompare**: No API key required for basic usage
- **JustETF**: Public API endpoints
- **SwissQuote**: Public quotes endpoint

For production use, consider implementing proper API authentication and rate limiting.

## 📋 Architecture Notes

- **Reactive UI**: Uses SwiftUI's @Observable for automatic UI updates
- **Error Resilience**: Graceful handling of network failures
- **Data Persistence**: UserDefaults for simplicity, easily extensible to Core Data
- **Modular Design**: Clear separation between models, views, and services
- **iOS Guidelines**: Follows Apple's Human Interface Guidelines

The app provides a solid foundation for personal portfolio tracking with room for advanced features and enterprise-grade enhancements.
