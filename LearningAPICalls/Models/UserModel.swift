//
//  UserModel.swift
//  LearningAPICalls
//
//  Created by Kaushal Kumbagowdana on 6/5/23.
//

import Foundation

// Parent Struct
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
    
}

struct Address: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
}

struct Geo: Codable {
    let lat: String
    let lng: String
}

struct Company: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
}
