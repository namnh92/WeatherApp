//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Max Nguyen on 26/12/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let nav = UINavigationController()
        let homeVC = DependencyResolver.shared.makeHomeViewController(navigation: nav)
        nav.viewControllers = [homeVC]
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        self.window = window
    }
}

