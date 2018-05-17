//
//  ConnectionViewController.swift
//  TrackStar
//
//  Created by Chris Hinkle on 5/12/18.
//

import UIKit
import CoreBluetooth

class ConnectionViewController:UIViewController
{
    override func viewDidLoad( )
    {
        super.viewDidLoad( )
        NotificationCenter.default.addObserver( forName:.TrackStarDidReady, object:TrackStar.shared, queue:.main )
        {
            [weak self]( notification ) in
            self?.performSegue( withIdentifier:"Ready", sender:nil )
        }
    }
    
    override func viewWillAppear( _ animated:Bool )
    {
        super.viewWillAppear( animated )
        
        
        TrackStar.shared.start( )
    }
    
    @IBAction
    func exit( segue:UIStoryboardSegue )
    {
        
    }
}
