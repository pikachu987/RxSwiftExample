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
            "page": 1
        ]
        return parameters
    }

    private let language: String

    init(language: String) {
        self.language = language
    }
}
