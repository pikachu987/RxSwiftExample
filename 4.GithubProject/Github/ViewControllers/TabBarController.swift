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
        viewControllers.append(TrendingViewController())
        
        self.setViewControllers(viewControllers, animated: true)
    }
}
