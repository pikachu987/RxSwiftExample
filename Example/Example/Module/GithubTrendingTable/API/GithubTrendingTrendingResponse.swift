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
        if let data = data, var repositories = try? JSONDecoder().decode(GithubTrendingRepositories.self, from: data) {
            let totalCount = repositories.totalCount ?? 0
            repositories.totalCount = totalCount > 60 ? 60 : totalCount
            self.repositories = repositories
        } else {
            repositories = GithubTrendingRepositories(totalCount: 0, incompleteResults: false, items: nil)
        }
    }
}
