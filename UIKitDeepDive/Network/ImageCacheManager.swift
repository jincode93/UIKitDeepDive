//
//  ImageCacheManager.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/23/26.
//

import UIKit

final class ImageCacheManager {
    
    static let shared = ImageCacheManager()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSString, UIImage>()
    private var runningTasks: [String: Task<UIImage?, Never>] = [:]
    
    // MARK: - Init
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Public API
    
    func loadImage(from url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        if let existingTask = runningTasks[url.absoluteString] {
            return await existingTask.value
        }
        
        let task = Task<UIImage?, Never> {
            do {
                let data = try await NetworkManager.shared.fetchImage(from: url)
                
                guard let image = UIImage(data: data) else { return nil }
                let decodedImage = await image.byPreparingForDisplay() ?? image
                
                self.cache.setObject(decodedImage, forKey: key, cost: data.count)
                
                return decodedImage
            } catch {
                return nil
            }
        }
        
        runningTasks[url.absoluteString] = task
        let result = await task.value
        runningTasks.removeValue(forKey: url.absoluteString)
        
        return result
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
