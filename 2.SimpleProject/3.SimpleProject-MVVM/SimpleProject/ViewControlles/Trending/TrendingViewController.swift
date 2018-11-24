//
//  TrendingViewController.swift
//  SimpleProject
//
//  Created by Gwanho Kim on 24/11/2018.
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.identifier)
    }
    
    private func setupBindings() {
        self.viewModel.language = "Swift"
        self.viewModel.refresh()
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TrendingCell.identifier, for: indexPath) as? TrendingCell else {
                    fatalError()
                }
                cell.item = item
                return cell
        })
        
        self.viewModel.items
            .asDriver()
            .map { [SectionModel(model: "Repositories", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
    }
}
