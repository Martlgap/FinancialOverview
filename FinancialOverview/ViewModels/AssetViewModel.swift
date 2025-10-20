import Foundation
import Observation
import SwiftUI

@Observable
class AssetViewModel {
    var assets: [Asset] = [] {
        didSet {
            saveAssets()
        }
    }
    var selectedCurrency: Currency = .eur {
        didSet {
            Task {
                await refreshData()
            }
        }
    }
    var lastUpdated: Date?
    var privacyModeManager = PrivacyModeManager()
    var assetClassSettings = AssetClassSettingsManager()

    private let apiService = APIService()
    private let userDefaultsKey = "savedAssets"

    init() {
        loadAssets()
        if assets.isEmpty {
            loadSampleData()
        }
        Task {
            await refreshData()
        }
    }

    var totalSum: Double {
        assets.filter { assetClassSettings.isEnabled($0.assetClass) }.reduce(0) { $0 + $1.sum }
    }
    
    var totalValue: Double {
        totalSum // Alias for compatibility with PlanManager
    }
    
    var assetClassDistribution: [AssetClass: Double] {
        var distribution: [AssetClass: Double] = [:]
        for assetClass in assetClassSettings.enabledClasses {
            distribution[assetClass] = percentage(for: assetClass)
        }
        return distribution
    }
    
    var riskCategoryDistribution: [AssetCategory: Double] {
        var distribution: [AssetCategory: Double] = [:]
        for category in AssetCategory.allCases {
            distribution[category] = percentage(for: category)
        }
        return distribution
    }

    func assets(for assetClass: AssetClass) -> [Asset] {
        guard assetClassSettings.isEnabled(assetClass) else { return [] }
        return assets.filter { $0.assetClass == assetClass }
    }
    
    func assets(for category: AssetCategory) -> [Asset] {
        assets.filter { $0.category == category && assetClassSettings.isEnabled($0.assetClass) }
    }

    func sum(for assetClass: AssetClass) -> Double {
        assets(for: assetClass).reduce(0) { $0 + $1.sum }
    }
    
    func sum(for category: AssetCategory) -> Double {
        assets(for: category).reduce(0) { $0 + $1.sum }
    }

    func percentage(for assetClass: AssetClass) -> Double {
        let classSum = sum(for: assetClass)
        return totalSum > 0 ? (classSum / totalSum) * 100 : 0
    }
    
    func percentage(for category: AssetCategory) -> Double {
        let categorySum = sum(for: category)
        return totalSum > 0 ? (categorySum / totalSum) * 100 : 0
    }
    
    func percentage(for asset: Asset) -> Double {
        return totalSum > 0 ? (asset.sum / totalSum) * 100 : 0
    }

    func refreshData() async {
        var updatedAssets = self.assets
        for i in 0..<updatedAssets.count {
            let asset = updatedAssets[i]
            do {
                var price: Double?
                switch asset.assetClass {
                case .rawMaterials:
                    price = try await apiService.fetchRawMaterialPrice(material: asset.code, currency: selectedCurrency.rawValue)
                case .cryptocurrencies:
                    price = try await apiService.fetchCryptoPriceCryptoCompare(symbol: asset.code, currency: selectedCurrency.rawValue)
                case .stocks, .etfs:
                    price = try await apiService.fetchStockOrETFPrice(isin: asset.code, currency: selectedCurrency.rawValue)
                }
                updatedAssets[i].currentPrice = price
            } catch {
                print("Error fetching price for \(asset.name): \(error)")
            }
        }
        
        DispatchQueue.main.async {
            self.assets = updatedAssets
            self.lastUpdated = Date()
        }
    }

    func addAsset(_ asset: Asset) {
        // Check if an asset with the same code and asset class already exists
        if let existingIndex = assets.firstIndex(where: { $0.code == asset.code && $0.assetClass == asset.assetClass }) {
            // Asset already exists, add the amount to the existing asset
            assets[existingIndex].amount += asset.amount
            print("Updated existing asset \(asset.name) (\(asset.code)): added \(asset.amount), new total: \(assets[existingIndex].amount)")
        } else {
            // Asset doesn't exist, add it as a new asset
            assets.append(asset)
            print("Added new asset \(asset.name) (\(asset.code)) with amount: \(asset.amount)")
        }
        Task {
            await refreshData()
        }
    }

    func updateAsset(_ asset: Asset) {
        if let index = assets.firstIndex(where: { $0.id == asset.id }) {
            assets[index] = asset
            Task {
                await refreshData()
            }
        }
    }
    
    func deleteAsset(at offsets: IndexSet) {
        assets.remove(atOffsets: offsets)
    }

    private func saveAssets() {
        do {
            let encoded = try JSONEncoder().encode(assets)
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("Assets saved to UserDefaults. Count: \(assets.count)")
        } catch {
            print("Failed to save assets: \(error)")
        }
    }

