import Foundation

// APIService class definition (copied from the main module for testing)
class APIService {
    private var assets: [Asset] = []
    
    // CryptoCompare API for fetching crypto prices
    func fetchCryptoPriceCryptoCompare(symbol: String, currency: String) async throws -> Double? {
        let urlString = "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(symbol.uppercased())&tsyms=\(currency.uppercased())"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let raw = json["RAW"] as? [String: Any],
           let symbolData = raw[symbol.uppercased()] as? [String: Any],
           let currencyData = symbolData[currency.uppercased()] as? [String: Any],
           let price = currencyData["PRICE"] as? Double {
            return price
        }
        return nil
    }
    
    func fetchStockOrETFPrice(isin: String, currency: String) async throws -> Double? {
        let urlString = "https://www.justetf.com/api/etfs/\(isin)/quote?locale=en&currency=\(currency)"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // Parse the correct structure: {"latestQuote":{"raw":126.91,"localized":"126.91"},...}
            if let latestQuote = json["latestQuote"] as? [String: Any],
               let rawPrice = latestQuote["raw"] as? Double {
                return rawPrice
            }
            
            // Fallback: try other common locations
            if let quote = json["quote"] as? Double {
                return quote
            }
            
            if let price = json["price"] as? Double {
                return price
            }
            
            if let value = json["value"] as? Double {
                return value
            }
        }
        return nil
    }
    
    func fetchRawMaterialPrice(material: String, currency: String) async throws -> Double? {
        let urlString = "https://forex-data-feed.swissquote.com/public-quotes/bboquotes/instrument/\(material)/\(currency)"
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
           let firstQuote = json.first,
           let spreadProfilePrices = firstQuote["spreadProfilePrices"] as? [[String: Any]],
           let firstPrice = spreadProfilePrices.first,
           let ask = firstPrice["ask"] as? Double {
            return ask
        }
        return nil
    }
}

// Minimal Asset struct definition for testing
struct Asset: Identifiable, Codable, Hashable {
    var id = UUID()
    var assetClass: AssetClass
    var code: String
    var name: String
    var amount: Double
    var currentPrice: Double?
    var category: AssetCategory
    
    var sum: Double {
        return amount * (currentPrice ?? 0)
    }
}

// Required enums for Asset
enum AssetClass: String, CaseIterable, Codable, Identifiable {
    case rawMaterials = "Raw Materials"
    case cryptocurrencies = "Cryptocurrencies"
    case stocks = "Stocks"
    case etfs = "ETFs"

    var id: String { self.rawValue }
}

enum AssetCategory: String, CaseIterable, Codable, Identifiable {
    case highRisk = "High"
    case mediumRisk = "Medium"
    case lowRisk = "Low"

    var id: String { self.rawValue }
    
    var color: String {
        switch self {
        case .highRisk:
            return "red"
        case .mediumRisk:
            return "orange"
        case .lowRisk:
            return "green"
        }
    }
    
    var iconName: String {
        switch self {
        case .highRisk:
            return "exclamationmark.triangle.fill"
        case .mediumRisk:
            return "exclamationmark.circle.fill"
        case .lowRisk:
            return "checkmark.shield.fill"
        }
    }
}

// Test runner function
func runAPITests() async {
    let apiService = APIService()

    print("Testing API services...")

    // Test fetchCryptoPriceCryptoCompare
    do {
        if let price = try await apiService.fetchCryptoPriceCryptoCompare(symbol: "BTC", currency: "usd") {
            print("✅ Bitcoin price (CryptoCompare): \(price) USD")
        } else {
            print("❌ Failed to fetch Bitcoin price (CryptoCompare).")
        }
    } catch {
        print("❌ Error fetching Bitcoin price (CryptoCompare): \(error)")
    }

    // Test fetchStockOrETFPrice
    do {
        if let price = try await apiService.fetchStockOrETFPrice(isin: "IE00B4L5Y983", currency: "USD") {
            print("✅ iShares Core S&P 500 UCITS ETF price: \(price) USD")
        } else {
            print("❌ Failed to fetch stock/ETF price.")
        }
    } catch {
        print("❌ Error fetching stock/ETF price: \(error)")
    }

    // Test fetchRawMaterialPrice
    do {
        if let price = try await apiService.fetchRawMaterialPrice(material: "XAU", currency: "USD") {
            print("✅ Gold price: \(price) USD")
        } else {
            print("❌ Failed to fetch Gold price.")
        }
    } catch {
        print("❌ Error fetching Gold price: \(error)")
    }
}

// Main entry point
await runAPITests()
