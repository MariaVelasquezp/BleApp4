import SwiftUI

@main
struct BleApp4App: App {
    @StateObject var bleLand = BlueToothNeighborhood()
    @State private var selectedTab = 0

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView(selectedTab: $selectedTab)
                
                PeripheralListView(bleLand: bleLand, selectedTab: $selectedTab)
            }
        }
    }
}


