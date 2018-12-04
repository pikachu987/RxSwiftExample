//
//  LoginViewController.swift
//  Github
//
//  Created by Gwanho Kim on 04/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

// LoginViewController
final class LoginViewController: BaseViewController {
    private let viewModel = LoginViewModel()
    
    private var cancelBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
    }
    
    private func setupBindings() {
        
        self.cancelBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
    }
}
