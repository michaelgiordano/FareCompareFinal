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

class ViewController: UIViewController {
    
    let ridesClient = RidesClient()
    let button = RideRequestButton()
    
    var list = [[String: JSON]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //button.delegate = self
        
        let parameters: Parameters = [
            "start_latitude": "37.7752315",
            "start_longitude": "-122.418075",
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token PxtTExlVkXCfJcsrCsCagaLvQs6j54LLm-UZrVMR",
            "Accept-Language": "en_US",
            "Content-Type" : "application/json"
        ]
        
        Alamofire.request("https://api.uber.com/v1.2/estimates/time",
          parameters: parameters,
          encoding: URLEncoding(destination: .queryString),
          headers: headers).validate().responseJSON { response in
            let x = JSON(response.result.value!)
            print(x["times"]["estimate"])
            print(x["times"])
            print(x["times"]["display_name"])
            self.parse(json: x)
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                self.parse(json: json)
//            case .failure(let error):
//                print(error)
//            }
            
        }
        
        print(list)
    }
    func parse(json: JSON) {
        for result in json["times"].arrayValue {
            let estimate = result["estimate"]
            let displayName = result["display_name"]
    1
        }
    }
    
    func rideRequestButtonDidLoadRideInformation(button: RideRequestButton) {
        button.sizeToFit()
        button.center = view.center
    }
    
    // Swift

    
    // Mark: LoginButtonDelegate
    
}





