import Foundation

enum AssetClass: String, CaseIterable, Codable, Identifiable {
    case rawMaterials = "Raw Materials"
    case cryptocurrencies = "Cryptocurrencies"
    case stocks = "Stocks"
    case etfs = "ETFs"

    var id: String { self.rawValue }
}
