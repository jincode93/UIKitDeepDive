//
//  User.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

struct User: Codable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
