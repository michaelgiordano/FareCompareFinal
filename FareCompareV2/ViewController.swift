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
        
           let request = Alamofire.request("https://api.uber.com/v1.2/estimates/time",
                              parameters: parameters,
                              encoding: URLEncoding(destination: .queryString),
                              headers: headers).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
        
         //   if let json = response.result.value {

                var totalEstimates = [Int]()
                do
                {
                    if let theData = response.result.value as? Data,
                        let json = try JSONSerialization.jsonObject(with: theData) as? [String: Any],
                        let rides = json["estimate"] as? [[String: Any]]
                    {
                        print("theData was deserialized from JSON to Swift")
                        print("theData: \(theData)")
                        for ride in rides
                        {
                            if let estimate = ride["estimate"] as? Int
                            {
                                print("Estimate: \(estimate)")
                                totalEstimates.append(estimate)
                            }
                            else
                            {
                                print("ERROR: failed to read estimate")
                            }
                        }
                    }
                    else
                    {
                        print("ERROR: theData was NOT deserialized")
                    }
                }
                catch
                {
                    print("Error deserializing JSON: \(error)")
                }
                print("totalEstimates: \(totalEstimates)")
//                print("JSON: \(json)[0]['estimate']") // serialized json response
//                print(json)
            }
            
//            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                print("Data: \(utf8Text)") // original server data as UTF8 string
//            }
//        
//        let pickupLocation = CLLocation(latitude: 37.775159, longitude: -122.417907)
//        let dropoffLocation = CLLocation(latitude: 37.6213129, longitude: -122.3789554)
//        
//        //make sure that the pickupLocation and dropoffLocation is set in the Deeplink
//        let builder = RideParametersBuilder()
//            .setPickupLocation(pickupLocation)
//            // nickname or address is required to properly display destination on the Uber App
//            .setDropoffLocation(dropoffLocation,
//                                nickname: "San Francisco International Airport")
//        
//        // use the same pickupLocation to get the estimate
//        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
//            product, response in
//            if let productID = product?.productID { //check if the productID exists
//                builder.setProductID(productID)
//                self.button.rideParameters = builder.build()
//                
//                // show estimate in the button
//                self.button.loadRideInformation()
//            }
//        })
//        
//        // center the button (optional)
//        button.sizeToFit()
//        button.center = view.center
//        
//        //put the button in the view
//        view.addSubview(button)    }
    }
    
    func rideRequestButtonDidLoadRideInformation(button: RideRequestButton) {
        button.sizeToFit()
        button.center = view.center
    }
    
    // Swift

    
    // Mark: LoginButtonDelegate
    
 


}


