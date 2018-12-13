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
        
        let myRepositoriesNavigationController = UINavigationController(rootViewController: MyRepositoriesViewController())
        myRepositoriesNavigationController.tabBarItem.title = "MyRepo"
        viewControllers.append(myRepositoriesNavigationController)
        
        let relationNavigationController = UINavigationController(rootViewController: RelationViewController())
        relationNavigationController.tabBarItem.title = "Relation"
        viewControllers.append(relationNavigationController)
        
        let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
        profileNavigationController.tabBarItem.title = "Profile"
        viewControllers.append(profileNavigationController)
        
        self.setViewControllers(viewControllers, animated: true)
    }
}
