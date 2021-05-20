//
//  MainViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/17.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MainViewController: BaseViewController {
    static func instance() -> MainViewController? {
        let viewController = MainViewController(nibName: nil, bundle: nil)
        return viewController
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.sectionHeaderHeight = 0.001
        tableView.sectionFooterHeight = 0.001
        return tableView
    }()
    
    private let viewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            self?.title = "Main"
        }).disposed(by: self.disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MainItemType>>(configureCell: { dataSource, tableView, IndexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: IndexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = item.title
            return cell
        })

        viewModel.items
            .asDriver()
            .map({ [SectionModel(model: "MainItemType", items: $0)] })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable
            .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(MainItemType.self))
            .bind { [weak self] indexPath, item in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                if item == .githubTrending {
                    guard let viewController = GithubTrendingViewController.instance() else { return }
                    self?.present(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
                } else if item == .simpleTable {
                    guard let viewController = ExampleSimpleTableViewController.instance() else { return }
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }

}

// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}
