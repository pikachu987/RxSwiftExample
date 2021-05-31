//
//  TrendingViewController.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

/*
 가장 먼저 나오는 페이지 또는 탭컨트롤러의 첫번째 탭입니다.
 The first tab of the page or tab controller that comes first.
 */

final class TrendingViewController: BaseViewController {
    private var viewModel = TrendingViewModel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }()
    
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    private var languageBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Language", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private var loginBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Login", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private var searchBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.title = "Trending"
        self.refreshControl.backgroundColor = .clear
        self.tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.identifier)
        self.tableView.addSubview(self.refreshControl)
        self.navigationItem.leftBarButtonItem = self.languageBarButtonItem
        if UserDefaults.isAuthorizationsToken {
            self.navigationItem.rightBarButtonItem = self.searchBarButtonItem
        } else {
            self.navigationItem.rightBarButtonItem = self.loginBarButtonItem
        }
    }
    
    private func setupBindings() {
        self.viewModel.inputs.language("Swift")
        self.viewModel.inputs.refresh()
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.inputs.loadPageTrigger)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.loadNextBottom
            .bind(to: self.viewModel.inputs.loadNextPageTrigger)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.viewModel.inputs.repositoryTap(indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.isLoading
            .asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if !isLoading {
                    self.refreshControl.endRefreshing()
                }
                if !self.refreshControl.isRefreshing {
                    self.view.loading(isLoading: isLoading, style: .whiteLarge, color: .black)
                }
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.error
            .subscribe { [weak self] error in
                let message: String = error.element?.localizedDescription ?? "An unknown error has occurred."
                let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            }.disposed(by: self.disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TrendingCell.identifier, for: indexPath) as? TrendingCell else {
                    fatalError()
                }
                cell.item = item
                return cell
        }, titleForHeaderInSection: { [weak self] (dataSource, section) -> String? in
            return self?.viewModel.outpust.languageRelay.value
        })
        
        self.viewModel.outpust.items
            .asDriver()
            .map { [SectionModel(model: "Repositories", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        self.viewModel.outpust.repositoryViewModel
            .drive(onNext: { [weak self] repositoryViewModel in
                let viewController = RepositoryViewController(viewModel: repositoryViewModel)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: self.disposeBag)
        
        self.languageBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let viewController = LanguageListViewController()
                viewController.rx_delegate.languageSubject
                    .subscribe(onNext: { [weak self] (language) in
                        self?.viewModel.inputs.language(language)
                        self?.viewModel.inputs.refresh()
                    }).disposed(by: self.disposeBag)
                self.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.loginBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                let viewController = LoginViewController()
                let navigationController = UINavigationController(rootViewController: viewController)
                self?.present(navigationController, animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.searchBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                let viewController = SearchRepositoryViewController()
                let navigationController = UINavigationController(rootViewController: viewController)
                self?.present(navigationController, animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
    }
}
