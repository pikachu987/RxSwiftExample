//
//  GithubTrendingRepository.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/20.
//

import Foundation

struct GithubTrendingRepository: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, url, description, size, owner
        case htmlURL = "html_url"
        case updatedAt = "updated_at"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
    }

    let id: Double
    let name: String
    let htmlURL: String
    let url: String
    let description: String?
    let updatedAt: String? // 2021-05-18T22:09:24Z
    let size: Int
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let owner: GithubTrendingRepositoryOwner?
}

extension GithubTrendingRepository {
    var updatedDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: self.updatedAt ?? "")
        return date
    }
}