    private func loadAssets() {
        if let savedAssets = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedAssets = try? JSONDecoder().decode([Asset].self, from: savedAssets) {
            self.assets = decodedAssets
            print("Loaded \(decodedAssets.count) assets from UserDefaults")
        } else {
            print("No saved assets found in UserDefaults")
        }
    }
    
    private func loadSampleData() {
        self.assets = [
            Asset(assetClass: .cryptocurrencies, code: "BTC", name: "Bitcoin", amount: 0.5, category: .highRisk),
            Asset(assetClass: .cryptocurrencies, code: "ETH", name: "Ethereum", amount: 10, category: .highRisk),
            Asset(assetClass: .stocks, code: "US0378331005", name: "Apple", amount: 100, category: .mediumRisk),
            Asset(assetClass: .etfs, code: "IE00B5BMR087", name: "iShares Core MSCI World", amount: 50, category: .lowRisk),
            Asset(assetClass: .rawMaterials, code: "XAU", name: "Gold", amount: 2, category: .lowRisk)
        ]
    }
    
    // MARK: - CSV Import/Export
    
    func exportToCSV() -> String {
        var csvString = "Asset Class,Code,Name,Amount,Risk Class\n"
        
        for asset in assets {
            let line = "\"\(asset.assetClass.rawValue)\",\"\(asset.code)\",\"\(asset.name)\",\(asset.amount),\"\(asset.category.rawValue)\"\n"
            csvString += line
        }
        
        return csvString
    }
    
    func importFromCSV(_ csvContent: String) throws {
        print("Starting CSV import...")
        let lines = csvContent.components(separatedBy: .newlines)
        var importedAssets: [Asset] = []
        
        // Skip header line if it exists and filter empty lines
        let dataLines = lines.dropFirst().filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        print("Found \(dataLines.count) data lines to process")
        
        for line in dataLines {
            let components = parseCSVLine(line)
            print("Parsing line: '\(line)' -> \(components.count) components: \(components)")
            guard components.count >= 4 else { 
                print("Skipping line with insufficient components: \(line)")
                continue 
            }
            
            let assetClassString = components[0].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let code = components[1].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let name = components[2].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            let amountString = components[3].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            
            // Handle category (optional field for backward compatibility)
            let categoryString = components.count > 4 ? components[4].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"")) : ""
            
            // Try case-insensitive matching for asset class
            let assetClass = AssetClass.allCases.first { $0.rawValue.lowercased() == assetClassString.lowercased() }
            
            // Try case-insensitive matching for category, handling both old format (with "Risk") and new format (without "Risk")
            var category: AssetCategory = .mediumRisk // default
            if !categoryString.isEmpty {
                // First try exact match with new format
                if let exactMatch = AssetCategory.allCases.first(where: { $0.rawValue.lowercased() == categoryString.lowercased() }) {
                    category = exactMatch
                } else {
                    // Try legacy format matching (e.g., "High Risk" -> "High")
                    let cleanedCategoryString = categoryString.replacingOccurrences(of: " Risk", with: "")
                    category = AssetCategory.allCases.first { $0.rawValue.lowercased() == cleanedCategoryString.lowercased() } ?? .mediumRisk
                }
            }
            
            guard let foundAssetClass = assetClass,
                  let amount = Double(amountString) else {
                print("Failed to parse line: \(line)")
                print("Asset class: '\(assetClassString)' (available: \(AssetClass.allCases.map { $0.rawValue }))")
                print("Amount: '\(amountString)'")
                continue
            }
            
            // Create asset with category (defaults to medium risk if not specified)
            let asset = Asset(assetClass: foundAssetClass, code: code, name: name, amount: amount, category: category)
            importedAssets.append(asset)
            print("Successfully parsed asset: \(name) (\(code)) with category: \(category.rawValue)")
        }
        
        print("Parsed \(importedAssets.count) assets from CSV")
        
        if !importedAssets.isEmpty {
            print("Overwriting all existing assets with imported data...")
            // Replace all existing assets with the imported ones (overwrite, not merge)
            self.assets = importedAssets
            print("Assets overwritten. New count: \(self.assets.count)")
            for asset in importedAssets {
                print("Imported asset: \(asset.name) (\(asset.code)) with amount: \(asset.amount)")
            }
            Task {
                await refreshData()
            }
        } else {
            print("No valid assets found in CSV")
            throw NSError(domain: "CSVImportError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No valid assets found in the CSV file. Please check the format and ensure asset classes match: \(AssetClass.allCases.map { $0.rawValue }.joined(separator: ", "))"])
        }
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
            
            i = line.index(after: i)
        }
        
        result.append(currentField)
        return result
    }
}
