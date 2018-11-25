//
//  AppCoordinator.swift
//  SomeProject
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let trendingCoordinator = TrendingViewCoordinator(window: self.window)
        return self.coordinate(to: trendingCoordinator)
    }
}
