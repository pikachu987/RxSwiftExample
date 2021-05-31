//
//  GitHubError.swift
//  Github
//
//  Created by Gwanho Kim on 27/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation

struct GitHubError: Codable {
    let message: String?
    let documentation_url: String?
}
