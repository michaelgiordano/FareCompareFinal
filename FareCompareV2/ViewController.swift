//
//  ViewController.swift
//  FareCompareV2
//
//  Created by hello on 10/7/2017.
//  Copyright © 2017 Cipher. All rights reserved.
//

import UIKit
import UberRides
import CoreLocation

class ViewController: UIViewController {
    
    let scopes: [RidesScope] = [.Profile, .Places, .Request]
    let loginManager = LoginManager(loginType: .native)

    let button = RideRequestButton()
    let ridesClient = RidesClient()
    let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
    let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
    let dropoffNickname = "Work"

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton : LoginButton = LoginButton(frame: CGRect.zero, scopes: scopes, loginManager: loginManager)
        var builder = RideParametersBuilder().setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: dropoffNickname)
        
        // Do any additional setup after loading the view, typically from a nib.
        loginButton.presentingViewController = self
        loginButton.delegate = self as? LoginButtonDelegate
        view.addSubview(loginButton)
        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
            product, response in
            if let productID = product?.productID {
                builder = builder.setProductID(productID)
                self.button.rideParameters = builder.build()
                print(self.button.rideParameters)
                self.button.loadRideInformation()
                print(self.button.loadRideInformation())
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Swift

    
    // Mark: LoginButtonDelegate
    
    public func loginButton(button: LoginButton, didLogoutWithSuccess success: Bool) {
        // success is true if logout succeeded, false otherwise
    }
    
    public func loginButton(button: LoginButton, didCompleteLoginWithToken accessToken: AccessToken?, error: NSError?) {
        if let _ = accessToken {
            // AccessToken Saved
        } else if let error = error {
            // An error occured
        }
    }


}

