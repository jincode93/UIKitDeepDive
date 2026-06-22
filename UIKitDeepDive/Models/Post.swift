//
//  Post.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

struct Post: Codable, Hashable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    
    var isBookmarked: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case userId, id, title, body
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.body == rhs.body
    }
}
