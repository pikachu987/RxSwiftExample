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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case htmlUrl = "html_url"
    }
}
