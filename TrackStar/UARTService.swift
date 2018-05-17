//
//  UARTService.swift
//  TrackStar
//
//  Created by Chris Hinkle on 5/12/18.
//

import Foundation
import CoreBluetooth


enum UARTServiceIdentifier:String
{
    case service    = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    case rx         = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    case tx         = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
    
    var uuid:CBUUID
    {
        return CBUUID( string:rawValue )
    }
}


class UARTService:NSObject
{
    let service:CBMutableService
        
    override init( )
    {
        let tx = CBMutableCharacteristic.init( type:UARTServiceIdentifier.tx.uuid, properties:[ .write, .writeWithoutResponse ], value:nil, permissions: [.writeable] )
        let rx = CBMutableCharacteristic.init( type:UARTServiceIdentifier.rx.uuid, properties: [.read, .notify], value:nil, permissions:[.readable] )
        service = CBMutableService.init( type:UARTServiceIdentifier.service.uuid, primary:true )
        service.characteristics = [ tx, rx ]
    }
}
