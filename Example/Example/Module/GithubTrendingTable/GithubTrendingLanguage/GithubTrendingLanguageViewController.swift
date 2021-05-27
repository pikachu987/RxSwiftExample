//
//  GithubTrendingLanguageViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/27.
//

import UIKit
import RxSwift
import RxCocoa

class GithubTrendingLanguageViewController: BaseViewController {
    static func instance() -> GithubTrendingLanguageViewController? {
        let viewController = GithubTrendingLanguageViewController(nibName: nil, bundle: nil)
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
    
    private let leftBarButtonItem = UIBarButtonItem(title: "👈", style: .done, target: self, action: nil)
    private let viewModel = GithubTrendingLanguageViewModel()
    
    var language = PublishRelay<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.input.loadPageTrigger.onNext(())
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
                guard let self = self else { return }
                self.title = "언어 선택"
                self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
            }).disposed(by: disposeBag)
        
        leftBarButtonItem.rx
            .tap
            .subscribe(onNext: { [weak self] isHidden in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.input.loadPageTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(GithubTrendingLanguageItem.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.language.accept(item.rawValue)
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
                cell.textLabel?.text = item.rawValue
            }.disposed(by: disposeBag)
    }
}
