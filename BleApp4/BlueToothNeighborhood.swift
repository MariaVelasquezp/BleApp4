import Foundation
import CoreBluetooth
import Combine

private struct BLEParameters {
    static let AmpFreqService = CBUUID(string: "00000000-0000-1000-8000-00805F9B34F0")
    static let FrequencyCharactersticUUID = CBUUID(string:"00000000-0000-1000-8000-00805F9B34F1")
    static let AmplitudeCharactersticUUID = CBUUID(string:"00000000-0000-1000-8000-00805F9B34F2")
}

class BlueToothNeighborhood: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    @Published var isBluetoothReady = false
    @Published var isDeviceFound = false
    @Published var isConnectionComplete = false
    @Published var isServiceScanComplete = false
    @Published var isCharacteristicScanComplete = false
    @Published var capsenseNotifySwitchIsOn = false
    @Published var isDiscoverCharacteristicsButtonEnabled = false
    @Published var isDisconnected = false
    @Published var selectedTab: Int = 1
    @Published var discoveredPeripherals: [CBPeripheral] = []
    
    var selectedPeripheral: CBPeripheral?
    var isLedCharacteristicAvailable: Bool {
        return FrequencyCharacteristic != nil
    }
    @Published var isCharacteristicScanEnabled = false {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
     
    private var centralManager: CBCentralManager!
    private var AmpFreqBoard: CBPeripheral?
    private var AmpFreqService: CBService?
    private var FrequencyCharacteristic: CBCharacteristic?
    private var AmplitudeCharacteristic: CBCharacteristic?
    //private var capsenseValueSubject = CurrentValueSubject<Int, Never>(0)
        
        /*var capsenseValuePublisher: AnyPublisher<Int, Never> {
            capsenseValueSubject.eraseToAnyPublisher()
        }*/
    
        var isConnectButtonEnabled: Bool {
            !isConnectionComplete
        }

        var isDisconnectButtonEnabled: Bool {
            isConnectionComplete
        }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startUpCentralManager() {
        isBluetoothReady.toggle()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothReady = true
            print("Bluetooth is on")
        default:
            break
        }
    }
    
    func discoverDevice() {
        print("Starting scan")
        centralManager.scanForPeripherals(withServices: [BLEParameters.AmpFreqService], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if AmpFreqBoard == nil {
            print("Found a new Peripheral advertising amplitude frequency service")
            AmpFreqBoard = peripheral
            //centralManager.connect(peripheral, options: nil)
            discoveredPeripherals.append(peripheral)
            isDeviceFound = true
            centralManager.stopScan()
        }
    }
    
    func connectToDevice() {
            guard let AmpFreqBoard = AmpFreqBoard else {
                print("No AmpFreq found")
                return
            }
            
            centralManager.connect(AmpFreqBoard, options: nil)
            isServiceScanComplete = false
                isCharacteristicScanComplete = false
                isDiscoverCharacteristicsButtonEnabled = false
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            if let AmpFreqBoard = AmpFreqBoard {
                print("Connection complete \(AmpFreqBoard) \(peripheral)")
                AmpFreqBoard.delegate = self
                DispatchQueue.main.async {
                    self.isConnectionComplete = true
                }
            }
        }

    
    func discoverServices() {
        guard let AmpFreqBoard = AmpFreqBoard else {
            print("Error: AmpFreq is nil")
            return
        }
        
        AmpFreqBoard.discoverServices(nil)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered services")
        if let services = peripheral.services {
            for service in services {
                print("Found service \(service)")
                if service.uuid == BLEParameters.AmpFreqService {
                    AmpFreqService = service
                }
            }
        }
        isServiceScanComplete = true
        isDiscoverCharacteristicsButtonEnabled = true
    }
    
    func discoverCharacteristics() {
        guard let AmpFreqBoard = AmpFreqBoard, let AmpFreqService = AmpFreqService else {
            print("Error: AmpFreq or FreqAmpService is nil")
            return
        }
        
        AmpFreqBoard.discoverCharacteristics(nil, for: AmpFreqService)
        isCharacteristicScanEnabled = true
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard service.characteristics != nil else {
            print("No characteristics found for service: \(service)")
            return
        }
        
        print("Discovered characteristics for service: \(service)")
        
        for characteristic in service.characteristics ?? [] {
            print("Found characteristic: \(characteristic)")
            
            switch characteristic.uuid {
            case BLEParameters.AmplitudeCharactersticUUID:
                AmplitudeCharacteristic = characteristic
            case BLEParameters.FrequencyCharactersticUUID:
                FrequencyCharacteristic = characteristic
            default:
                break
            }
        }
        isCharacteristicScanComplete = true
    }
    
    func disconnectDevice() {
        if let AmpFreqBoard = AmpFreqBoard {
            centralManager.cancelPeripheralConnection(AmpFreqBoard)
        }
        isDisconnected = true
        isDeviceFound = false
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected \(peripheral)")
        AmpFreqBoard = nil
        isConnectionComplete = false
        isDisconnected = false
    }
    
    func stopScanning() {
            centralManager.stopScan()
        }
    
    func writeLedCharacteristicForFrequency(val: UInt8) {
        print("Received frequency: \(val)")
        guard let AmpFreqBoard = AmpFreqBoard, let FrequencyCharacteristic = FrequencyCharacteristic else {
            print("Error: AmpFreq or FrequencyCharacteristic is nil")
            return
        }
        
        var value = val
        
        let ns = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
        AmpFreqBoard.writeValue(ns as Data, for: FrequencyCharacteristic, type: .withResponse)

        print("Value: \(value)")

    }

    func writeLedCharacteristicForAmplitude(val: UInt8) {
        print("Received frequency: \(val)")
        guard let AmpFreqBoard = AmpFreqBoard, let FrequencyCharacteristic = FrequencyCharacteristic else {
            print("Error: AmpFreq or AmplitudeCharacteristic is nil")
            return
        }
        
        var value = val
        
        let ns = NSData(bytes: &value, length: MemoryLayout<UInt8>.size)
        AmpFreqBoard.writeValue(ns as Data, for: FrequencyCharacteristic, type: .withResponse)

        print("Value: \(value)")

    }
}
