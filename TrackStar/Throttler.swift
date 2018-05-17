//  Throttler.swift
//
//  Created by Daniele Margutti on 10/19/2017
//
//  web: http://www.danielemargutti.com
//  email: hello@danielemargutti.com
//
//  Updated by Ignazio Calò on 19/10/2017.

import Foundation

public class Throttler
{
    private let queue:DispatchQueue
    private var job:DispatchWorkItem = DispatchWorkItem( block:{} )
    private var previousRun: Date = Date.distantPast
    private var maxInterval:TimeInterval = 1.0
    
    init( maxInterval:TimeInterval, queue:DispatchQueue = DispatchQueue.global( qos:.background ) )
    {
        self.queue = queue
        self.maxInterval = maxInterval
    }
    
    
    func throttle( block:@escaping( )->( ) )
    {
        job.cancel( )
        job = DispatchWorkItem( )
            {
                [weak self] in
                self?.previousRun = Date( )
                block( )
        }
        let elapsed = Date( ).timeIntervalSince( previousRun )
        let delay = elapsed > maxInterval ? 0.0 : maxInterval
        queue.asyncAfter( deadline:.now( ) + delay, execute:job )
    }
    
    func cancel( )
    {
        job.cancel( )
    }
}
