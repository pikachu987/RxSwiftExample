//
//  UserViewController.swift
//  Github
//
//  Created by Gwanho Kim on 16/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxDataSources

final class UserViewController: BaseViewController {
    let viewModel: UserViewModel
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.grouped)
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
    
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.refreshControl.backgroundColor = .clear
        self.tableView.sectionFooterHeight = 0.001
        self.tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.identifier)
        self.tableView.addSubview(self.refreshControl)
    }
    
    private func setupBindings() {
        self.viewModel.inputs.loadPageTrigger.onNext(())
        
        self.refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.inputs.loadPageTrigger)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.loadNextBottom
            .bind(to: self.viewModel.inputs.loadNextPageTrigger)
            .disposed(by: self.disposeBag)
        
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
        })
        
        self.viewModel.outpust.items
            .asDriver()
            .map { [SectionModel(model: "Repositories", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.viewModel.inputs.repositoryTap(indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.repositoryViewModel
            .drive(onNext: { [weak self] repositoryViewModel in
                let viewController = RepositoryViewController(viewModel: repositoryViewModel)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: self.disposeBag)
    }
}

// MARK: UITableViewDelegate
// https://github.com/RxSwiftCommunity/RxDataSources/issues/226
extension UserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UserView()
        view.user = self.viewModel.user
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
