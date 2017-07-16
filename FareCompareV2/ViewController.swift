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
    var startLat = 0.00
    var startLong = 0.00
    var endLat = 0.00
    var endLong = 0.00
    var pickupNickname = ""
    var dropoffNickname = ""
    var lyftBearerToken = "" //Lyft bearer token set by create access token as type "String"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("View Did Load")
        if startLat == 0.00 || startLong == 0.00 || endLat == 0.00 || endLong == 0.00 || pickupNickname == "" || dropoffNickname == ""
        {
            print("not enough params to refesh")
        }
        else
        {
            print("calling refresh from view did load")
            refresh()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(false)
        print("View Did Appear")
        if startLat == 0.00 || startLong == 0.00 || endLat == 0.00 || endLong == 0.00 || pickupNickname == "" || dropoffNickname == ""
        {
            print("not enough params to refesh")
            print("\(startLat), \(startLong), \(endLat), \(endLong), \(pickupNickname), \(dropoffNickname)")
        }
        else
        {
            print("calling refresh from view did appear")
            refresh()
        }
    }
    
    // LYFT METHODS --

    func createAccessToken() //creates new lyft access (bearer) token -- each only lasts 1 day
    {
        //Creating lyft access token --
        let user = "Mdlycve9fovu"
        let password = "71nh2vP-aQwVzR4inI8b_dD6TSWucgei"
        
        let headersLyft: HTTPHeaders = ["Content-Type": "application/json"]
        let paramsLyft: Parameters = ["grant_type" : "client_credentials",
                                      "scope" : "public"]
        
        Alamofire.request("https://api.lyft.com/oauth/token", parameters: paramsLyft, encoding: JSONEncoding.default, headers: headersLyft).authenticate(user: user, password: password)
            .responseJSON { response in
                print("Response request: \(response.result)")
                print("OAuth Token: \(response.result.value)")
                self.parseLyft(json: JSON(response.result.value!))
        }
        /* 
         
         This function does not work for some reason, so paste this into terminal instead and then set global var 'lyftBearerToken' to the response you get:
 
         curl -X POST -H "Content-Type: application/json" \
         --user "Mdlycve9fovu:71nh2vP-aQwVzR4inI8b_dD6TSWucgei" \
         -d '{"grant_type": "client_credentials", "scope": "public"}' \
         'https://api.lyft.com/oauth/token'
 
        */
    }
    
    func parseLyft(json: JSON) //to be used with create AccessToken() in future for getting new lyft access tokens (every 24 hrs)
    {
        let token = json["access_token"]
        lyftBearerToken = "\(token)"
        //print(token)
    }
    
    // Getting Lyft ride price based on arrival and destinaton
    func getLyftRidePrice(start_lat: Double, start_lng: Double, end_lat: Double, end_lng: Double)
    {
        let token:JSON = "/UU/LnAYqmMYALaXg5HEghKoCD/GZlduLXMCZ+AFUGw7o4p/9+6aHzNpK0BPyekxvsS1h+n1N7xLlHhe6z22zuuJeDs2y6cwDh/X7HfXvxAWt6cQZaY2N9A="
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
                            self.helperLyftPrice(json: JSON(response.result.value as Any))
        }
    }
    
    // Helper method for lyft price(setting labels)
    func helperLyftPrice(json :JSON)
    {
        for part in json["cost_estimates"].arrayValue
        {
            let min = part["estimated_cost_cents_min"].int!
            let max = part["estimated_cost_cents_max"].int!
            lyftPrice = "Price: $\(min/100)-$\(max/100)"
            lyftPriceLabel.text = lyftPrice
            print("Lyft \(lyftPrice)")
        }
    }
    
    // Getting amount of time for the driver to get to the passenger
    func getLyftETA(start_lat: Double, start_lng: Double, end_lat: Double, end_lng: Double)
    {
        let token:JSON = "/UU/LnAYqmMYALaXg5HEghKoCD/GZlduLXMCZ+AFUGw7o4p/9+6aHzNpK0BPyekxvsS1h+n1N7xLlHhe6z22zuuJeDs2y6cwDh/X7HfXvxAWt6cQZaY2N9A="
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
    
    // Helper method for lyft eta(setting labels)
    func helperLyftETA(json :JSON)
    {
        for part in json["eta_estimates"].arrayValue
        {
            let eta = part["eta_seconds"].int! / 60
            lyftTime = "Time: \(eta) mins"
            lyftTimeLabel.text = lyftTime
            print("Lyft \(lyftTime)")
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
        print("uberXTime: \(uberXTime) mins")
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
    
    func refresh() //refreshes the whole screen, lyft and uber ride prices, times, and buttons as well as location nicknames of both locations
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
        let dropoffLocation = CLLocation(latitude: Double(endLat), longitude: Double(endLong))
        let builder = RideParametersBuilder().setDropoffLocation(dropoffLocation, nickname: dropoffNickname)
        button.rideParameters = builder.build()
        uberButton.center = CGPoint(x: view.frame.width/2, y: 365) //position the button
        view.addSubview(uberButton) //put the button in the view
        // --
        let btnLyft = LyftButton() //ride request button
        btnLyft.style = LyftButtonStyle.hotPink //making the button pink
        btnLyft.center = CGPoint(x: view.frame.width/2, y: 607) //position the button
        let pickup = CLLocationCoordinate2D(latitude: startLat, longitude: startLong)
        let destination = CLLocationCoordinate2D(latitude: endLat, longitude: endLong)
        btnLyft.configure(rideKind: LyftSDK.RideKind.Standard, pickup: pickup, destination: destination)
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
    
    func partialRefresh(sender: String) //refreshes the nickname of the given location when one location is inputted
    {
        print("Partial Refresh: \(sender)")
        if sender == "pickup"
        {
            if pickupNickname != ""
            {
                pickupLabel.setTitle(pickupNickname,for: .normal)
            }
        }
        else if sender == "dropoff"
        {
            if dropoffNickname != ""
            {
            dropoffLabel.setTitle(dropoffNickname,for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) //runs segues from view controller to map and second map view controllers
    {
    }
    
    @IBAction func unwindToInitialViewController(segue: UIStoryboardSegue) //gets data back from map view controllers
    {
        if let sourceViewController = segue.source as? MapViewController //checks if segue is from MapViewController
        {
            print("Segue Source Title: \(sourceViewController.theSource)")
            if (sourceViewController.theSource) == "pickup" //confirms the source inside the view contrller
            {
                print("unwinding")
                theSender = "pickup" //sets the global sender var in ViewController so that partialRefresh() will know what to resfresh
                pickupNickname = (sourceViewController.nickname) //get all the data:
                startLat = (sourceViewController.lat)
                startLong = (sourceViewController.long)
                print("pickup params passed back")
                partialRefresh(sender: theSender)
            }
        }
        else if let sourceViewController = segue.source as? SecondMapViewController //checks if segue is from SecondMapViewController
        {
            print("Segue Source Title: \(sourceViewController.theSource)")
            if (sourceViewController.theSource) == "dropoff" //confirms the source inside the view contrller
            {
                print("unwinding")
                theSender = "dropoff" //sets the global sender var in ViewController so that partialRefresh() will know what to resfresh
                dropoffNickname = (sourceViewController.nickname) //get all the data:
                endLat = (sourceViewController.lat)
                endLong = (sourceViewController.long)
                print("dropoff params passed back")
                partialRefresh(sender: theSender)
            }
        }
        else
        {
            print("ERROR: failed to recognize view controller identifier") //print error if segue source doesn't match either map view controller
        }
    }
}

