import SwiftUI
import Charts

struct DistributionView: View {
    let viewModel: AssetViewModel
    @State private var selectedDistributionType: DistributionType = .assetClass
    
    enum DistributionType: String, CaseIterable {
        case assetClass = "Asset Classes"
        case riskCategory = "Risk Classes"
    }
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Distribution Type Picker
                        distributionTypePicker
                        
                        // Main Chart
                        chartCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Distribution")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    

    
    private var distributionTypePicker: some View {
        Picker("Distribution Type", selection: $selectedDistributionType) {
            ForEach(DistributionType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 4)
    }
    
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedDistributionType.rawValue)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            chartContent
        }
        .padding(20)
        .background(chartBackground)
    }
    
    @ViewBuilder
    private var chartContent: some View {
        if viewModel.totalSum > 0 {
            pieChart
        } else {
            emptyStateView
        }
    }
    
    private var pieChart: some View {
        Chart {
            if selectedDistributionType == .assetClass {
                ForEach(AssetClass.allCases) { assetClass in
                    let sum = viewModel.sum(for: assetClass)
                    if sum > 0 {
                        let percentage = (sum / viewModel.totalSum) * 100
                        SectorMark(
                            angle: .value("Value", sum),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(colorForAssetClass(assetClass))
                        .opacity(0.8)
                        .annotation(position: .overlay) {
                            VStack(spacing: 2) {
                                Text(assetClass.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("\(percentage, specifier: "%.1f")%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(4)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(6)
                        }
                    }
                }
            } else {
                ForEach(AssetCategory.allCases) { category in
                    let sum = viewModel.sum(for: category)
                    if sum > 0 {
                        let percentage = (sum / viewModel.totalSum) * 100
                        SectorMark(
                            angle: .value("Value", sum),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(colorForCategory(category))
                        .opacity(0.8)
                        .annotation(position: .overlay) {
                            VStack(spacing: 2) {
                                Text(category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text("\(percentage, specifier: "%.1f")%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(4)
                            .background(Color(.systemBackground).opacity(0.9))
                            .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .frame(height: 300)
        .animation(.easeInOut(duration: 0.3), value: selectedDistributionType)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No data to display")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add some assets to see the distribution")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
    }
    
    private var chartBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Chart Data
    

    

    

    
    // MARK: - Helper Functions
    

    
    private func colorForAssetClass(_ assetClass: AssetClass) -> Color {
        switch assetClass {
        case .rawMaterials:
            return .cyan
        case .cryptocurrencies:
            return Color(red: 0.2, green: 0.6, blue: 1.0) // Light blue
        case .stocks:
            return .blue
        case .etfs:
            return Color(red: 0.0, green: 0.4, blue: 0.8) // Dark blue
        }
    }
    
    private func colorForCategory(_ category: AssetCategory) -> Color {
        switch category {
        case .highRisk:
            return .red
        case .mediumRisk:
            return .orange
        case .lowRisk:
            return .green
        }
    }
    
    private func iconForAssetClass(_ assetClass: AssetClass) -> String {
        switch assetClass {
        case .rawMaterials:
            return "cube.fill"
        case .cryptocurrencies:
            return "bitcoinsign.circle.fill"
        case .stocks:
            return "chart.line.uptrend.xyaxis"
        case .etfs:
            return "chart.pie.fill"
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    DistributionView(viewModel: AssetViewModel())
}