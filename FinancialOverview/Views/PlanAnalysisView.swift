import SwiftUI
import Charts

struct PlanAnalysisView: View {
    let plan: Plan
    let viewModel: AssetViewModel
    let planManager: PlanManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditPlan = false
    @State private var showingDeleteAlert = false
    
    private var analysis: PlanAnalysis {
        planManager.analyzePlan(plan, with: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Plan Header
                    planHeaderCard
                    
                    // Current vs Target Chart
                    if viewModel.totalValue > 0 {
                        distributionComparisonCard
                    }
                    
                    // Rebalancing Recommendations
                    if analysis.isRebalancingNeeded {
                        rebalancingCard
                    } else {
                        successCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .navigationTitle("Plan Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingEditPlan = true
                        } label: {
                            Label("Edit Plan", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Plan", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditPlan) {
                AddPlanView(planManager: planManager, viewModel: viewModel, editingPlan: plan)
            }
            .alert("Delete Plan", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    planManager.deletePlan(plan)
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete '\(plan.name)'? This action cannot be undone.")
            }
        }
    }
    
    private var planHeaderCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(plan.targetType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: analysis.isRebalancingNeeded ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .foregroundColor(analysis.isRebalancingNeeded ? .orange : .green)
                        
                        Text(analysis.isRebalancingNeeded ? "Needs Rebalancing" : "On Target")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(analysis.isRebalancingNeeded ? .orange : .green)
                    }
                    
                    Text("Updated \(plan.modifiedAt, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if analysis.totalPortfolioValue > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Portfolio Value: \(analysis.totalPortfolioValue, format: .currency(code: viewModel.selectedCurrency.rawValue.uppercased()))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if analysis.isRebalancingNeeded && analysis.totalRebalancingAmount > 0 {
                        let futureValue = analysis.totalPortfolioValue + analysis.totalRebalancingAmount
                        Text("Future Portfolio Value: \(futureValue, format: .currency(code: viewModel.selectedCurrency.rawValue.uppercased()))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var distributionComparisonCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current vs Target Distribution")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            comparisonChart
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var comparisonChart: some View {
        Chart {
            ForEach(analysis.discrepancies, id: \.key) { discrepancy in
                // Current distribution
                BarMark(
                    x: .value("Category", discrepancy.key),
                    y: .value("Percentage", discrepancy.currentPercentage),
                    width: .fixed(20)
                )
                .foregroundStyle(.blue.opacity(0.7))
                .position(by: .value("Type", "Current"))
                
                // Target distribution
                BarMark(
                    x: .value("Category", discrepancy.key),
                    y: .value("Percentage", discrepancy.targetPercentage),
                    width: .fixed(20)
                )
                .foregroundStyle(.orange.opacity(0.7))
                .position(by: .value("Type", "Target"))
            }
        }
        .frame(height: 200)
        .chartForegroundStyleScale([
            "Current": .blue,
            "Target": .orange
        ])
        .chartLegend(position: .bottom)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisValueLabel()
                    .font(.caption)
            }
        }
    }
    
    private var rebalancingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Rebalancing Needed")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            if analysis.totalRebalancingAmount > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Additional Investment Needed: \(analysis.totalRebalancingAmount, format: .currency(code: viewModel.selectedCurrency.rawValue.uppercased()))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Calculated to get as close as possible to target percentages (additions only)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(analysis.discrepancies.filter { $0.needsRebalancing }, id: \.key) { discrepancy in
                    rebalancingRow(for: discrepancy)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var successCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 50))
            
            Text("Perfect Allocation!")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Your portfolio matches your target distribution")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    

    
    private func rebalancingRow(for discrepancy: PlanDiscrepancy) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(discrepancy.key)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                let finalPercentage = discrepancy.currentPercentage + discrepancy.discrepancyPercentage
                Text("\(discrepancy.currentPercentage, specifier: "%.1f")% → \(finalPercentage, specifier: "%.1f")% (target: \(discrepancy.targetPercentage, specifier: "%.1f")%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if discrepancy.discrepancyValue > 0 {
                    Text("+ \(discrepancy.discrepancyValue, format: .currency(code: viewModel.selectedCurrency.rawValue.uppercased()))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                } else if discrepancy.discrepancyValue < 0 {
                    Text("- \(abs(discrepancy.discrepancyValue), format: .currency(code: viewModel.selectedCurrency.rawValue.uppercased()))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                
                Text("\(discrepancy.discrepancyPercentage >= 0 ? "+" : "")\(discrepancy.discrepancyPercentage, specifier: "%.1f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    

}

#Preview {
    let viewModel = AssetViewModel()
    let planManager = PlanManager()
    let samplePlan = Plan(name: "Conservative Portfolio", targetType: .riskClass)
    
    return PlanAnalysisView(plan: samplePlan, viewModel: viewModel, planManager: planManager)
}