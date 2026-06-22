//
//  Album.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

struct Album: Codable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
