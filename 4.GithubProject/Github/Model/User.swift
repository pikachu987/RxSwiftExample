//
//  User.swift
//  Github
//
//  Created by Gwanho Kim on 14/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation

struct User : Codable {
    let avatarUrl: String?
    let id: Int?
    let login: String?
    let name: String?
    let email: String?
    let reposUrl: String?
    let starredUrl: String?
    let followersUrl: String?
    let followingUrl: String?
    let publicRepos: Int?
    let totalPrivateRepos: Int?
    
    var repoCount: Int {
        return (self.publicRepos ?? 0) + (self.totalPrivateRepos ?? 0)
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case id = "id"
        case login = "login"
        case name = "name"
        case email = "email"
        case reposUrl = "repos_url"
        case starredUrl = "starred_url"
        case followersUrl = "followers_url"
        case followingUrl = "following_url"
        case publicRepos = "public_repos"
        case totalPrivateRepos = "total_private_repos"
    }
}
