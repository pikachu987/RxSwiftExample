//
//  TrendingViewControllerTests.swift
//  GithubTests
//
//  Created by Gwanho Kim on 17/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import XCTest

@testable import Github

class TrendingViewControllerTests: XCTestCase {
    
    var viewController: TrendingViewController!
    
    override func setUp() {
        super.setUp()
        
        let viewController = TrendingViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
}
