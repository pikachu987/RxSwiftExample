//
//  ProfileViewController.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

final class ProfileViewController: BaseViewController {
    private let viewModel = ProfileViewModel()
    
    private var logInOutBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
//        let alertController = UIAlertController(title: "Logout", message: "Do you logout?", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
//            UserDefaults.standard.removeObject(forKey: "AuthorizationsToken")
//            UserDefaults.standard.synchronize()
//            let viewController = TrendingViewController()
//            let navigationController = UINavigationController(rootViewController: viewController)
//            AppDelegate.shared?.window?.rootViewController?.dismiss(animated: false, completion: nil)
//            AppDelegate.shared?.window?.rootViewController = navigationController
//            AppDelegate.shared?.window?.makeKeyAndVisible()
//        }))
//        self?.present(alertController, animated: true, completion: nil)
    }
    
    private func setupUI() {
        
    }
    
    private func setupBindings() {
        
    }
}
