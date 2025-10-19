import SwiftUI

struct AddPlanView: View {
    @ObservedObject var planManager: PlanManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var planName: String = ""
    @State private var selectedTargetType: PlanTargetType = .riskClass
    @State private var plan: Plan
    @State private var showingValidationError = false
    
    init(planManager: PlanManager, editingPlan: Plan? = nil) {
        self.planManager = planManager
        if let existingPlan = editingPlan {
            self._plan = State(initialValue: existingPlan)
            self._planName = State(initialValue: existingPlan.name)
            self._selectedTargetType = State(initialValue: existingPlan.targetType)
        } else {
            self._plan = State(initialValue: Plan(name: "", targetType: .riskClass))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Plan Details") {
                    TextField("Plan Name", text: $planName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Target Type", selection: $selectedTargetType) {
                        ForEach(PlanTargetType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedTargetType) { _, newType in
                        updatePlanTargetType(newType)
                    }
                }
                
                Section {
                    distributionInputs
                } header: {
                    HStack {
                        Text("Target Distribution")
                        Spacer()
                        Text("Total: \(plan.totalPercentage, specifier: "%.1f")%")
                            .foregroundColor(plan.isValid ? .green : .red)
                            .fontWeight(.medium)
                    }
                } footer: {
                    if !plan.isValid {
                        Text("Total must equal 100%")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(plan.name.isEmpty ? "New Plan" : "Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePlan()
                    }
                    .disabled(planName.isEmpty)
                }
            }
            .alert("Invalid Plan", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text("The total percentage must equal 100% before saving.")
            }
        }
    }
    
    @ViewBuilder
    private var distributionInputs: some View {
        ForEach(plan.distributions.indices, id: \.self) { index in
            HStack {
                Text(plan.distributions[index].key)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextField("0.0", value: Binding(
                    get: { plan.distributions[index].percentage },
                    set: { newValue in
                        plan.updateDistribution(for: plan.distributions[index].key, percentage: newValue)
                    }
                ), format: .number.precision(.fractionLength(1)))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 80)
                .keyboardType(.decimalPad)
                
                Text("%")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func updatePlanTargetType(_ newType: PlanTargetType) {
        var newPlan = Plan(name: planName, targetType: newType)
        // Try to preserve any existing percentages that match
        for distribution in plan.distributions {
            if let matchingIndex = newPlan.distributions.firstIndex(where: { $0.key == distribution.key }) {
                newPlan.distributions[matchingIndex] = distribution
            }
        }
        plan = newPlan
    }
    
    private func savePlan() {
        guard !planName.isEmpty else { return }
        
        if !plan.isValid {
            showingValidationError = true
            return
        }
        
        plan.name = planName
        
        // Check if we're editing an existing plan
        if planManager.plans.firstIndex(where: { $0.id == plan.id }) != nil {
            planManager.updatePlan(plan)
        } else {
            planManager.addPlan(plan)
        }
        
        dismiss()
    }
}

#Preview {
    AddPlanView(planManager: PlanManager())
}