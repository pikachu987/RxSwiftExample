//
//  Authorizations.swift
//  Github
//
//  Created by Gwanho Kim on 10/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation

struct Authorizations: Codable {
    let token: String?
    
//    enum CodingKeys: String, CodingKey {
//        case token = "token"
//    }
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        token = try values.decodeIfPresent(String.self, forKey: .token)
//    }
}
