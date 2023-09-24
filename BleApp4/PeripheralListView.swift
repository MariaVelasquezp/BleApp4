import SwiftUI
import CoreBluetooth

struct PeripheralListView: View {
    @ObservedObject var bleLand: BlueToothNeighborhood
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            List(bleLand.discoveredPeripherals, id: \.self) { peripheral in
                NavigationLink(destination: ContentView(selectedTab: $selectedTab)) {
                    Text(peripheral.name ?? "Unnamed Peripheral")
                }
                .onTapGesture {
                    // Set the selected peripheral and initiate the connection
                    bleLand.selectedPeripheral = peripheral
                    bleLand.connectToDevice()
                    selectedTab = 1 // Set the tab index for "Control" tab
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
