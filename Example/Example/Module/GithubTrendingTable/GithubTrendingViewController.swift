//
//  GithubTrendingViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class GithubTrendingViewController: BaseViewController {
    static func instance() -> GithubTrendingViewController? {
        let viewController = GithubTrendingViewController(nibName: nil, bundle: nil)
        return viewController
    }
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.enablesReturnKeyAutomatically = false
        return searchBar
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(GithubTrendingCell.self, forCellReuseIdentifier: GithubTrendingCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        return tableView
    }()

    private let refreshControl: UIRefreshControl = {
        return UIRefreshControl()
    }()
    
    private let viewModel = GithubTrendingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.loadPageTrigger.onNext(())
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
        
        rx
            .viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigationItem.titleView = self.searchBar
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "👈", style: .done, target: self, action: nil)
                self.navigationItem.leftBarButtonItem?.rx
                    .tap
                    .subscribe(onNext: { [weak self] _ in
                        self?.dismiss(animated: true, completion: nil)
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        searchBar.rx
            .text
            .bind(to: viewModel.input.highlightTextTrigger)
            .disposed(by: disposeBag)
        
        searchBar.rx
            .searchButtonClicked
            .compactMap({ [weak self] _ -> String? in
                return self?.searchBar.text
            })
            .bind(to: viewModel.input.searchTextTrigger)
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        
        tableView.rx
            .contentReverseOffset
            .filter({ [weak self] point in
                guard let self = self else { return false }
                return point.y < (40 - self.view.safe.bottom)
            })
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.input.loadMorePageTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.input.refreshPageTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemSelected
            .subscribe(onNext: { index in
                
            })
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(GithubTrendingRepository.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func bindingViewModel() {
        super.bindingViewModel()
        
        viewModel.output
            .errorMessage
            .compactMap({ $0 })
            .filter({ !$0.isEmpty })
            .subscribe(onNext: { [weak self] in
                let alertController = UIAlertController(title: nil, message: $0, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
            }).disposed(by: disposeBag)

        viewModel.output
            .refreshIndicator
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.output
            .indicator
            .bind(to: view.rx.isIndicator)
            .disposed(by: disposeBag)
        
        viewModel.output
            .bottomIndicator
            .bind(to: tableView.rx.isBottomIndicator)
            .disposed(by: disposeBag)
        
        viewModel.output
            .items
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: GithubTrendingCell.identifier, cellType: GithubTrendingCell.self))({ [weak self] index, item, cell in
                cell.rx
                    .githubTrendingOwnerTap
                    .compactMap({ item.owner?.htmlURL })
                    .compactMap({ URL(string: $0) })
                    .subscribe(onNext: { url in
                        let viewController = SFSafariViewController(url: url)
                        self?.present(viewController, animated: true, completion: nil)
                    }).disposed(by: cell.disposeBag)
                cell.repository = item
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UITableViewDelegate
extension GithubTrendingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude))
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: CGFloat.leastNonzeroMagnitude, height: CGFloat.leastNonzeroMagnitude))
    }
}
