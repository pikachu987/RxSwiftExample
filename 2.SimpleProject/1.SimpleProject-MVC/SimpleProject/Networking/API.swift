//
//  API.swift
//  SimpleProject
//
//  Created by Gwanho Kim on 24/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Moya

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
    static func trendingRepositories(_ language: String, callback: @escaping (Error?, [Repository]?) -> Void)
}

final class API: GitHubAPI {
    static func trendingRepositories(_ language: String, callback: @escaping (Error?, [Repository]?) -> Void) {
        GithubProvider.request(GitHub.trendingRepositories(language: language)) { result in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONDecoder().decode(Repositories.self, from: response.data)
                    callback(nil, data.items)
                } catch let error {
                    callback(error, nil)
                }
                break
            case .failure(let error):
                callback(error, nil)
                break
            }
        }
    }
}
