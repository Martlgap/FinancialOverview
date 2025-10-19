import Foundation

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