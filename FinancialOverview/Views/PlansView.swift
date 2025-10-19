import SwiftUI

struct PlansView: View {
    let viewModel: AssetViewModel
    @StateObject private var planManager = PlanManager()
    @State private var showingAddPlan = false
    @State private var selectedPlan: Plan?
    @State private var showingPlanAnalysis = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95),
                        Color(.systemGray6).opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if planManager.plans.isEmpty {
                    emptyStateView
                } else {
                    plansList
                }
            }
            .navigationTitle("Plans")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddPlan = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlan) {
                AddPlanView(planManager: planManager)
            }
            .sheet(item: $selectedPlan) { plan in
                PlanAnalysisView(plan: plan, viewModel: viewModel, planManager: planManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Plans Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Create your first investment plan to track your portfolio allocation goals")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddPlan = true
            } label: {
                Label("Create Plan", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
    
    private var plansList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(planManager.plans) { plan in
                    PlanCard(plan: plan) {
                        selectedPlan = plan
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }
}

struct PlanCard: View {
    let plan: Plan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(plan.targetType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        validationBadge
                        
                        Text(plan.modifiedAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Preview of distribution
                HStack {
                    ForEach(plan.distributions.prefix(3), id: \.id) { distribution in
                        if distribution.percentage > 0 {
                            VStack(spacing: 4) {
                                Text(distribution.key)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text("\(distribution.percentage, specifier: "%.1f")%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                        }
                    }
                    
                    if plan.distributions.filter({ $0.percentage > 0 }).count > 3 {
                        Text("...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var validationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: plan.isValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(plan.isValid ? .green : .orange)
            
            Text(plan.isValid ? "Valid" : "Invalid")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(plan.isValid ? .green : .orange)
        }
    }
}

#Preview {
    PlansView(viewModel: AssetViewModel())
}