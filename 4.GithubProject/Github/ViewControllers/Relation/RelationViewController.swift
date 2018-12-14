//
//  RelationViewController.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

final class RelationViewController: BaseViewController {
    private let viewModel = RelationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        
    }
    
    private func setupBindings() {
        ProfileHelper.shared.profile
            .subscribe(onNext: { [weak self] user in
                print(user?.reposUrl)
            }).disposed(by: self.disposeBag)
        
        ProfileHelper.shared.ifExistsProfileLoad()
    }
}
