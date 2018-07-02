//
//  StudentsLocation.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/24/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct StudentsLocation {
    
    static var shared = StudentsLocation()
    
    private init() {}
    
    var studentsInformation = [StudentInformation]()
}
