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
        let loadPageTrigger = PublishSubject<Bool>()
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

        let request = input
            .loadPageTrigger
            .do(onNext: { [weak self] _ in
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
    
    func fetchRefreshData() {
        input.loadPageTrigger.onNext(true)
    }

    func fetchLoadMoreData() {
        if output.errorMessage.value != nil { return }
        if output.isLoading.value { return }
        if output.items.value.count >= (output.item.value?.totalCount ?? 0) { return }
        output.bottomIndicator.accept(true)
        input.loadPageTrigger.onNext(false)
    }

    func showIndicator() {
        output.indicator.accept(true)
    }
}
