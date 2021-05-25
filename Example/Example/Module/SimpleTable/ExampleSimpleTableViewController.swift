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
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }()
    
    private let viewModel = ExampleSimpleTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            self.viewModel.input.loadPageTrigger.onNext(())
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            view.topAnchor.constraint(equalTo: tableView.topAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    override func bindingView() {
        super.bindingView()
        
        rx.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.title = "ExampleSimpleTableView"
            }).disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.input.loadPageTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
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
    
    override func bindingViewModel() {
        super.bindingViewModel()
        
        viewModel.output
            .refreshIndicator
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.output
            .items.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "UITableViewCell", cellType: UITableViewCell.self)) { index, item, cell in
                cell.textLabel?.text = item.name.appending("(\(item.gender?.uppercased() ?? "?"))")
            }.disposed(by: disposeBag)
    }
}
