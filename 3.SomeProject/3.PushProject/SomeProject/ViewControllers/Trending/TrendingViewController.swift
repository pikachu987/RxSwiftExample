//
//  TrendingViewController.swift
//  SomeProject
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

final class TrendingViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel = TrendingViewModel()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.refreshControl.backgroundColor = .clear
        self.tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.identifier)
        self.tableView.addSubview(self.refreshControl)
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
            .map { (at: $0, animated: true) }
            .subscribe(onNext: tableView.deselectRow)
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.viewModel.inputs.repositoryTap(indexPath)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.isLoading
            .asObservable()
            .filter { !$0 }
            .subscribe({ [weak self] _ in
                self?.refreshControl.endRefreshing()
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
        
        self.viewModel.outpust.repositoryViewModel
            .drive(onNext: { [weak self] repositoryViewModel in
                let viewController = RepositoryViewController(viewModel: repositoryViewModel)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }).disposed(by: self.disposeBag)
    }
}
