import Foundation
import SwiftUI
import UIKit
import CoreBluetooth

struct RCNotifications {
    static let BluetoothReady = "org.elkhorn-creek.simpleledcapsense.bluetoothReady"
    static let FoundDevice = "org.elkhorn-creek.simpleledcapsense.founddevice"
    static let ConnectionComplete = "org.elkhorn-creek.simpleledcapsense.connectioncomplete"
    static let ServiceScanComplete = "org.elkhorn-creek.simpleledcapsense.servicescancomplete"
    static let CharacteristicScanComplete = "org.elkhorn-creek.simpleledcapsense.characteristicsscancomplete"
    static let DisconnectedDevice = "org.elkhorn-creek.simpleledcapsense.disconnecteddevice"
    static let UpdatedCapsense = "org.elkhorn-creek.simpleledcapsense.updatedcapsense"
}

struct ContentView: View {
    @StateObject private var bleLand = BlueToothNeighborhood()
    @State private var capsenseLabel: String = ""
    @State var isBluetoothReady = false
    @State var ChoiceMadeAmp = "Amplitude (µA)"
    @State var ChoiceMadeFreq = "Frequency (Hz)"
    @State private var ledSwitchIsOn: Bool = false
    @State private var capsenseNotifySwitchIsOn: Bool = false
    @State private var isConnectButtonEnabled = true
    @State private var isDiscoverServicesButtonEnabled = true
    @State private var isConnectionComplete = false
    @State private var isDeviceFound = false
    @State private var isServiceScanComplete = false
    @State private var isCharacteristicScanComplete = false
    
    var body: some View {
        VStack {
            //MARK: TITLE
            Text("BleApp")
                .font(.largeTitle)
                .padding()
            
            //MARK: START BLUETOOTH
            Button(action: {
                bleLand.startUpCentralManager()
            }) {
                Text("Start Bluetooth")
            }
            .disabled(isBluetoothReady || bleLand.isBluetoothReady || isConnectionComplete)
            
            //MARK: SEARCH FOR SERVICE
            Button(action: {
                bleLand.discoverDevice()
            }) {
                Text("Search for Device")
            }
            .disabled(bleLand.isDeviceFound || bleLand.isDisconnected)
            .padding()

            
            //MARK: CONNECT
            Button(action: {
                if bleLand.isDeviceFound {
                    bleLand.connectToDevice()
                }
            }) {
                Text("Connect")
            }
            .disabled(!bleLand.isDeviceFound)
            .padding()
            
            //MARK: DISCOVER SERVICES
            Button(action: {
                bleLand.discoverServices()
            }) {
                Text("Discover Services")
            }
            .disabled(!bleLand.isConnectionComplete || !isDiscoverServicesButtonEnabled)
            .padding()
            
            //MARK: DISCOVER CHARACTERISTICS
            Button(action: {
                bleLand.discoverCharacteristics()
            }) {
                Text("Discover Characteristics")
            }
            .disabled(!bleLand.isServiceScanComplete || !bleLand.isDiscoverCharacteristicsButtonEnabled)
            .padding()

            
            //MARK: AMPLITUDE
            Menu{
                Button(action: {
                    ChoiceMadeAmp = "250"
                }, label:{
                    Text("250")
                })
                Button(action: {
                    ChoiceMadeAmp = "200"
                }, label:{
                    Text("200")
                })
                Button(action: {
                    ChoiceMadeAmp = "150"
                }, label:{
                    Text("150")
                })
                Button(action: {
                    ChoiceMadeAmp = "100"
                }, label:{
                    Text("100")
                })
                Button(action: {
                    ChoiceMadeAmp = "50"
                }, label:{
                    Text("50")
                })
            } label: {
                Label (
                    title: {Text("\(ChoiceMadeAmp)")},
                    icon: {Image(systemName: "plus")}
                )
            }.padding()
            
            //MARK: FREQUENCY
            
            Menu{
                Button(action: {
                    ChoiceMadeFreq = "150"
                }, label:{
                    Text("150")
                })
                Button(action: {
                    ChoiceMadeFreq = "140"
                }, label:{
                    Text("140")
                })
                Button(action: {
                    ChoiceMadeFreq = "130"
                }, label:{
                    Text("130")
                })
                Button(action: {
                    ChoiceMadeFreq = "120"
                }, label:{
                    Text("120")
                })
                Button(action: {
                    ChoiceMadeFreq = "110"
                }, label:{
                    Text("110")
                })
                Button(action: {
                    ChoiceMadeFreq = "100"
                }, label:{
                    Text("100")
                })
            } label: {
                Label (
                    title: {Text("\(ChoiceMadeFreq)")},
                    icon: {Image(systemName: "plus")}
                )
            }.padding()
            
            //MARK: DISCONNECT
            Button(action: {
                bleLand.disconnectDevice()
            }) {
                Text("Disconnect")
            }
            .disabled(!bleLand.isDisconnectButtonEnabled)
            .padding()
        }
        
        .onAppear {
                    bleLand.startUpCentralManager()
                }
        .onReceive(bleLand.$isBluetoothReady) { newValue in
            isBluetoothReady = newValue
        }
        .onReceive(bleLand.$isDeviceFound) { newValue in
            isDeviceFound = newValue
        }
        .onReceive(bleLand.$isConnectionComplete) { newValue in
            isConnectionComplete = newValue
        }
        .onReceive(bleLand.$isServiceScanComplete) { newValue in
            isServiceScanComplete = newValue
        }
        .onReceive(bleLand.$isCharacteristicScanComplete) { newValue in
            isCharacteristicScanComplete = newValue
        }
    }
}
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
    }
}
