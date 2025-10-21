import Foundation

enum PlanTargetType: String, CaseIterable, Codable {
    case riskClass = "Risk Class"
    case assetClass = "Asset Class"
    
    var id: String { self.rawValue }
}

struct PlanDistribution: Codable, Identifiable {
    var id = UUID()
    let key: String // AssetCategory.rawValue or AssetClass.rawValue
    var percentage: Double
    
    init(key: String, percentage: Double = 0.0) {
        self.key = key
        self.percentage = percentage
    }
}

struct Plan: Codable, Identifiable {
    var id = UUID()
    var name: String
    var targetType: PlanTargetType
    var distributions: [PlanDistribution]
    let createdAt: Date
    var modifiedAt: Date
    
    init(name: String, targetType: PlanTargetType, enabledAssetClasses: [AssetClass]? = nil) {
        self.name = name
        self.targetType = targetType
        self.createdAt = Date()
        self.modifiedAt = Date()
        
        // Initialize distributions based on target type
        switch targetType {
        case .riskClass:
            self.distributions = AssetCategory.allCases.map { category in
                PlanDistribution(key: category.rawValue, percentage: 0.0)
            }
        case .assetClass:
            let assetClasses = enabledAssetClasses ?? AssetClass.allCases
            self.distributions = assetClasses.map { assetClass in
                PlanDistribution(key: assetClass.rawValue, percentage: 0.0)
            }
        }
    }
    
    var totalPercentage: Double {
        distributions.reduce(0) { $0 + $1.percentage }
    }
    
    var isValid: Bool {
        abs(totalPercentage - 100.0) < 0.01
    }
    
    func enabledDistributions(using enabledAssetClasses: [AssetClass]) -> [PlanDistribution] {
        switch targetType {
        case .riskClass:
            return distributions // Risk class distributions are always valid
        case .assetClass:
            let enabledClassNames = Set(enabledAssetClasses.map { $0.rawValue })
            return distributions.filter { enabledClassNames.contains($0.key) }
        }
    }
    
    mutating func updateDistribution(for key: String, percentage: Double) {
        if let index = distributions.firstIndex(where: { $0.key == key }) {
            distributions[index] = PlanDistribution(key: key, percentage: percentage)
            modifiedAt = Date()
        }
    }
}

struct PlanDiscrepancy {
    let key: String
    let currentPercentage: Double
    let targetPercentage: Double
    let currentValue: Double
    let targetValue: Double
    let discrepancyValue: Double // Amount needed to add (positive) or remove (negative)
    let discrepancyPercentage: Double
    
    var needsRebalancing: Bool {
        abs(discrepancyPercentage) > 0.01
    }
}

struct PlanAnalysis {
    let plan: Plan
    let discrepancies: [PlanDiscrepancy]
    let totalPortfolioValue: Double
    let isRebalancingNeeded: Bool
    
    var totalRebalancingAmount: Double {
        discrepancies.filter { $0.discrepancyValue > 0 }.reduce(0) { $0 + $1.discrepancyValue }
    }
    
    init(plan: Plan, currentDistribution: [String: Double], totalValue: Double, enabledAssetClasses: [AssetClass]? = nil) {
        self.plan = plan
        self.totalPortfolioValue = totalValue
        
        // Use only enabled distributions for calculations
        let distributionsToUse = enabledAssetClasses != nil ? 
            plan.enabledDistributions(using: enabledAssetClasses!) : 
            plan.distributions
        
        // Calculate discrepancies with corrected rebalancing logic
        let (discrepancies, _) = Self.calculateCorrectRebalancing(
            distributions: distributionsToUse,
            currentDistribution: currentDistribution,
            totalValue: totalValue
        )
        
        self.discrepancies = discrepancies
        self.isRebalancingNeeded = discrepancies.contains { $0.needsRebalancing }
    }
    
