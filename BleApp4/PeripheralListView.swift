import SwiftUI
import CoreBluetooth

struct PeripheralListView: View {
    @ObservedObject var bleLand: BlueToothNeighborhood

    var body: some View {
        NavigationView {
            List {
                // Your list content here
            }
            .navigationBarTitle("Available Peripherals")
        }
        .onAppear {
            // Start scanning for peripherals when this view appears
            bleLand.discoverDevice()
        }
        .onDisappear {
            // Stop scanning when this view disappears
            bleLand.stopScanning()
        }
    }
}
