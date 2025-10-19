import SwiftUI

struct ContentView: View {
    @State private var assetViewModel = AssetViewModel()

    var body: some View {
        TabView {
            OverviewView(viewModel: assetViewModel)
                .tabItem {
                    Label("Overview", systemImage: "chart.pie")
                }

            SettingsView(viewModel: assetViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            UITabBar.appearance().barTintColor = .black
        }
        .preferredColorScheme(.dark)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh asset values when app comes to foreground
            Task {
                await assetViewModel.refreshData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
