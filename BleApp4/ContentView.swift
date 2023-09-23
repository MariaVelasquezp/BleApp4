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
    @State var isBluetoothReady = false
    @State var ChoiceMadeAmp = "Amplitude (µA)"
    @State var ChoiceMadeFreq = "Frequency (Hz)"
    @State private var isConnectButtonEnabled = true
    @State private var isDiscoverServicesButtonEnabled = true
    @State private var isConnectionComplete = false
    @State private var isDeviceFound = false
    @State private var isServiceScanComplete = false
    @State private var isCharacteristicScanComplete = false
    @State private var isDiscoverCharacteristicsButtonEnabled = false
    @State private var selectedPeripheral: CBPeripheral?
    @Binding var selectedTab: Int


    
    var body: some View {
        TabView(selection: $selectedTab) {
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
            
            //MARK: CONNECT TO DEVICE
                        Button(action: {
                            if bleLand.isDeviceFound {
                                bleLand.connectToDevice()
                            }
                        }) {
                            Text("Connect to device")
                        }
                        .disabled(!bleLand.isDeviceFound)
                        .padding()
                        //MARK: DISCOVER SERVICES
                        Button(action: {
                          bleLand.discoverServices()
                        }) {
                          Text("Discover Services")
                        }
                        .disabled(!bleLand.isConnectionComplete) // || !isDiscoverServicesButtonEnabled)
                        .padding()
                        //MARK: DISCOVER CHARACTERISTICS
                        Button(action: {
                          bleLand.discoverCharacteristics()
                        }) {
                          Text("Discover Characteristics")
                        }
                        .disabled(!bleLand.isServiceScanComplete || !bleLand.isDiscoverCharacteristicsButtonEnabled || bleLand.isDisconnected || !bleLand.isConnectionComplete)
                        .padding()
                        //MARK: AMPLITUDE
                        Menu{
                          Button(action: {
                            let value: UInt8 = 0x80
                            bleLand.writeLedCharacteristicForAmplitude(val: UInt8(value))
                            ChoiceMadeAmp = "250µA"
                          }, label:{
                            Text("250µA")
                          })
                          Button(action: {
                            let value: UInt8 = 0x90
                            bleLand.writeLedCharacteristicForAmplitude(val: UInt8(value))
                            ChoiceMadeAmp = "200µA"
                          }, label:{
                            Text("200µA")
                          })
                          Button(action: {
                            let value: UInt8 = 0x91
                            bleLand.writeLedCharacteristicForAmplitude(val: UInt8(value))
                            ChoiceMadeAmp = "150µA"
                          }, label:{
                            Text("150µA")
                          })
                          Button(action: {
                            let value: UInt8 = 0x92
                            bleLand.writeLedCharacteristicForAmplitude(val: UInt8(value))
                            ChoiceMadeAmp = "100µA"
                          }, label:{
                            Text("100µA")
                          })
                          Button(action: {
                            let value: UInt8 = 0x93
                            bleLand.writeLedCharacteristicForAmplitude(val: UInt8(value))
                            ChoiceMadeAmp = "50µA"
                          }, label:{
                            Text("50µA")
                          })
                        } label: {
                          Label (
                            title: {Text("\(ChoiceMadeAmp)")},
                            icon: {Image(systemName: "plus")}
                          )
                        }
                        .disabled(!bleLand.isCharacteristicScanComplete || bleLand.isDisconnected || !bleLand.isConnectionComplete)
                        .padding()
                        //MARK: FREQUENCY
                        Menu{
                          Button(action: {
                            let value: UInt8 = 0x30
                            bleLand.writeLedCharacteristicForFrequency(val: UInt8(value))
                            print("Sending frequency: \(value)")
                            ChoiceMadeFreq = "1Hz"
                          }) {
                            Text("1Hz")
                          }
                          Button(action: {
                            let value: UInt8 = 0x40
                            bleLand.writeLedCharacteristicForFrequency(val: UInt8(value))
                            print("Sending frequency: \(value)")
                            ChoiceMadeFreq = "2Hz"
                          }) {
                            Text("2Hz")
                          }
                          Button(action: {
                            let value: UInt8 = 0x50
                            bleLand.writeLedCharacteristicForFrequency(val: UInt8(value))
                            print("Sending frequency: \(value)")
                            ChoiceMadeFreq = "4Hz"
                          }) {
                            Text("4Hz")
                          }
                          Button(action: {
                            let value: UInt8 = 0x60
                            bleLand.writeLedCharacteristicForFrequency(val: UInt8(value))
                            print("Sending frequency: \(value)")
                            ChoiceMadeFreq = "10Hz"
                          }) {
                            Text("10Hz")
                          }
                        } label: {
                          Label (
                            title: {Text("\(ChoiceMadeFreq)")},
                            icon: {Image(systemName: "plus")}
                          )
                        }
                        .disabled(!bleLand.isCharacteristicScanComplete || bleLand.isDisconnected || !bleLand.isConnectionComplete)
                        .padding()
                        //MARK: DISCONNECT
                        Button(action: {
                          bleLand.disconnectDevice()
                          isDiscoverCharacteristicsButtonEnabled = false
                          ChoiceMadeAmp = "Amplitude (µA)"
                          ChoiceMadeFreq = "Frequency (Hz)"
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
                    .onReceive(bleLand.$isDisconnected) { newValue in
                      if newValue {
                        isDiscoverCharacteristicsButtonEnabled = false
                        isServiceScanComplete = false
                        isCharacteristicScanComplete = false
                      }
            }

            // Peripheral List Tab
            PeripheralListView(bleLand: bleLand, selectedTab: $selectedTab)
        }
    }
}
