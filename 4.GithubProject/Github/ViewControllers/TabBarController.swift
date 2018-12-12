//
//  TabBarController.swift
//  Github
//
//  Created by Gwanho Kim on 12/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewControllers = [UIViewController]()
        
        let trendingNavigationController = UINavigationController(rootViewController: TrendingViewController())
        trendingNavigationController.tabBarItem.title = "Trending"
        viewControllers.append(trendingNavigationController)
        
//        let searchNavigationController = UINavigationController(rootViewController: TrendingViewController())
//        searchNavigationController.tabBarItem.title = "Search"
//        viewControllers.append(searchNavigationController)
        
        self.setViewControllers(viewControllers, animated: true)
    }
}
