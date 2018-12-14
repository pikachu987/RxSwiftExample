//
//  MyRepositoriesViewController.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class MyRepositoriesViewController: BaseViewController {
    private var viewModel = MyRepositoriesViewModel()
    
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
