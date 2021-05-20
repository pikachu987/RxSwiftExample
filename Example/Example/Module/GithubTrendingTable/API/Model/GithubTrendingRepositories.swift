//
//  GithubTrendingRepositories.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/20.
//

import Foundation

struct GithubTrendingRepositories: Codable {
    let totalCount: Int?
    let incompleteResults: Bool?
    let items: [GithubTrendingRepository]?
    
    enum CodingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case totalCount = "total_count"
        case items
    }
}
