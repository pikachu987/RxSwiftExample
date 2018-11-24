//
//  Repositories.swift
//  SimpleProject
//
//  Created by Gwanho Kim on 24/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation

struct Repositories: Codable {
    let totalCount: Int?
    let incompleteResults: Bool?
    let items: [Repository]?
    
    enum CodingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case totalCount = "total_count"
        case items
    }
}
