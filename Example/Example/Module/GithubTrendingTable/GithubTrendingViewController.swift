//
//  GithubTrendingViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import SafariServices

class GithubTrendingViewController: BaseViewController {
    static func instance() -> GithubTrendingViewController? {
        let viewController = GithubTrendingViewController(nibName: nil, bundle: nil)
        return viewController
    }
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Owner 검색"
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
    
    private let leftBarButtonItem = UIBarButtonItem(title: "👈", style: .done, target: self, action: nil)
    
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
                self.navigationItem.leftBarButtonItem = self.leftBarButtonItem
            }).disposed(by: disposeBag)
        
        searchBar.rx
            .text
            .bind(to: viewModel.input.filterTextTrigger)
            .disposed(by: disposeBag)
        
        leftBarButtonItem.rx.tap.asDriver().withLatestFrom(RxKeyboard.instance.isHidden)
            .drive(onNext: { [weak self] isHidden in
                if isHidden {
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.searchBar.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance
            .isHidden
            .drive(onNext: { [weak self] isHidden in
                if isHidden {
                    self?.leftBarButtonItem.title = "👈"
                } else {
                    self?.leftBarButtonItem.title = "👇"
                }
            })
            .disposed(by: disposeBag)
        
        searchBar.rx
            .searchButtonClicked
            .compactMap({ [weak self] _ -> String? in
                return self?.searchBar.text
            })
            .do(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
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
            .compactMap({ _ in () })
            .bind(to: viewModel.input.loadMorePageTrigger)
            .disposed(by: disposeBag)
        
        refreshControl.rx
            .controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshPageTrigger)
            .disposed(by: disposeBag)

        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(GithubTrendingRepository.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
        
        RxKeyboard.instance
            .visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                if keyboardVisibleHeight == 0 {
                    self?.tableView.contentInset.bottom = 0
                } else {
                    self?.tableView.contentInset.bottom = keyboardVisibleHeight - (self?.view.safe.bottom ?? 0)
                }
            })
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
            .repositories
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
