//
//  LoginViewCoordinator.swift
//  Github
//
//  Created by Gwanho Kim on 11/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift

class LoginViewCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        
        viewModel.outpust.login
            .drive(onNext: { [weak viewController] isLogin in
                if isLogin == false {
                    let alertController = UIAlertController(title: "Error", message: "Login Error", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
                    viewController?.present(alertController, animated: true, completion: nil)
                } else {
                    //                    let rootTabBarCoordinator = RootTabBarCoordinator(window: self.window)
                    //                    self.coordinate(to: rootTabBarCoordinator)
                    //                        .subscribe()
                    //                        .disposed(by: self.disposeBag)
                }
            }).disposed(by: self.disposeBag)
        
        self.window.rootViewController?.present(navigationController, animated: true, completion: nil)
        return Observable.never()
    }
}
