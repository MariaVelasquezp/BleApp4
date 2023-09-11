import SwiftUI

@main
struct BleApp4App: App {
    @StateObject var bleLand = BlueToothNeighborhood()
    @State private var selectedTab = 0 // Add this line

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Label("Control", systemImage: "square.and.pencil")
                    }
                    .tag(0)
                
                PeripheralListView(bleLand: bleLand, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Peripherals", systemImage: "list.bullet")
                    }
                    .tag(1)
            }
        }
    }
}