    /// Calculates the correct rebalancing amounts when only additions are allowed (no selling).
    /// This solves for the minimum additional investments needed to get underfunded categories
    /// as close as possible to their target percentages.
    private static func calculateCorrectRebalancing(
        distributions: [PlanDistribution],
        currentDistribution: [String: Double],
        totalValue: Double
    ) -> ([PlanDiscrepancy], Double) {
        
        // Get current values for each category
        var currentValues: [String: Double] = [:]
        for distribution in distributions {
            let currentPercent = currentDistribution[distribution.key] ?? 0.0
            currentValues[distribution.key] = totalValue * (currentPercent / 100.0)
        }
        
        // Identify underfunded and overfunded categories
        var underfundedCategories: [(key: String, currentValue: Double, targetPercent: Double)] = []
        var overfundedValue: Double = 0.0
        
        for distribution in distributions {
            let key = distribution.key
            let currentValue = currentValues[key] ?? 0.0
            let currentPercent = currentDistribution[key] ?? 0.0
            let targetPercent = distribution.percentage
            
            if currentPercent < targetPercent {
                underfundedCategories.append((key: key, currentValue: currentValue, targetPercent: targetPercent / 100.0))
            } else {
                overfundedValue += currentValue
            }
        }
        
        // If no underfunded categories, no rebalancing needed
        guard !underfundedCategories.isEmpty else {
            let discrepancies = distributions.map { distribution in
                let currentPercent = currentDistribution[distribution.key] ?? 0.0
                let currentValue = currentValues[distribution.key] ?? 0.0
                
                return PlanDiscrepancy(
                    key: distribution.key,
                    currentPercentage: currentPercent,
                    targetPercentage: distribution.percentage,
                    currentValue: currentValue,
                    targetValue: currentValue,
                    discrepancyValue: 0.0,
                    discrepancyPercentage: distribution.percentage - currentPercent
                )
            }
            return (discrepancies, totalValue)
        }
        
        // Calculate the total target percentage for underfunded categories
        let totalUnderfundedTargetPercent = underfundedCategories.reduce(0.0) { $0 + $1.targetPercent }
        
        // Mathematical solution:
        // Let N = new total portfolio value after additions
        // For each underfunded category i: targetValue_i = N * targetPercent_i
        // Amount to add to category i: addAmount_i = targetValue_i - currentValue_i
        // 
        // Total amount to add: X = sum(addAmount_i) = sum(N * targetPercent_i - currentValue_i)
        // Also: N = totalValue + X
        // 
        // Therefore: X = sum(N * targetPercent_i) - sum(currentValue_i)
        // X = N * sum(targetPercent_i) - sum(currentValue_i)
        // X = N * totalUnderfundedTargetPercent - totalCurrentUnderfunded
        // 
        // Since N = totalValue + X:
        // X = (totalValue + X) * totalUnderfundedTargetPercent - totalCurrentUnderfunded
        // X = totalValue * totalUnderfundedTargetPercent + X * totalUnderfundedTargetPercent - totalCurrentUnderfunded
        // X - X * totalUnderfundedTargetPercent = totalValue * totalUnderfundedTargetPercent - totalCurrentUnderfunded
        // X * (1 - totalUnderfundedTargetPercent) = totalValue * totalUnderfundedTargetPercent - totalCurrentUnderfunded
        // X = (totalValue * totalUnderfundedTargetPercent - totalCurrentUnderfunded) / (1 - totalUnderfundedTargetPercent)
        
        let totalCurrentUnderfunded = underfundedCategories.reduce(0.0) { $0 + $1.currentValue }
        
        let newTotalValue: Double
        if totalUnderfundedTargetPercent < 1.0 {
            let numerator = totalValue * totalUnderfundedTargetPercent - totalCurrentUnderfunded
            let denominator = 1.0 - totalUnderfundedTargetPercent
            
            if denominator > 0 && numerator >= 0 {
                let totalToAdd = numerator / denominator
                newTotalValue = totalValue + totalToAdd
            } else {
                // Edge case: impossible to achieve target percentages with only additions
                newTotalValue = totalValue
            }
        } else {
            // Target percentages for underfunded categories sum to 100% or more
            // This is impossible to achieve without selling overfunded assets
            newTotalValue = totalValue
        }
        
        // Calculate discrepancies based on the new total value
        var discrepancies: [PlanDiscrepancy] = []
        
        for distribution in distributions {
            let currentPercent = currentDistribution[distribution.key] ?? 0.0
            let targetPercent = distribution.percentage
            let currentValue = currentValues[distribution.key] ?? 0.0
            
            let newTargetValue = newTotalValue * (targetPercent / 100.0)
            let discrepancyValue = max(0, newTargetValue - currentValue)
            
            // Calculate what the actual percentage will be after rebalancing
            let finalValue = currentValue + discrepancyValue
            let finalPercentage = newTotalValue > 0 ? (finalValue / newTotalValue) * 100.0 : currentPercent
            
            let discrepancy = PlanDiscrepancy(
                key: distribution.key,
                currentPercentage: currentPercent,
                targetPercentage: distribution.percentage,
                currentValue: currentValue,
                targetValue: newTargetValue,
                discrepancyValue: discrepancyValue,
                discrepancyPercentage: finalPercentage - currentPercent // Show actual change, not target difference
            )
            
            discrepancies.append(discrepancy)
        }
        
        return (discrepancies, newTotalValue)
    }
}