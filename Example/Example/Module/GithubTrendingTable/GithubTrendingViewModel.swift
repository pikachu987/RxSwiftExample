//
//  GithubTrendingViewModel.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class GithubTrendingViewModel: BaseViewModel {
    private var language = ""
    private var page = 1

    let item = PublishRelay<GithubTrendingRepositories>()
    let items = BehaviorRelay<[GithubTrendingRepository]>(value: [])
    let loadPageTrigger = PublishSubject<Bool>()
    let isLoading = BehaviorRelay<Bool>(value: false)
    let indicator = BehaviorRelay<Bool>(value: false)
    let refreshIndicator = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    
    override init() {
        super.init()

        let request = loadPageTrigger
            .observe(on: MainScheduler.asyncInstance)
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true)
            })
            .observe(on: CurrentThreadScheduler.instance)
            .flatMap { [weak self] isRefresh -> Observable<(isRefresh: Bool, response: GithubTrendingTrendingResponse)> in
                return GithubTrendingAPI.request(GithubTrendingTrendingRequest(language: self?.language ?? "", page: self?.page ?? 1))
                    .compactMap { response in
                        return response as? GithubTrendingTrendingResponse
                    }.compactMap { response in
                        return (isRefresh, response)
                    }
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] element in
                self?.isLoading.accept(false)
                self?.indicator.accept(false)
                self?.refreshIndicator.accept(false)
                if element.response.resultCode == .error {
                    self?.errorMessage.accept(element.response.errorMessage)
                } else {
                    self?.errorMessage.accept(nil)
                }
            })
            .filter({ $0.1.resultCode == .success })
            .compactMap({ (isRefresh: $0.isRefresh, repositories: $0.response.repositories) })
            .share()
        
        request
            .compactMap({ $0.repositories })
            .bind(to: item)
            .disposed(by: disposeBag)
        
        Observable.zip(request, items) { request, items in
            if request.isRefresh {
                return request.repositories?.items ?? []
            } else {
                return items + (request.repositories?.items ?? [])
            }
        }
        .bind(to: items)
        .disposed(by: disposeBag)
        
    }
    
    func fetchRefreshData() {
        loadPageTrigger.onNext(true)
    }

    func fetchLoadMoreData() {
        if errorMessage.value != nil { return }
        if isLoading.value { return }
        loadPageTrigger.onNext(false)
    }

    func showIndicator() {
        indicator.accept(true)
    }
}
