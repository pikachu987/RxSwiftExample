//
//  GithubTrendingTrendingResponse.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/20.
//

import Foundation

class GithubTrendingTrendingResponse: GithubTrendingResponse {
    var repositories: GithubTrendingRepositories?

    required init(statusCode: Int, data: Data?) {
        super.init(statusCode: statusCode, data: data)
        if let data = data, let repositories = try? JSONDecoder().decode(GithubTrendingRepositories.self, from: data) {
            self.repositories = repositories
        } else {
            repositories = GithubTrendingRepositories(totalCount: 0, incompleteResults: false, items: nil)
        }
    }
}
