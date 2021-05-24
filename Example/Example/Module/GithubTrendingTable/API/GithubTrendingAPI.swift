//
//  GithubTrendingAPI.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/20.
//

import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

final class GithubTrendingAPI {
    static func request(_ request: GithubTrendingRequest) -> Observable<GithubTrendingResponse> {
        return RxAlamofire.requestData(request.method, request.url, parameters: request.parameters)
            .observe(on: MainScheduler.instance)
            .flatMap { dataRequest -> Observable<GithubTrendingResponse> in
                let response = request.responseType.init(statusCode: dataRequest.0.statusCode, data: dataRequest.1)
                return Observable.just(response)
            }.subscribe(on: CurrentThreadScheduler.instance)
    }
}
