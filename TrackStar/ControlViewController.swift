//
//  ControlViewController.swift
//  TrackStar
//
//  Created by Chris Hinkle on 5/12/18.
//

import UIKit

class ControlViewController:UIViewController
{
    override func viewWillAppear( _ animated:Bool )
    {
        super.viewWillAppear( animated )
        
        NotificationCenter.default.addObserver( forName:.TrackStarDidDisconnect, object:TrackStar.shared, queue:.main )
        {
            [weak self]( notification ) in
            self?.performSegue( withIdentifier:"Disconnect", sender:nil )
        }
        
        
    }
    

    @IBAction func throttle_changed( _ sender:UISlider )
    {
        guard let vehicle = TrackStar.shared.vehicle else
        {
            return
        }
        
        let throttleValue = UInt16( sender.value )
        vehicle.throttle = throttleValue
    }
    
    @IBAction func steering_changed( _ sender:UISlider )
    {
        guard let vehicle = TrackStar.shared.vehicle else
        {
            return
        }
        
        let steeringValue = UInt8( sender.value )
        vehicle.steering = steeringValue
    }
}
