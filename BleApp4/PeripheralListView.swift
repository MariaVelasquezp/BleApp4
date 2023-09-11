import SwiftUI
import CoreBluetooth

struct PeripheralListView: View {
    @ObservedObject var bleLand: BlueToothNeighborhood
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            List(bleLand.discoveredPeripherals, id: \.self) { peripheral in
                Button(action: {
                    // Set the selected peripheral and switch to the Control tab
                    bleLand.selectedPeripheral = peripheral
                    selectedTab = 0 // Control tab index
                }) {
                    Text(peripheral.name ?? "Unnamed Peripheral")
                }
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
