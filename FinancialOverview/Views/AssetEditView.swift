import SwiftUI

struct AssetEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Bindable var viewModel: AssetViewModel
    @State var asset: Asset
    
    private let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ""
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 20 // Allow many decimal places
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    init(viewModel: AssetViewModel, asset: Asset?) {
        self.viewModel = viewModel
        // Create a new asset if none provided
        self._asset = State(initialValue: asset ?? Asset(
            assetClass: .cryptocurrencies,
            code: "",
            name: "",
            amount: 0,
            category: .mediumRisk
        ))
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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Asset Details")) {
                    Picker("Asset Class", selection: $asset.assetClass) {
                        ForEach(AssetClass.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    Picker("Risk Class", selection: $asset.category) {
                        ForEach(AssetCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundColor(colorForCategory(category))
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    TextField("Name", text: $asset.name)
                    TextField("Code (e.g., BTC, US0378331005)", text: $asset.code)
                    TextField("Amount", value: $asset.amount, formatter: amountFormatter)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(viewModel.assets.contains(where: { $0.id == asset.id }) ? "Edit Asset" : "Add Asset")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                if viewModel.assets.contains(where: { $0.id == asset.id }) {
                    viewModel.updateAsset(asset)
                } else {
                    viewModel.addAsset(asset)
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
