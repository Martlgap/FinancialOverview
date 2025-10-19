import Foundation

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
