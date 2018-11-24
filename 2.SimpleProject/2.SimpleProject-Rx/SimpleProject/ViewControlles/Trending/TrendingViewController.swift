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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }()
    
    private var language = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.language = "Swift"
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.identifier)
    }
    
    private func setupBindings() {
        let behaviorRelay = BehaviorRelay<[Repository]>(value: [])
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Repository>>(
            configureCell: { dataSource, tableView, indexPath, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TrendingCell.identifier, for: indexPath) as? TrendingCell else {
                    fatalError()
                }
                cell.item = item
                return cell
        })
        
        behaviorRelay
            .asDriver()
            .map { [SectionModel(model: "Repositories", items: $0)] }
            .drive(self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: self.disposeBag)
        
        let loadPageTrigger = PublishSubject<Void>()
        loadPageTrigger.asObserver()
            .flatMap { _ -> Observable<[Repository]> in
                behaviorRelay.accept([])
                return API.trendingRepositories(self.language)
                    .asObservable()
            }.bind(to: behaviorRelay)
            .disposed(by: self.disposeBag)
        
        loadPageTrigger.onNext(())
    }
}
