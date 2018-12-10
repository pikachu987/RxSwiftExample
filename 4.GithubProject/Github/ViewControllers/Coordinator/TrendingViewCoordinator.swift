//
//  TrendingViewCoordinator.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift

class TrendingViewCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel = TrendingViewModel()
        let viewController = TrendingViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewModel.login
            .drive(onNext: { _ in
                let loginCoordinator = LoginViewCoordinator(window: self.window)
                self.coordinate(to: loginCoordinator)
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
        
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
        
        return Observable.never()
    }
}
