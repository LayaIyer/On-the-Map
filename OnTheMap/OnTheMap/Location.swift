//
//  Location.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/24/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation


struct Location: Codable {
    
    let objectId: String
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let updatedAt: String
    
    var locationLabel: String {
        var name = ""
        if let firstName = firstName {
            name = firstName
        }
        if let lastName = lastName {
            if name.isEmpty {
                name = lastName
            } else {
                name += " \(lastName)"
            }
        }
        if name.isEmpty {
            name = "No name provided"
        }
        return name
    }
    
}
