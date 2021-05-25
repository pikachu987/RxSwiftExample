//
//  GithubTrendingViewModel.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class GithubTrendingViewModel: ViewModelType {
    struct Dependency {
        var language = ""
        var page = 1
    }

    struct Input {
        let loadPageTrigger = PublishSubject<Void>()
        let refreshPageTrigger = PublishSubject<Void>()
        let loadMorePageTrigger = PublishSubject<Void>()
    }
 
    struct Output {
        let item = BehaviorRelay<GithubTrendingRepositories?>(value: nil)
        let items = BehaviorRelay<[GithubTrendingRepository]>(value: [])
        let isLoading = BehaviorRelay<Bool>(value: false)
        let indicator = BehaviorRelay<Bool>(value: false)
        let refreshIndicator = BehaviorRelay<Bool>(value: false)
        let bottomIndicator = BehaviorRelay<Bool>(value: false)
        let errorMessage = BehaviorRelay<String?>(value: nil)
    }

    var disposeBag: DisposeBag = DisposeBag()
    var dependency: Dependency
    var input: Input
    var output: Output
    
    init() {
        dependency = Dependency()
        input = Input()
        output = Output()
        
        let loadRequest = input.loadPageTrigger
            .do(onNext: { [weak self] in
                self?.output.indicator.accept(true)
            })
            .map({ return true })
        
        let refreshRequest = input.refreshPageTrigger
            .do(onNext: { [weak self] in
                self?.dependency.page = 1
            })
            .map({ return true })
        
        let loadMoreRequest = input.loadMorePageTrigger
            .filter({ [weak self] in
                guard let self = self else { return false }
                if self.output.errorMessage.value != nil { return false }
                if self.output.isLoading.value { return false }
                if self.output.items.value.count >= (self.output.item.value?.totalCount ?? 0) { return false }
                return true
            })
            .do(onNext: { [weak self] in
                self?.output.bottomIndicator.accept(true)
            })
            .map({ return false })
        
        let request = Observable.of(loadRequest, refreshRequest, loadMoreRequest)
            .merge()
            .do(onNext: { [weak self] isRefresh in
                self?.output.isLoading.accept(true)
            })
            .flatMap { [weak self] isRefresh -> Observable<(isRefresh: Bool, response: GithubTrendingTrendingResponse)> in
                return GithubTrendingAPI.request(GithubTrendingTrendingRequest(language: self?.dependency.language ?? "", page: self?.dependency.page ?? 1))
                    .compactMap { response in
                        return response as? GithubTrendingTrendingResponse
                    }.compactMap { response in
                        return (isRefresh, response)
                    }
            }
            .do(onNext: { [weak self] element in
                self?.output.isLoading.accept(false)
                self?.output.indicator.accept(false)
                self?.output.bottomIndicator.accept(false)
                self?.output.refreshIndicator.accept(false)
                if element.response.resultCode == .error {
                    self?.output.errorMessage.accept(element.response.errorMessage)
                } else {
                    self?.dependency.page += 1
                    self?.output.errorMessage.accept(nil)
                }
            })
            .filter({ $0.1.resultCode == .success })
            .compactMap({ (isRefresh: $0.isRefresh, repositories: $0.response.repositories) })
            .share()

        request
            .compactMap({ $0.repositories })
            .bind(to: output.item)
            .disposed(by: disposeBag)

        Observable.zip(request, output.items) { request, items in
            if request.isRefresh {
                return request.repositories?.items ?? []
            } else {
                return items + (request.repositories?.items ?? [])
            }
        }
        .bind(to: output.items)
        .disposed(by: disposeBag)
    }
}
