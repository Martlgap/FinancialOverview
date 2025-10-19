import Foundation

struct Asset: Identifiable, Codable, Hashable {
    var id = UUID()
    var assetClass: AssetClass
    var code: String
    var name: String
    var amount: Double
    var currentPrice: Double?
    
    var sum: Double {
        return amount * (currentPrice ?? 0)
    }
}
