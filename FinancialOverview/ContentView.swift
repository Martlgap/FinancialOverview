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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
