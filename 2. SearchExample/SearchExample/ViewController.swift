//
//  ViewController.swift
//  SearchExample
//
//  Created by Gwanho Kim on 21/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import Alamofire
import Moya
import RxSwift
import RxCocoa

enum MyService {
    case search(String)
}

extension MyService: TargetType {
    var baseURL: URL { return URL(string: "https://api.github.com")! }
    
    var path: String {
        switch self {
        case .search(_):
            return "/search/repositories"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search(_):
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .search(let text): // Send no parameters
            return .requestParameters(parameters: ["q": text, "sort": "stars", "order": "desc"], encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data {
        switch self {
        case .search(let text):
            return "{\"id\": \(text), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".data(using: .utf8)!
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

class ViewController: UIViewController {
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

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        let provider = MoyaProvider<MyService>()
        provider.request(.search(text)) { result in
            switch result {
            case let .success(moyaResponse):
                let data = try? moyaResponse.mapJSON()
                let statusCode = moyaResponse.statusCode
                print(data)
                print(statusCode)
                
            case let .failure(error):
                // this means there was a network failure - either the request
                // wasn't sent (connectivity), or no response was received (server
                // timed out).  If the server responds with a 4xx or 5xx error, that
                // will be sent as a ".success"-ful response.
                print(error)
                break
            }
        }

        
    }
}
