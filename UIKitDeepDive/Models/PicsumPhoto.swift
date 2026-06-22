//
//  PicsumPhoto.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import Foundation

struct PicsumPhoto: Codable, Hashable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadUrl: String
    
    func imageURL(width: Int, height: Int) -> URL? {
        URL(string: "https://picsum.photos/id/\(id)/\(width)/\(height)")
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
