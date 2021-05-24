//
//  GithubTrendingRepositoryOwner.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/25.
//

import Foundation

struct GithubTrendingRepositoryOwner: Codable {
    enum CodingKeys: String, CodingKey {
        case id, login, url
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }

    var id: Double
    var login: String
    var avatarURL: String
    var url: String
    var htmlURL: String
}
