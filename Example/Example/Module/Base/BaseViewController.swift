//
//  BaseViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    deinit {
        print("deinit: \(self)")
    }

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
    }

    func setupUI() {
        
    }

    func setupBindings() {
        
    }
}