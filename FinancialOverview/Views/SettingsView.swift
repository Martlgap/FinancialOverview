import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Bindable var viewModel: AssetViewModel
    @State private var showingImportPicker = false
    @State private var showingExportPicker = false
    @State private var showingImportAlert = false
    @State private var showingExportAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Privacy")) {
                    Toggle("Privacy Mode", isOn: $viewModel.privacyModeManager.isPrivacyModeEnabled)
                    
                    if viewModel.privacyModeManager.isPrivacyModeEnabled {
                        Text("When enabled, asset values will be hidden by default and can be temporarily revealed using the eye icon next to the + button.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Currency")) {
                    Picker("Select Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(Currency.allCases, id: \.self) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Data Management")) {
                    Button(action: {
                        showingExportPicker = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Assets to CSV")
                        }
                    }
                    
                    Button(action: {
                        showingImportPicker = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Assets from CSV")
                        }
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                    }
                    
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Martin Knoche")
                    }
                    
                    HStack {
                        Text("Contact")
                        Spacer()
                        Text("financialoverview@martinknoche.net")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.commaSeparatedText, .plainText, .text],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .fileExporter(
                isPresented: $showingExportPicker,
                document: CSVDocument(content: viewModel.exportToCSV()),
                contentType: .commaSeparatedText,
                defaultFilename: "assets_export"
            ) { result in
                handleExport(result: result)
            }
            .alert("Import/Export", isPresented: $showingImportAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .alert("Export Complete", isPresented: $showingExportAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                alertMessage = "Failed to access the selected file. Please try again."
                showingImportAlert = true
                return
            }
            
            defer {
                // Always stop accessing the resource when done
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                try viewModel.importFromCSV(content)
                alertMessage = "Assets imported successfully!"
                showingImportAlert = true
            } catch {
                alertMessage = "Failed to import assets: \(error.localizedDescription)"
                showingImportAlert = true
            }
            
        case .failure(let error):
            alertMessage = "Failed to select file: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
    
    private func handleExport(result: Result<URL, Error>) {
        switch result {
        case .success(_):
            alertMessage = "Assets exported successfully!"
            showingExportAlert = true
        case .failure(let error):
            alertMessage = "Failed to export assets: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
