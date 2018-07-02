//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Laya Iyer on 3/25/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct StudentInfo: Codable{
    let user: User
}

struct User: Codable {
    let name: String
    enum CodingKeys: String, CodingKey {
        case name = "nickname"
    }
}

struct UserSession: Codable {
    let account: Account?
    let session: Session?
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}
