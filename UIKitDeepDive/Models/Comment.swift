//
//  Comment.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

struct Comment: Codable, Hashable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
