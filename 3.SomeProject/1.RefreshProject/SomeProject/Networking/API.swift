//
//  API.swift
//  SomeProject
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Moya
import RxSwift
import RxCocoa

var GithubProvider = MoyaProvider<GitHub>(
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
    static func trendingRepositories(_ language: String) -> Single<[Repository]>
}

final class API: GitHubAPI {
    static func trendingRepositories(_ language: String) -> Single<[Repository]> {
        return GithubProvider.rx.request(GitHub.trendingRepositories(language: language))
            .map(Repositories.self)
            .observeOn(MainScheduler.instance)
            .flatMap ({ repositories -> Single<[Repository]> in
                guard let items = repositories.items else { return Single.just([]) }
                return Single.just(items)
            })
    }
}
