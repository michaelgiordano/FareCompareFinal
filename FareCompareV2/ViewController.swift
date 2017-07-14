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

class ViewController: UIViewController
{
    
    @IBOutlet weak var uberPriceLabel: UILabel!
    @IBOutlet weak var uberTimeLabel: UILabel!
    @IBOutlet weak var lyftPriceLabel: UILabel!
    @IBOutlet weak var lyftTimeLabel: UILabel!
    @IBOutlet weak var pickupLabel: UIButton!
    @IBOutlet weak var dropoffLabel: UIButton!
    
    var theSender = ""
    let ridesClient = RidesClient()
    let button = RideRequestButton()
    var uberXTime = 0 //in mins
    var uberXPrice = "" //string with $ and -
    var lyftTime = ""
    var lyftPrice = ""
    var startLat = 37.7752315
    var startLong = -122.418075
    var endLat = 37.7752415
    var endLong = -122.518075
    var pickupNickname = ""
    var dropoffNickname = ""

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("View Did Load")
        //button.delegate = self
        
        refresh()
    }
    
    func createAccessToken()
    {
        //Creating access token -------------------------------------------------------------------------------
        let user = "Mdlycve9fovu"
        let password = "71nh2vP-aQwVzR4inI8b_dD6TSWucgei"
        
        let headersLyft: HTTPHeaders = ["Content-Type": "application/json"]
        let paramsLyft: Parameters = ["grant_type" : "client_credentials",
                                      "scope" : "public"]
        
        Alamofire.request("https://api.lyft.com/oauth/token", parameters: paramsLyft, encoding: JSONEncoding.default, headers: headersLyft).authenticate(user: user, password: password)
            .responseJSON { response in
                //    print("OAuth Token: \(response.result.value)")
                self.parseLyft(json: JSON(response.result.value!))
        }
    }
        //-----------------------------------------------------------------------------------------------------
        
    func parseLyft(json: JSON) //future for getting new access tokens
    {
        let token = json["access_token"]
        // self.token = token
        //   print(token)
    }
    
    //-----------------------------------------------------------------------------------------------------
    
    // Getting Lyft ride price based on arrival and destinaton
    
    func getLyftRidePrice(start_lat: Double, start_lng: Double, end_lat: Double, end_lng: Double)
    {
        let token:JSON = "soZ8CE76+NKofh/+kzw8U7NIhR4oRnfqE6omFN5gXhUr6JG5oreA1NOvnCaugYT5CYcXWuj5d3GOs3znlD9MdOCeO0GWwE/nuRH3z2k9ehDVrgq4v7rT3y0="
        let headerRequest: HTTPHeaders = ["Authorization" : "bearer \(token)"]
        let paramsRequest: Parameters = ["start_lat": start_lat,
                                         "start_lng": start_lng,
                                         "end_lat": end_lat,
                                         "end_lng": end_lng,
                                         "ride_type": "lyft"]
        Alamofire.request("https://api.lyft.com/v1/cost",
                          parameters: paramsRequest,
                          encoding: URLEncoding(destination: .queryString),
                          headers: headerRequest).validate().responseJSON { response in
                            self.helperLyftPrice(json: JSON(response.result.value!))
        }
    }
    
    // Helper method (setting labels)
    
    func helperLyftPrice(json :JSON)
    {
        for part in json["cost_estimates"].arrayValue
        {
            let min = part["estimated_cost_cents_min"].int!
            let max = part["estimated_cost_cents_max"].int!
            lyftPrice = "Price: $\(min/100)-$\(max/100)"
            lyftPriceLabel.text = lyftPrice
        }
    }
    
    // Getting amount of time for the driver to get to the passenger
    
    func getLyftETA(start_lat: Double, start_lng: Double, end_lat: Double, end_lng: Double)
    {
        let token:JSON = "soZ8CE76+NKofh/+kzw8U7NIhR4oRnfqE6omFN5gXhUr6JG5oreA1NOvnCaugYT5CYcXWuj5d3GOs3znlD9MdOCeO0GWwE/nuRH3z2k9ehDVrgq4v7rT3y0="
        let headerRequest: HTTPHeaders = ["Authorization" : "bearer \(token)"]
        let paramsRequest: Parameters = ["lat": start_lat,
                                         "lng": start_lng,
                                         "destination_lat": end_lat,
                                         "destination_lng": end_lng,
                                         "ride_type": "lyft"]
        Alamofire.request("https://api.lyft.com/v1/eta",
                          parameters: paramsRequest,
                          encoding: URLEncoding(destination: .queryString),
                          headers: headerRequest).validate().responseJSON { response in
                            self.helperLyftETA(json: JSON(response.result.value!))
        }
    }
    
    // Helper method (setting labels)
    
    func helperLyftETA(json :JSON)
    {
        for part in json["eta_estimates"].arrayValue
        {
            let eta = part["eta_seconds"].int! / 60
            lyftTime = "Time: \(eta) mins"
            lyftTimeLabel.text = lyftTime
        }
    }

    // UBER METHODS --
    
    func uberCallTime(startLat: Double, startLong: Double) //Uber call for time
    {
        let parameters: Parameters =
            [
                "start_latitude": "\(startLat)",
                "start_longitude": "\(startLong)",
        ]
        let headers: HTTPHeaders =
            [
                "Authorization": "Token 4Z9MYJoZ1qKF914OfBqT1Js-kHUl9p9qekDE2h2e",
                "Accept-Language": "en_US",
                "Content-Type" : "application/json",
                ]
        _ = Alamofire.request("https://api.uber.com/v1.2/estimates/time",
                              parameters: parameters,
                              encoding: URLEncoding(destination: .queryString),
                              headers: headers).responseJSON { response in
                                self.uberParseTime(json: JSON(response.result.value!))
        }
    }
    
    func uberCallPrice(startLat: Double, startLong: Double, endLat: Double, endLong: Double) //Uber call for price
    {
        let parameters: Parameters =
            [
                "start_latitude": "\(startLat)",
                "start_longitude": "\(startLong)",
                "end_latitude": "\(endLat)",
                "end_longitude": "\(endLong)",
        ]
        let headers: HTTPHeaders =
            [
                "Authorization": "Token 4Z9MYJoZ1qKF914OfBqT1Js-kHUl9p9qekDE2h2e",
                "Accept-Language": "en_US",
                "Content-Type" : "application/json",
                ]
        _ = Alamofire.request("https://api.uber.com/v1.2/estimates/price",
                              parameters: parameters,
                              encoding: URLEncoding(destination: .queryString),
                              headers: headers).responseJSON { response in
                                self.uberParsePrice(json: JSON(response.result.value!))
        }
    }
    
    func uberParseTime(json: JSON) // (called by func uberCallTime) parses json file from uber time call, picks out time in mins as int, sets global var uberXTime
    {
        for ride in json["times"].arrayValue
        {
            let rideDisplayName = ride["display_name"]
            if rideDisplayName.string! == "uberX"
            {
                if let rideEstimate = ride["estimate"].int
                {
                    uberXTime = rideEstimate/60
                    uberTimeLabel.text = "Time: \(uberXTime) mins"
                }
                else
                {
                    uberXTime = -1
                    print("--------uberXTime Fetch Error--------")
                }
            }
        }
        print("uberXTime: \(uberXTime)")
    }
    
    func uberParsePrice(json: JSON) // (called by func uberCallPrice) parses json file from uber price call, picks out price as string, sets global var uberXPrice
    {
        for ride in json["prices"].arrayValue
        {
            let rideDisplayName = ride["display_name"]
            if rideDisplayName.string! == "uberX"
            {
                uberXPrice = ride["estimate"].string!
                uberPriceLabel.text = "Price: " + uberXPrice
            }
        }
        if uberXPrice == ""
        {
            print("--------uberXPrice Fetch Error--------")
        }
        print("uberXPrice: \(uberXPrice)")
    }
    
    func refresh()
    {
        print("Refresh")
        //LYFT --
        getLyftRidePrice(start_lat: startLat, start_lng: startLong, end_lat: endLat, end_lng: endLong)
        getLyftETA(start_lat: startLat, start_lng: startLong, end_lat: endLat, end_lng: endLong)
        
        // UBER --
        uberCallTime(startLat: startLat, startLong: startLong) //call uber time estimate and set global var uberXTime
        uberCallPrice(startLat: startLat, startLong: startLong, endLat: endLat, endLong: endLong) //call uber price, set global var uberXPrice
        
        //BUTTONS --
        let uberButton = RideRequestButton() //ride request button
        uberButton.center = CGPoint(x: view.frame.width/2, y: 365) //position the button
        view.addSubview(uberButton) //put the button in the view
        // --
        let btnLyft = LyftButton() //ride request button
        btnLyft.style = LyftButtonStyle.hotPink //making the button pink
        btnLyft.center = CGPoint(x: view.frame.width/2, y: 607) //position the button
        view.addSubview(btnLyft) //put the button in the view
        btnLyft.layer.cornerRadius = 9 //rounding button
        btnLyft.clipsToBounds = true //clipping the rounded corners
        
        //NICKNAMES --
        if pickupNickname != ""
        {
            pickupLabel.setTitle(pickupNickname,for: .normal)
        }
        if dropoffNickname != ""
        {
            dropoffLabel.setTitle(dropoffNickname,for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let dvc = segue.destination as! MapViewController
        dvc.sender = self.theSender
    }
    
    @IBAction func unwindToInitialViewController(segue: UIStoryboardSegue)
    {
    }
    
    @IBAction func onPickupButtonTapped(_ sender: Any)
    {
        theSender = "pickup"
    }
    
    @IBAction func onDropoffButtonTapped(_ sender: Any)
    {
        theSender = "dropoff"
    }
}
