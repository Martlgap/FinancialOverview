import Foundation
import Observation

@Observable
class AssetClassSettingsManager {
    var enabledAssetClasses: Set<AssetClass> = Set(AssetClass.allCases) {
        didSet {
            saveSettings()
        }
    }
    
    private let userDefaultsKey = "enabledAssetClasses"
    
    init() {
        loadSettings()
    }
    
    func isEnabled(_ assetClass: AssetClass) -> Bool {
        enabledAssetClasses.contains(assetClass)
    }
    
    func toggle(_ assetClass: AssetClass) {
        if enabledAssetClasses.contains(assetClass) {
            enabledAssetClasses.remove(assetClass)
        } else {
            enabledAssetClasses.insert(assetClass)
        }
    }
    
    func setEnabled(_ assetClass: AssetClass, enabled: Bool) {
        if enabled {
            enabledAssetClasses.insert(assetClass)
        } else {
            enabledAssetClasses.remove(assetClass)
        }
    }
    
    var enabledClasses: [AssetClass] {
        AssetClass.allCases.filter { enabledAssetClasses.contains($0) }
    }
    
    private func saveSettings() {
        let enabledClassNames = enabledAssetClasses.map { $0.rawValue }
        UserDefaults.standard.set(enabledClassNames, forKey: userDefaultsKey)
    }
    
    private func loadSettings() {
        if let savedClassNames = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            let savedClasses = savedClassNames.compactMap { className in
                AssetClass.allCases.first { $0.rawValue == className }
            }
            enabledAssetClasses = Set(savedClasses)
        }
        // If no saved settings or empty set, default to all classes enabled
        if enabledAssetClasses.isEmpty {
            enabledAssetClasses = Set(AssetClass.allCases)
        }
    }
}