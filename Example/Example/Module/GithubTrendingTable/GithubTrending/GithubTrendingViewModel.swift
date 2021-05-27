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
        var page = 1
        var searchText = ""
        var language = ""
    }

    struct Input {
        let loadPageTrigger = PublishSubject<Void>()
        let refreshPageTrigger = PublishSubject<Void>()
        let loadMorePageTrigger = PublishSubject<Void>()
        let filterTextTrigger = BehaviorRelay<String?>(value: nil)
        let searchTextTrigger = BehaviorRelay<String?>(value: nil)
        let languageTrigger = PublishSubject<String>()
    }
 
    struct Output {
        let repositoryItem = BehaviorRelay<GithubTrendingRepositories?>(value: nil)
        let repositories = BehaviorRelay<[GithubTrendingRepository]>(value: [])
        let originRepositories = BehaviorSubject<[GithubTrendingRepository]>(value: [])
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
                if ((try? self.output.originRepositories.value())?.count ?? 0) >= (self.output.repositoryItem.value?.totalCount ?? 0) { return false }
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
                return GithubTrendingAPI.request(GithubTrendingTrendingRequest(user: self?.dependency.searchText ?? "", language: self?.dependency.language ?? "", page: self?.dependency.page ?? 1))
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
            .bind(to: output.repositoryItem)
            .disposed(by: disposeBag)

        Observable.zip(request, output.originRepositories) { request, items in
            if request.isRefresh {
                return request.repositories?.items ?? []
            } else {
                return items + (request.repositories?.items ?? [])
            }
        }
        .bind(to: output.originRepositories)
        .disposed(by: disposeBag)
        
        let fiilterText = input
            .filterTextTrigger
            .compactMap({ $0?.lowercased() })
            .throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
        
        Observable.combineLatest(output.originRepositories, fiilterText)
            .map { (list, text) in
                return text == "" ? list : list.filter({ $0.name.lowercased().contains(text) || $0.owner?.login.lowercased().contains(text) == true })
            }
            .bind(to: output.repositories)
            .disposed(by: disposeBag)
        
        input
            .searchTextTrigger
            .compactMap({ $0 })
            .subscribe(onNext: { [weak self] text in
                self?.output.indicator.accept(true)
                self?.dependency.searchText = text
                self?.input.refreshPageTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        input.languageTrigger
            .subscribe(onNext: { [weak self] language in
                self?.dependency.language = language
                self?.output.indicator.accept(true)
                self?.input.refreshPageTrigger.onNext(())
            })
            .disposed(by: disposeBag)
    }
}
