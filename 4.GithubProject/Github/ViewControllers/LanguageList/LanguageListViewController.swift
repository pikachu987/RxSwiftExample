//
//  LanguageListViewController.swift
//  Github
//
//  Created by Gwanho Kim on 27/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

class LanguageListViewController: BaseViewController {
    private let viewModel = LanguageListViewModel()
    
    private var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.done, target: nil, action: nil)
        return barButtonItem
    }()
    
    private var sendBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "임시", style: UIBarButtonItem.Style.done, target: nil, action: nil)
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
        self.navigationItem.rightBarButtonItem = self.sendBarButtonItem
    }
    
    private func setupBindings() {
        
        self.closeBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.sendBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
    }
}
