import SwiftUI

@main
struct BleApp4App: App {
    @StateObject var bleLand = BlueToothNeighborhood()
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Control", systemImage: "square.and.pencil")
                    }
                    .tag(1)
                
                PeripheralListView(bleLand: bleLand, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Peripherals", systemImage: "list.bullet")
                    }
                    .tag(0)
            }
        }
    }
}


