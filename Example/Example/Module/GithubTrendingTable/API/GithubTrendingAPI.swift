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
        return RxAlamofire.request(request.method, request.url, parameters: request.parameters)
            .debug()
            //.observe(on: MainScheduler.instance)
            .sample(<#T##sampler: ObservableType##ObservableType#>)
            .flatMap { dataRequest -> Observable<GithubTrendingResponse> in
                print("dataRequest.data: \(dataRequest.data)")
                let response = request.responseType.init(data: dataRequest.data)
                return Observable.just(response)
            }//.subscribe(on: CurrentThreadScheduler.instance)
    }
}
