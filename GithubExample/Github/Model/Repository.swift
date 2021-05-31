//
//  Repository.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation

struct Repository: Codable {
    let id: Int
    let name: String
    let htmlUrl: String?
    let star: Int?
    let fork: Int?
    let language: String?
    
    var starCount: Int {
        return self.star ?? 0
    }
    var forkCount: Int {
        return self.fork ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case htmlUrl = "html_url"
        case star = "stargazers_count"
        case fork = "forks"
        case language
        
    }
}
