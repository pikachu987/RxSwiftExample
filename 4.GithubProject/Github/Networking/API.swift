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

protocol GitHubAPI {
    static func trendingRepositories(_ language: String, page: Int) -> Single<[Repository]>
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
}
