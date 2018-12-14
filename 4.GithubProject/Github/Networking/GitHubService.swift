//
//  GitHubService.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Moya

enum GitHub {
    case trendingRepositories(language: String, page: Int)
    case languages
    case login(id: String, password: String)
    case searchRepositories(query: String, page: Int)
    case profile
    case myRepo(urlPath: String)
}

extension GitHub: TargetType {
    var baseURL: URL {
        switch self {
        case .myRepo(let urlPath):
            return URL(string: urlPath) ?? URL(string: "https://api.github.com")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
    
    var method: Moya.Method {
        switch self {
        case .login(id: _, password: _):
            return .post
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .trendingRepositories,
             .searchRepositories:
            return "/search/repositories"
        case .languages:
            return ""
        case .login:
            return "/authorizations"
        case .profile:
            return "/user"
        default:
            return ""
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
        case .languages:
            return .requestPlain
        case .login(_, _):
            let parameters = [
                "scopes": ["public_repo", "user"],
                "note": "(\(NSDate()))"
                ] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .searchRepositories(let query, let page):
            let parameters = ["q": query.encoding, "page":page] as [String : Any]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data { return "There is No smaple Data".data(using: String.Encoding.utf8) ?? Data() }
}

private extension String {
    var encoding: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
