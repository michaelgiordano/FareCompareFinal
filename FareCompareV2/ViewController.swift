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
import Alamofire
import LyftSDK

class ViewController: UIViewController {
    
    let ridesClient = RidesClient()
    let button = RideRequestButton()
    
    var token :JSON = "soZ8CE76+NKofh/+kzw8U7NIhR4oRnfqE6omFN5gXhUr6JG5oreA1NOvnCaugYT5CYcXWuj5d3GOs3znlD9MdOCeO0GWwE/nuRH3z2k9ehDVrgq4v7rT3y0="
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //button.delegate = self
        
        let parameters: Parameters = [
            "start_latitude": 41.888543,
            "start_longitude": -87.635444,
            "end_latitude": 41.974162,
            "end_longitude": -87.907321
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer KA.eyJ2ZXJzaW9uIjoyLCJpZCI6InN2d2h4RjR2VEtlTkJyZVRnNXJUeWc9PSIsImV4cGlyZXNfYXQiOjE1MDI0ODA5OTcsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0.IYrMGsDH4_zJFfapzJDU5TEHAl0Xw0rr7VlXKbgmdrs",
            "Accept-Language": "en_US",
            "Content-Type" : "application/json"
        ]
        
        Alamofire.request("https://api.uber.com/v1.2/requests/estimate",
                          parameters: parameters,
                          encoding: URLEncoding(destination: .queryString),
                          headers: headers).validate().responseJSON { response in
                            let x = JSON(response.result.value as Any)
                            print(x)
                            self.parse(json: x)
                            
        }
        
        //Creating access token
        let user = "Mdlycve9fovu"
        let password = "71nh2vP-aQwVzR4inI8b_dD6TSWucgei"
        
        let headersLyft: HTTPHeaders = ["Content-Type": "application/json"]
        let paramsLyft: Parameters = ["grant_type" : "client_credentials",
                                      "scope" : "public"]
        
        Alamofire.request("https://api.lyft.com/oauth/token", parameters: paramsLyft, encoding: JSONEncoding.default, headers: headersLyft).authenticate(user: user, password: password)
            .responseJSON { response in
                print("OAuth Token: \(response.result.value)")
                self.parseLyft(json: JSON(response.result.value!))
        }
        //-----------------------------------------------------------------------------------------------------
        
        let headerRequest: HTTPHeaders = ["Authorization" : "bearer \(token)"]
        
        let paramsRequest: Parameters = ["start_lat" : 37.7763,
                                         "start_lng" : -122.3918,
                                         "end_lat" : 37.7972,
                                         "end_lng" : -122.453,
                                         "ride_type" : "lyft"]
        
        Alamofire.request("https://api.lyft.com/v1/cost", method: .get, parameters: paramsRequest, encoding: URLEncoding.default, headers: headerRequest).responseJSON { response in
            print(response.result.value)
            print("hello")
        }
    }
    
    func parseLyft(json: JSON) {
        let token = json["access_token"]
        // self.token = token
        //   print(token)
    }
    
    func parse(json: JSON)
    {
        for ride in json["times"].arrayValue
        {
            let timeToPickup = ride["pickup_estimate"]
            let fare = ride["fare"]["display"]
            let durationTime = ride["trip"]["duration_estimate"]
            
            print(timeToPickup)
            print(fare)
            print(durationTime)
        }
    }
    
    
    
}





