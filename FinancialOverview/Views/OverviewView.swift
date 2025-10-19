import SwiftUI

struct OverviewView: View {
    
    // Helper function to format asset amounts with smart decimal handling
    private func formatAssetAmount(_ amount: Double) -> String {
        if amount == floor(amount) {
            // Natural number - show no decimals
            return String(format: "%.0f", amount)
        } else {
            // Rational number - show appropriate decimals
            return String(format: "%.2f", amount).replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
        }
    }
    var viewModel: AssetViewModel
    @State private var expandedAssetClasses: Set<AssetClass> = []
    @State private var showingAssetEditView = false
    @State private var selectedAsset: Asset?
    @State private var showingNewAssetView = false

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
                
                List {
                    totalSumSection
                    
                    ForEach(AssetClass.allCases) { assetClass in
                        assetClassSection(assetClass)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Portfolio")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingNewAssetView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .refreshable {
                    await viewModel.refreshData()
                }
                .sheet(item: $selectedAsset) { asset in
                    AssetEditView(viewModel: viewModel, asset: asset)
                }
                .sheet(isPresented: $showingNewAssetView) {
                    AssetEditView(viewModel: viewModel, asset: nil)
                }
            }
        }
    }

    private var totalSumSection: some View {
        Section {
            VStack(spacing: 12) {
                Text("\(viewModel.totalSum, specifier: "%.2f") \(viewModel.selectedCurrency.rawValue)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan, .teal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Last updated: \(lastUpdated, formatter: itemFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.cyan.opacity(0.08),
                                Color.teal.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private func assetClassSection(_ assetClass: AssetClass) -> some View {
        let assets = viewModel.assets(for: assetClass)

        return AnyView(
            Section {
                DisclosureGroup(
                    isExpanded: Binding(
                        get: { expandedAssetClasses.contains(assetClass) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedAssetClasses.insert(assetClass)
                            } else {
                                expandedAssetClasses.remove(assetClass)
                            }
                        }
                    ),
                    content: {
                        if assets.isEmpty {
                            Text("No assets")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(assets) { asset in
                                assetRow(asset)
                                    .onTapGesture {
                                        selectedAsset = asset
                                    }
                            }
                            .onDelete { indexSet in
                                let assetsToDelete = indexSet.map { assets[$0] }
                                for asset in assetsToDelete {
                                    if let index = viewModel.assets.firstIndex(where: { $0.id == asset.id }) {
                                        viewModel.deleteAsset(at: IndexSet(integer: index))
                                    }
                                }
                            }
                        }
                    },
                    label: {
                        assetClassHeader(assetClass)
                    }
                )
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground).opacity(0.8))
                        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            }
        )
    }

    private func assetClassHeader(_ assetClass: AssetClass) -> some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: iconForAssetClass(assetClass))
                    .font(.title2)
                    .foregroundColor(.cyan)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(assetClass.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("\(viewModel.assets(for: assetClass).count) Assets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(viewModel.sum(for: assetClass), specifier: "%.2f") \(viewModel.selectedCurrency.rawValue)")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(viewModel.percentage(for: assetClass), specifier: "%.1f")%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 2)
    }

    private func assetRow(_ asset: Asset) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.name)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(formatAssetAmount(asset.amount)) units")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(asset.sum, specifier: "%.2f") \(viewModel.selectedCurrency.rawValue)")
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("\(asset.currentPrice ?? 0, specifier: "%.2f") \(viewModel.selectedCurrency.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(viewModel.percentage(for: asset), specifier: "%.1f")%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue.opacity(0.8))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
                .padding(.leading, 8)
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.leading, 4)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
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
