//
//  LocationCell.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/24/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class LocationCell: UITableViewCell {
    
    static let identifier = "LocationCell"
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelUrl: UILabel!
    
    func configWith(_ info: StudentInformation) {
        labelName.text = info.labelName
        labelUrl.text = info.mediaURL
    }
}
