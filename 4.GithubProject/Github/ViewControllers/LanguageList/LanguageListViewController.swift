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
import RxDataSources

// LanguageList Delegate
protocol LanguageListDelegate: class {
    func selectLanguage(_ language: String)
}

// LanguageList Delegate Proxy
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

// LanguageListViewController
final class LanguageListViewController: BaseViewController {
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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = .black
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        return activityIndicator
    }()
    
    private var closeBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItem.Style.done, target: nil, action: nil)
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    private func setupBindings() {
        self.viewModel.refresh()
        
        self.closeBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.viewModel.languageTap(indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.language
            .drive(onNext: { [weak self] language in
                self?.delegate?.selectLanguage(language)
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = item
                return cell
        })
        
        self.viewModel.outpust.items
            .asDriver()
            .map { [SectionModel(model: "Languages", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        self.viewModel.outpust.isLoading
            .asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }).disposed(by: self.disposeBag)
    }
}

extension LanguageListViewController {
    var rx_delegate: RxLanguageListDelegateProxy {
        return RxLanguageListDelegateProxy.proxy(for: self)
    }
}
