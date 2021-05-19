//
//  AppDelegate.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/17.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let viewController = MainViewController.instance() {
            window?.rootViewController = UINavigationController(rootViewController: viewController)
        }
        window?.makeKey()
        
        return true
    }
}

