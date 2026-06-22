//
//  APIEndpoint.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

enum APIEndpoint {
    case posts(page: Int, limit: Int)
    case post(id: Int)
    case users
    case user(id: Int)
    case comments(postId: Int)
    case albums(userId: Int)
    case picsumList(page: Int, limit: Int)
    
    var url: URL {
        switch self {
        case .posts(let page, let limit):
            return URL(string: "https://jsonplaceholder.typicode.com/posts?_page=\(page)&_limit=\(limit)")!
        case .post(let id):
            return URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)")!
        case .users:
            return URL(string: "https://jsonplaceholder.typicode.com/users")!
        case .user(let id):
            return URL(string: "https://jsonplaceholder.typicode.com/users/\(id)")!
        case .comments(let postId):
            return URL(string: "https://jsonplaceholder.typicode.com/posts/\(postId)/comments")!
        case .albums(let userId):
            return URL(string: "https://jsonplaceholder.typicode.com/users/\(userId)/albums")!
        case .picsumList(let page, let limit):
            return URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)")!
        }
    }
}
