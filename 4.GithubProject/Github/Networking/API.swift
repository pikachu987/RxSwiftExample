//
//  API.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

var GithubProvider = MoyaProvider<GitHub> (
    endpointClosure: endpointClosure,
    plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]
)

func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data
    }
}

let endpointClosure = { (target: GitHub) -> Endpoint in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)

    switch target {
    case .login(let id, let password):
        let credentialData = "\(id):\(password)".data(using: String.Encoding.utf8)
        let base64Credentials = credentialData?.base64EncodedString() ?? ""
        return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "Basic \(base64Credentials)"])
    default:
        if let token = UserDefaults.token {
            return defaultEndpoint.adding(newHTTPHeaderFields: ["Authorization": "token \(token)"])
        }
        return defaultEndpoint
    }

}

protocol GitHubAPI {
    static func trendingRepositories(_ language: String, page: Int) -> Single<[Repository]>
    static func languages() -> Single<[String]>
}

final class API: GitHubAPI {
    static func trendingRepositories(_ language: String, page: Int) -> Single<[Repository]> {
        return GithubProvider.rx.request(GitHub.trendingRepositories(language: language, page: page))
            .observeOn(MainScheduler.instance)
            .flatMap ({ response -> Single<[Repository]> in
                guard let repositories = try? JSONDecoder().decode(Repositories.self, from: response.data) else {
                    let error = try? JSONDecoder().decode(GitHubError.self, from: response.data)
                    return Single.error(NSError(domain: error?.message ?? "An unknown error has occurred.", code: 400, userInfo: nil))
                }
                return Single.just(repositories.items)
            })
    }
    
    static func languages() -> Single<[String]> {
        return Single.just(["Swift", "Objective-C", "Java", "C", "C++", "C#", "Go", "JavaScript", "Python", "CSS", "PHP", "Ruby", "Haskell", "Scala", "Go", "Perl", "R", "VimL", "Shell" ])
            .delay(TimeInterval.random(in: 0.5...1), scheduler: MainScheduler.instance)
    }
    
    static func login(_ id: String, password: String) -> Single<Bool> {
        return GithubProvider.rx.request(GitHub.login(id: id, password: password))
            .map(Authorizations.self)
            .observeOn(MainScheduler.instance)
            .flatMap({ user -> Single<Bool> in
                if let token = user.token {
                    UserDefaults.standard.set(token, forKey: "AuthorizationsToken")
                    return Single.just(true)
                } else {
                    return Single.just(false)
                }
            })
    }
}
