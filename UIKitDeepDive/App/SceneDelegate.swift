//
//  SceneDelegate.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = createTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let feedVC = createNavController(
            rootVC: FeedViewController(),
            title: "Feed",
            systemImage: "list.bullet"
        )
        let galleryVC = createNavController(
            rootVC: GalleryViewController(),
            title: "Gallery",
            systemImage: "square.grid.2x2"
        )
        let hybridVC = createNavController(
            rootVC: HybridViewController(),
            title: "Hybrid",
            systemImage: "rectangle.split.2x2"
        )
        let performanceVC = createNavController(
            rootVC: PerformanceViewController(),
            title: "Performance",
            systemImage: "gauge.with.dots.needle.67percent"
        )
        let edgeCasesVC = createNavController(
            rootVC: EdgeCasesViewController(),
            title: "Edge Cases",
            systemImage: "exclamationmark.triangle"
        )
        
        tabBarController.viewControllers = [
            feedVC, galleryVC, hybridVC, performanceVC, edgeCasesVC
        ]

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        return tabBarController
    }
    
    private func createNavController(
        rootVC: UIViewController,
        title: String,
        systemImage: String
    ) -> UINavigationController {
        rootVC.title = title
        let navController = UINavigationController(rootViewController: rootVC)
        navController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: systemImage),
            selectedImage: nil
        )
        
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navController.navigationBar.standardAppearance = navAppearance
        navController.navigationBar.scrollEdgeAppearance = navAppearance
        
        return navController
    }
}

