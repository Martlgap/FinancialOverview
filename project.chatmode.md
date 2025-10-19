# Overview

This is a native iOS SwiftUI application designed to track and visualize investment portfolios across multiple asset classes. The app supports cryptocurrencies, ETFs, stocks, precious metals, and other financial instruments, providing real-time price updates and portfolio analytics. It features a dark theme design with a clean, modern interface optimized for portfolio management and asset tracking.

# Tabs

The application is structured around a three-tab interface:

## Portfolio Tab (Primary)

Main Dashboard: Displays total portfolio value in a prominent summary card with gradient background
Holdings List: Organized by asset categories (ETF, Shares, Cryptos, Raw Materials, Other) in expandable sections
Category Navigation: Each category shows total value and allows drilling down to individual assets
Pull-to-Refresh: Enables manual price updates for all holdings
Empty State: Shows helpful guidance when no assets are present
Add Asset Button: Plus button in navigation bar to add new holdings

## Distribution Tab

Pie Chart Visualization: Interactive donut chart showing portfolio allocation by individual assets
Asset Details: Tapping segments reveals detailed asset information
Category Breakdown: Displays percentage and value of each asset category
Custom Color Palette: Uses a predefined color scheme for visual clarity
Responsive Design: Automatically adjusts for different portfolio sizes

## Settings Tab

Currency Selection: Toggle between USD and EUR display currencies
Simple Configuration: Minimal settings focused on essential preferences

# API Interfaces

The app integrates with multiple financial data providers for comprehensive asset coverage:

## CoinGecko API

Purpose: Cryptocurrency price data and coin resolution
Functionality: Resolves crypto symbols to coin IDs, fetches USD prices
Search: Symbol-based search with market cap ranking prioritization

## JustETF API

Purpose: ISIN-based ETF and fund pricing
Functionality: Fetches USD quotes for 12-character ISIN codes
Coverage: European and international ETFs/funds

## MetalsPriceClient

Purpose: Precious metals pricing (Gold - XAU, Silver - XAG)
Functionality: Real-time USD prices for commodity assets

## ETFPriceClient (Yahoo Finance)

Purpose: WKN-based ETF resolution and pricing
Functionality: Resolves 6-character WKN codes to tickers, fetches USD prices

## FinnhubClient

Purpose: Asset metadata and ISIN validation
Functionality: Provides descriptions and company information for ISIN assets

## Exchange Rate Service

Purpose: Currency conversion (USD to EUR)
Functionality: Real-time exchange rates for multi-currency support

Settings
The settings interface is deliberately minimal and focused:

Currency Selection: Segmented control for USD/EUR switching
Persistent Storage: Automatic saving of currency preference
Real-time Updates: Immediate application of currency changes across the app
Future Extensibility: Form-based structure allows for easy addition of new settings

# Design

## Visual Theme

Dark Mode: Forced dark appearance with .preferredColorScheme(.dark)
Color Scheme: Cyan accent color throughout the interface
Material Design: Uses .ultraThinMaterial backgrounds for depth
Card-based Layout: Rounded rectangles with subtle shadows and gradients

## Typography

Hierarchy: Clear font size progression from .largeTitle to .caption
Monospaced Numbers: Financial values use .monospacedDigit() for alignment
Weight Variation: Strategic use of .bold() and .semibold() for emphasis

## Layout Principles

Spacing Consistency: 16-18px standard spacing between major elements
Information Density: Balanced presentation of financial data without clutter
Touch Targets: Appropriately sized buttons and interactive elements
Responsive Design: Adapts to different screen sizes and content amounts

## User Experience

Loading States: Progress indicators during async operations
Error Handling: Alert dialogs for API failures and validation errors
Haptic Feedback: Standard iOS interactions with accessibility labels
Pull-to-Refresh: Intuitive gesture for data updates
General

## Asset Support

Cryptocurrencies: Symbol-based lookup via CoinGecko
ETFs: ISIN (12-char) and WKN (6-char) support
Stocks: Generic symbol resolution
Precious Metals: Direct XAU/XAG support
Categories: User-defined categorization for organization

## Data Management

Local Persistence: UserDefaults-based storage with Base64 encoding
Migration Support: Automatic data structure updates for new features
Real-time Updates: Async/await pattern for modern concurrency
Error Resilience: Graceful handling of network failures

## Technical Architecture

MVVM Pattern: Clean separation with PortfolioViewModel as central coordinator
SwiftUI: Modern declarative UI with state management
Combine Framework: Reactive programming for currency selection
Concurrent Processing: Async/await for all network operations
Type Safety: Strong typing with enums and structured data models
The application represents a comprehensive portfolio tracking solution with professional-grade financial data integration, modern iOS design patterns, and a focus on user experience and data accuracy.

# Goals

Implement the app and include tests for all major components and features. Test all API integrations separately to ensure modularity and easy exchange if data providers change. Use SwiftUI and Combine for reactive programming and state management. Ensure the app is responsive and works well on different iOS devices.

# General

Store the data locally on the phone using UserDefaults or CoreData, depending on the complexity of the data structure. Use Base64 encoding for any complex data types to ensure compatibility with UserDefaults.


-> TODO HERE: Completely rework the API calls -> specifiy the api adress and the purpose of the API call. 

