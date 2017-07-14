//
//  SecondMapViewController.swift
//  FareCompareV2
//
//  Created by hello on 10/7/2017.
//  Copyright © 2017 Cipher. All rights reserved.
//

import UIKit
import MapKit

class SecondMapViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    
    let theSource = "dropoff"
    var lat = 0.00
    var long = 0.00
    var nickname = ""
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        dismiss(animated: true, completion: nil)
        findLocation(location: searchBar.text!)
    }
    
    func findLocation(location: String)
    {
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = location
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) in
            if localSearchResponse == nil
            {
                let alert = UIAlertController(title: "nil", message: "Place Not Found", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let locations = localSearchResponse!.mapItems
            if locations.count > 1  //more than one location found
            {
                let alert = UIAlertController(title: "Select A Location", message: nil, preferredStyle: .actionSheet)
                for location in locations
                {
                    let name = "\(location.placemark.name!), \(location.placemark.administrativeArea!)"
                    let locationAction = UIAlertAction(title: name, style: .default, handler: { (action) in
                        self.displayMap(placemark: location.placemark)
                        self.lat = location.placemark.coordinate.latitude
                        self.long = location.placemark.coordinate.longitude
                        self.nickname = location.name!
                        print("set latitude and longitude and nickname")
                    })
                    alert.addAction(locationAction)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            else //only 1 location
            {
                self.displayMap(placemark: locations.first!.placemark)
                self.lat = locations.first!.placemark.coordinate.latitude
                self.long = locations.first!.placemark.coordinate.longitude
                self.nickname = locations.first!.name!
                print("set latitude and longitude and nickname")
            }
        }
    }
    
    func displayMap(placemark: MKPlacemark)
    {
        navigationItem.title = placemark.name
        let center = placemark.location!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)  //kind of like zoom, how much you will see across the screen
        let region = MKCoordinateRegion(center: center, span: span)
        let pin = MKPointAnnotation()
        pin.coordinate = center
        pin.title = placemark.name
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showSearchBar(_ sender: Any)
    {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
}
