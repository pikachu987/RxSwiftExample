//
//  ViewController.swift
//  SearchExample
//
//  Created by Gwanho Kim on 21/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    private lazy var titleSearchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 40, y: 0, width: UIScreen.main.bounds.width - 80, height: self.navigationController?.navigationBar.frame.height ?? 44))
        searchBar.delegate = self
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.titleView = self.titleSearchBar
        
    }


}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        Provider.search(text) { (error) in
            guard error == nil else {
                print(error)
                return
            }
            
        }

        
    }
}
