//
//  TrendingViewController.swift
//  SimpleProject
//
//  Created by Gwanho Kim on 24/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import SnapKit

final class TrendingViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: UITableView.Style.plain)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return tableView
    }()
    
    private var language = ""
    private var items: [Repository]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.language = "Swift"
        self.setupUI()
        self.fetchData()
    }
    
    private func setupUI() {
        self.tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.identifier)
        self.tableView.dataSource = self
    }
    
    private func fetchData() {
        API.trendingRepositories(self.language) { (error, items) in
            guard error == nil else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.items = items
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDataSource
extension TrendingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrendingCell.identifier, for: indexPath) as? TrendingCell else {
            fatalError()
        }
        cell.item = self.items?[indexPath.row]
        return cell
    }
}
