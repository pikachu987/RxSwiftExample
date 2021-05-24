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
        guard let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return [:] }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let parameters: Parameters = [
            "q": "language:\(language) " + "created:>" + formatter.string(from: lastWeek),
            "sort": "stars",
            "order": "desc",
            "page": page
        ]
        return parameters
    }

    override var responseType: GithubTrendingResponse.Type {
        return GithubTrendingTrendingResponse.self
    }

    private let language: String
    private let page: Int

    init(language: String, page: Int) {
        self.language = language
        self.page = page
    }
}
