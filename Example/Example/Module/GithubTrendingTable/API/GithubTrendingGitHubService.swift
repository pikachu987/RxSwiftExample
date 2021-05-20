//
//  GithubTrendingRequest.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/20.
//

import Foundation
import Alamofire

class GithubTrendingRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com") ?? URL(fileURLWithPath: "")
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return ""
    }
    
    var parameters: Parameters {
        return [:]
    }

    var url: URLConvertible {
        return baseURL.appendingPathComponent(path)
    }
}
