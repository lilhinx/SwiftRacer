//
//  Data+CRC.swift
//  TrackStar
//
//  Created by Chris Hinkle on 5/12/18.
//

import Foundation

extension Data
{
    mutating func appendCrc( )
    {
        var dataBytes = [UInt8]( repeating:0, count:count )
        copyBytes( to:&dataBytes, count:count )
        
        var crc:UInt8 = 0
        for i in dataBytes
        {
            crc = crc &+ i
        }
        crc = ~crc
        append( &crc, count:1 )
    }
}
