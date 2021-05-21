//
//  GithubTrendingViewModel.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class GithubTrendingViewModel {
    private let disposeBag = DisposeBag()
    private var language = ""

    let items = BehaviorRelay<[GithubTrendingRepository]>(value: [])
    let loadPageTrigger = PublishSubject<Void>()
    let refreshIndicator = BehaviorRelay<Bool>(value: false)
    
    init() {
        loadPageTrigger
            .flatMap { _ -> Observable<[GithubTrendingRepository]> in
                return GithubTrendingAPI.request(GithubTrendingTrendingRequest(language: self.language))
                    .compactMap { response in
                        return response as? GithubTrendingTrendingResponse
                    }.compactMap { response in
                        return response.repositories.items
                    }
            }.do(onNext: { [weak self] _ in
                self?.refreshIndicator.accept(false)
            })
            .bind(to: items)
            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        loadPageTrigger.onNext(())
    }
}