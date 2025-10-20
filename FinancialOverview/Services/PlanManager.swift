import Foundation
import SwiftUI
import Combine

class PlanManager: ObservableObject {
    @Published var plans: [Plan] = []
    
    private let plansKey = "SavedPlans"
    
    init() {
        loadPlans()
    }
    
    func savePlans() {
        if let encoded = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(encoded, forKey: plansKey)
        }
    }
    
    private func loadPlans() {
        if let data = UserDefaults.standard.data(forKey: plansKey),
           let decodedPlans = try? JSONDecoder().decode([Plan].self, from: data) {
            plans = decodedPlans
        }
    }
    
    func addPlan(_ plan: Plan) {
        plans.append(plan)
        savePlans()
    }
    
    func updatePlan(_ plan: Plan) {
        if let index = plans.firstIndex(where: { $0.id == plan.id }) {
            plans[index] = plan
            savePlans()
        }
    }
    
    func deletePlan(_ plan: Plan) {
        plans.removeAll { $0.id == plan.id }
        savePlans()
    }
    
    func analyzePlan(_ plan: Plan, with assetViewModel: AssetViewModel) -> PlanAnalysis {
        let totalValue = assetViewModel.totalValue
        var currentDistribution: [String: Double] = [:]
        
        switch plan.targetType {
        case .riskClass:
            // Calculate current risk class distribution
            let riskDistribution = assetViewModel.riskCategoryDistribution
            for category in AssetCategory.allCases {
                let percentage = riskDistribution[category] ?? 0.0
                currentDistribution[category.rawValue] = percentage
            }
        case .assetClass:
            // Calculate current asset class distribution
            let assetDistribution = assetViewModel.assetClassDistribution
            for assetClass in assetViewModel.assetClassSettings.enabledClasses {
                let percentage = assetDistribution[assetClass] ?? 0.0
                currentDistribution[assetClass.rawValue] = percentage
            }
        }
        
        return PlanAnalysis(
            plan: plan, 
            currentDistribution: currentDistribution, 
            totalValue: totalValue,
            enabledAssetClasses: plan.targetType == .assetClass ? assetViewModel.assetClassSettings.enabledClasses : nil
        )
    }
}