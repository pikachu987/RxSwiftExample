//
//  ProfileViewController.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import Kingfisher

final class ProfileViewController: BaseViewController {
    private let viewModel = ProfileViewModel()
    
    private var logoutBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private lazy var userView: UserView = {
        let view = UserView()
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeArea.top)
        })
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.title = "Profile"
        self.navigationItem.rightBarButtonItem = self.logoutBarButtonItem
        
    }
    
    private func setupBindings() {
        self.viewModel.inputs.loadProfileTrigger.onNext(())
        
        self.logoutBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                let alertController = UIAlertController(title: "Logout", message: "Do you logout?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    UserDefaults.standard.removeObject(forKey: "AuthorizationsToken")
                    UserDefaults.standard.synchronize()
                    let viewController = TrendingViewController()
                    let navigationController = UINavigationController(rootViewController: viewController)
                    AppDelegate.shared?.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    AppDelegate.shared?.window?.rootViewController = navigationController
                    AppDelegate.shared?.window?.makeKeyAndVisible()
                }))
                self?.present(alertController, animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.isLoading
            .asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                self?.view.loading(isLoading: isLoading, style: .whiteLarge, color: .black)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.profile
            .subscribe(onNext: { [weak self] user in
                self?.userView.user = user
            }).disposed(by: self.disposeBag)
    }
}
