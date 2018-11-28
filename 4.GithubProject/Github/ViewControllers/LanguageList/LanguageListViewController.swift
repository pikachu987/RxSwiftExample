//
//  LanguageListViewController.swift
//  Github
//
//  Created by Gwanho Kim on 27/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol LanguageListDelegate: class {
    func selectLanguage(_ language: String)
}

class RxLanguageListDelegateProxy: DelegateProxy<LanguageListViewController, LanguageListDelegate>, DelegateProxyType, LanguageListDelegate  {
    let languageSubject = PublishSubject<String>()
    
    static func currentDelegate(for object: LanguageListViewController) -> LanguageListDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: LanguageListDelegate?, to object: LanguageListViewController) {
        object.delegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { RxLanguageListDelegateProxy(parentObject: $0, delegateProxy: RxLanguageListDelegateProxy.self) }
    }
    
    func selectLanguage(_ language: String) {
        self.languageSubject.onNext(language)
    }
}

class LanguageListViewController: BaseViewController {
    private let viewModel = LanguageListViewModel()
    
    weak var delegate: LanguageListDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }()
    
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
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    private func setupBindings() {
        
        self.closeBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.sendBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.delegate?.selectLanguage("Java")
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        Observable.just(API.languages())
            .subscribe(onNext: { request in
                request.subscribe(onSuccess: { (array) in
                    print(array)
                }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
    }
}

extension LanguageListViewController {
    var rx_delegate: RxLanguageListDelegateProxy {
        return RxLanguageListDelegateProxy.proxy(for: self)
    }
}
