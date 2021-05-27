//
//  GithubTrendingTrendingRequest.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/20.
//

import Foundation
import Alamofire

final class GithubTrendingTrendingRequest: GithubTrendingRequest {
    override var method: HTTPMethod {
        return .get
    }
    
    override var path: String {
        return "/search/repositories"
    }

    override var parameters: Parameters {
        let parameters: Parameters = [
            "q": "user:\(user) language:\(language)",
            "sort": "stars",
            "order": "desc",
            "page": page
        ]
        return parameters
    }

    override var responseType: GithubTrendingResponse.Type {
        return GithubTrendingTrendingResponse.self
    }

    private let user: String
    private let language: String
    private let page: Int

    init(user: String, language: String, page: Int) {
        self.user = user
        self.language = language
        self.page = page
    }
}
