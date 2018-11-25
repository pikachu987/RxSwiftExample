//
//  GitHubService.swift
//  SomeProject
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Moya

enum GitHub {
    case trendingRepositories(language: String, page: Int)
}

extension GitHub: TargetType {
    var baseURL: URL { return URL(string: "https://api.github.com")! }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    var method: Moya.Method {
        switch self {
        case .trendingRepositories:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .trendingRepositories:
            return "/search/repositories"
        }
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
    
    var task: Task {
        switch self {
        case .trendingRepositories(let language, let page):
            guard let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return .requestPlain }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let parameters = [
                "q": "language:\(language) " + "created:>" + formatter.string(from: lastWeek),
                "sort": "stars",
                "order": "desc",
                "page": page
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var sampleData: Data { return "There is No smaple Data".data(using: String.Encoding.utf8) ?? Data() }
}
