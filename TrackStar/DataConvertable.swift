//
//  DataConvertable.swift
//  TrackStar
//
//  Created by Chris Hinkle on 5/12/18.
//

import Foundation

public protocol DataConvertible
{
    static func + ( lhs:Data, rhs:Self )->Data
    static func += ( lhs:inout Data, rhs:Self )
}

extension DataConvertible
{
    public static func + ( lhs:Data, rhs:Self )->Data
    {
        var value = rhs
        let data = Data( buffer:UnsafeBufferPointer( start:&value, count:1 ) )
        return lhs + data
    }
    
    public static func += ( lhs:inout Data, rhs:Self )
    {
        lhs = lhs + rhs
    }
}

extension UInt8:DataConvertible { }
extension UInt16:DataConvertible { }
extension UInt32:DataConvertible { }

extension Int:DataConvertible { }
extension Float:DataConvertible { }
extension Double:DataConvertible { }

extension String:DataConvertible
{
    public static func + ( lhs:Data, rhs:String )->Data
    {
        guard let data = rhs.data( using:.utf8 ) else
        {
            return lhs
        }
        return lhs + data
    }
}

extension Data:DataConvertible
{
    public static func + ( lhs:Data, rhs:Data )->Data
    {
        var data = Data( )
        data.append( lhs )
        data.append( rhs )
        return data
    }
}
