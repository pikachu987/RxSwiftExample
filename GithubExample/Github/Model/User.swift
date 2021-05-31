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
    let starredUrlPath: String?
    let followersUrlPath: String?
    let followingUrlPath: String?
    let publicRepos: Int?
    let totalPrivateRepos: Int?
    let followers: Int?
    let following: Int?
    
    var starredUrl: String? {
        return self.starredUrlPath?.components(separatedBy: "{").first
    }
    var followersUrl: String? {
        return self.followersUrlPath
    }
    var followingUrl: String? {
        return self.followingUrlPath?.components(separatedBy: "{").first
    }
    
    var repoCount: Int {
        return (self.publicRepos ?? 0) + (self.totalPrivateRepos ?? 0)
    }
    
    var followersCount: Int {
        return self.followers ?? 0
    }
    
    var followingCount: Int {
        return self.following ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case id = "id"
        case login = "login"
        case name = "name"
        case email = "email"
        case reposUrl = "repos_url"
        case starredUrlPath = "starred_url"
        case followersUrlPath = "followers_url"
        case followingUrlPath = "following_url"
        case publicRepos = "public_repos"
        case totalPrivateRepos = "total_private_repos"
        case followers
        case following
    }
}
