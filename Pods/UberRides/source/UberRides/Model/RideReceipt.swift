//
//  RideReceipt.swift
//  UberRides
//
//  Copyright © 2016 Uber Technologies, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import ObjectMapper

// MARK: RideReceipt

/**
 *  Get the receipt information of a completed request that was made with the request endpoint.
 */
@objc(UBSDKRideReceipt) public class RideReceipt: NSObject {
    
    /// Adjustments made to the charges such as promotions, and fees.
    public fileprivate(set) var chargeAdjustments: [RideCharge]?
    
    /// Describes the charges made against the rider.
    public fileprivate(set) var charges: [RideCharge]?
    
    /// ISO 4217
    public fileprivate(set) var currencyCode: String?
    
    /// Distance of the trip charged.
    public fileprivate(set) var distance: String?
    
    /// The localized unit of distance.
    public fileprivate(set) var distanceLabel: String?
    
    /// Time duration of the trip in ISO 8601 HH:MM:SS format.
    public fileprivate(set) var duration: String?
    
    /// The summation of the charges array.
    public fileprivate(set) var normalFare: String?
    
    /// Unique identifier representing a Request.
    public fileprivate(set) var requestID: String?
    
    /// The summation of the normal fare and surge charge amount.
    public fileprivate(set) var subtotal: String?
    
    /// Describes the surge charge. May be null if surge pricing was not in effect.
    public fileprivate(set) var surgeCharge: RideCharge?
    
    /// The total amount charged to the users payment method. This is the the subtotal (split if applicable) with taxes included.
    public fileprivate(set) var totalCharged: String?
    
    /// The total amount still owed after attempting to charge the user. May be 0 if amount was paid in full.
    public fileprivate(set) var totalOwed: Double = 0.0
    
    public required init?(map: Map) {
    }
}

extension RideReceipt: UberModel {
    public func mapping(map: Map) {
        chargeAdjustments <- map["charge_adjustments"]
        charges           <- map["charges"]
        currencyCode      <- map["currency_code"]
        distance          <- map["distance"]
        distanceLabel     <- map["distance_label"]
        duration          <- map["duration"]
        normalFare        <- map["normal_fare"]
        requestID         <- map["request_id"]
        subtotal          <- map["subtotal"]
        surgeCharge       <- map["surge_charge"]
        totalCharged      <- map["total_charged"]
        totalOwed         <- map["total_owed"]
    }
}
