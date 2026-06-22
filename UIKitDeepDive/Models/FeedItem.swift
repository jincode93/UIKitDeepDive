//
//  FeedItem.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

enum FeedItem: Hashable {
    case textPost(Post)
    case imagePost(Post)
    case loading
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .textPost(let post), .imagePost(let post):
            hasher.combine(post.id)
        case .loading:
            hasher.combine("loading")
        }
    }
    
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        switch (lhs, rhs) {
        case (.textPost(let a), .textPost(let b)):
            return a == b
        case (.imagePost(let a), .imagePost(let b)):
            return a == b
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
}
