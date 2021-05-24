//
//  GithubTrendingResponse.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/20.
//

import Foundation

class GithubTrendingResponse {
    var statusCode: Int = -1
    var errorMessage: String?
    var resultCode = ResultCode.error

    init() {
        
    }

    required init(statusCode: Int, data: Data?) {
        self.statusCode = statusCode

        if 200 > statusCode || statusCode > 300 {
            resultCode = .error
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String] {
                self.errorMessage = json["message"]
            } else {
                self.errorMessage = "네트워크 에러"
            }
        } else {
            resultCode = .success
        }
    }
}

extension GithubTrendingResponse {
    enum ResultCode {
        case success
        case error
    }
}
