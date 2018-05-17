//
//  TrackStar.swift
//  TrackStar
//
//  Created by Chris Hinkle on 5/12/18.
//

import Foundation
import CoreBluetooth
import GameController

let VehicleIdentifier = UUID.init( uuidString:"265B66D6-28F8-D0BA-2BD6-EDC7519CAFAA" )

extension CBPeripheral
{
    var isVehicle:Bool
    {
        return identifier == VehicleIdentifier
    }
    
    var UARTService:CBService?
    {
        return services?.first( )
        {
            ( service )-> Bool in
            return service.uuid == UARTServiceIdentifier.service.uuid
        }
    }
}

extension CBService
{
    var rx:CBCharacteristic?
    {
        guard uuid == UARTServiceIdentifier.service.uuid else
        {
            return nil
        }
        
        return characteristics?.first( )
        {
            ( characteristic )->Bool in
            return characteristic.uuid == UARTServiceIdentifier.rx.uuid
        }
    }
}

extension Notification.Name
{
    static let TrackStarDidReady = Notification.Name.init( "TrackStarDidReady" )
    static let TrackStarDidDisconnect = Notification.Name.init( "TrackStarDidDisconnect" )
}

class TrackStar:NSObject
{
    static let shared = TrackStar.init( )
    
    override init( )
    {
        super.init( )
        let ctr = NotificationCenter.default
        ctr.addObserver( forName:.GCControllerDidConnect, object:nil, queue:nil )
        {
            ( notification ) in
            guard let extGamePad = GCController.controllers( ).first?.extendedGamepad else
            {
                return
            }
            self.controller = extGamePad
        }
    }
    
    var controller:GCExtendedGamepad?
    {
        didSet
        {
            if let controller = controller
            {
                controller.valueChangedHandler =
                {
                    ( pad, element ) in
                    print( "value changed: \( element )" )
                }
                print( "got a controller: \( controller )" )
            }
        }
    }
    
    let queue:DispatchQueue = .init( label:"com.lilhinx.trackstar.central", attributes:[ ] )
    var central:CBCentralManager?
    
    func start( )
    {
        central = CBCentralManager.init( delegate:self, queue:queue )
    }
    
    var vehicle:TrackStarVehicle?
    
    func scanForVehicle( )
    {
        guard let central = central else
        {
            return
        }
        print( "starting vehicle scan" )
        central.scanForPeripherals( withServices:[ UARTServiceIdentifier.service.uuid ], options:[:] )
    }
    
    func scanForController( )
    {
        print( "starting controller scan" )
        GCController.startWirelessControllerDiscovery
        {
            print( "complete: \( GCController.controllers( ) )" )
        }
    }
}

class TrackStarVehicle:NSObject, CBPeripheralDelegate
{
    let peripheral:CBPeripheral
    let throttler:Throttler
    init( peripheral:CBPeripheral )
    {
        self.peripheral = peripheral
        self.throttler = Throttler.init( maxInterval:0.05 )
        super.init( )
        peripheral.delegate = self
    }
    
    
    var throttle:UInt16 = 0
    {
        didSet
        {
            throttler.throttle
            {
                [weak self] in
                self?.update( )
            }
            
        }
    }
    
    var steering:UInt8 = 90
    {
        didSet
        {
            throttler.throttle
            {
                [weak self] in
                self?.update( )
            }
        }
    }
    
    func updateMessage( )->Data
    {
        var data = Data( )
        data += "!C"
        data += throttle
        data += steering
        data.appendCrc( )
        return data
    }
    
    
    
    func update( )
    {
        guard let uart = peripheral.UARTService else
        {
            return
        }
        
        guard let rx = uart.rx else
        {
            return
        }
        
        peripheral.writeValue( updateMessage( ), for:rx, type:.withResponse )
    }
    
    public func peripheral( _ peripheral:CBPeripheral, didModifyServices invalidatedServices:[CBService] )
    {
        print( "invalidatedServices: \( invalidatedServices )" )
    }
    
    public func peripheral( _ peripheral:CBPeripheral, didDiscoverServices error:Error? )
    {
        print( "didDiscoverServices \( error?.localizedDescription ?? "" )" )
        if let UARTService = peripheral.UARTService
        {
            peripheral.discoverCharacteristics( [ UARTServiceIdentifier.rx.uuid ], for:UARTService )
        }
    }
    
    public func peripheral( _ peripheral:CBPeripheral, didDiscoverCharacteristicsFor service:CBService, error:Error? )
    {
        print( "didDiscoverCharacteristicsFor" )
        if let error = error
        {
            print( "error: \( error )" )
            return
        }
        NotificationCenter.default.post( name:.TrackStarDidReady, object:TrackStar.shared )
    }
    
    
    public func peripheral( _ peripheral: CBPeripheral, didUpdateValueFor characteristic:CBCharacteristic, error:Error? )
    {
        print( "didUpdateValueFor characteristic" )
    }
    
    
    
    public func peripheral( _ peripheral:CBPeripheral, didWriteValueFor characteristic:CBCharacteristic, error:Error? )
    {
        print( "update" )
        if let error = error
        {
            print( "error: \( error.localizedDescription )" )
        }
    }
}

extension TrackStar:CBCentralManagerDelegate
{
    public func centralManagerDidUpdateState( _ central:CBCentralManager )
    {
        switch central.state
        {
        case .poweredOff:
            print( "poweredOff" )
        case .poweredOn:
            scanForVehicle( )
            scanForController( )
        case .resetting:
            print( "resetting" )
        case .unauthorized:
            print( "unauthorized" )
        case .unknown:
            print( "unknown" )
        case .unsupported:
            print( "unsupported" )
        }
    }
    
    public func centralManager( _ central:CBCentralManager, didDiscover peripheral:CBPeripheral, advertisementData:[String : Any], rssi RSSI:NSNumber )
    {
        print( advertisementData )
    }
    
    public func centralManager( _ central:CBCentralManager, didConnect peripheral:CBPeripheral )
    {
        print( "did connect" )
        guard let vehicle = vehicle, vehicle.peripheral.identifier == peripheral.identifier else
        {
            return
        }
        peripheral.discoverServices( [ UARTServiceIdentifier.service.uuid ] )
    }
    
    public func centralManager( _ central:CBCentralManager, didFailToConnect peripheral:CBPeripheral, error:Error? )
    {
        print( "did fail connect" )
    }
    
    public func centralManager( _ central:CBCentralManager, didDisconnectPeripheral peripheral:CBPeripheral, error:Error? )
    {
        print( "did disconnect" )
        self.vehicle = nil
        NotificationCenter.default.post( name:.TrackStarDidDisconnect, object:self )
        if !central.isScanning
        {
            scanForVehicle( )
        }
    }
}


