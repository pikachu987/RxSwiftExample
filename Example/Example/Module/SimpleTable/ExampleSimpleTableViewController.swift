//
//  ExampleSimpleTableViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import UIKit
import RxSwift
import RxCocoa

class ExampleSimpleTableViewController: BaseViewController {
    static func instance() -> ExampleSimpleTableViewController? {
        let viewController = ExampleSimpleTableViewController(nibName: nil, bundle: nil)
        return viewController
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let viewModel = ExampleSimpleTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            self.viewModel.fetchData()
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    override func setupBindings() {
        super.setupBindings()
        
        rx.viewWillAppear.subscribe(onNext: { [weak self] _ in
            self?.title = "ExampleSimpleTableView"
        }).disposed(by: disposeBag)
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.fetchData()
            })
            .disposed(by: disposeBag)

        viewModel.refreshIndicator
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.items.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "UITableViewCell", cellType: UITableViewCell.self)) { index, item, cell in
                cell.textLabel?.text = item.name.appending("(\(item.gender?.uppercased() ?? "?"))")
            }.disposed(by: disposeBag)

        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(ExampleSimpleTableMemberModel.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                let alertController = UIAlertController(title: nil, message: item.name, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}