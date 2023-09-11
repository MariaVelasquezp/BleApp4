import SwiftUI

@main
struct BleApp4App: App {
    @StateObject var bleLand = BlueToothNeighborhood()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $bleLand.selectedTab) {
                ContentView()
                    .tabItem {
                        Label("Control", systemImage: "square.and.pencil")
                    }
                    .tag(0)
                
                PeripheralListView(bleLand: bleLand)
                    .tabItem {
                        Label("Peripherals", systemImage: "list.bullet")
                    }
                    .tag(1)
            }
        }
    }
}

