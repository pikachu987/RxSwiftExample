//
//  TrendingViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

protocol TrendingViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    func refresh()
    func language(_ language: String)
    func repositoryTap(_ indexPath: IndexPath)
}

protocol TrendingViewModelOutputs {
    var items: BehaviorRelay<[Repository]> { get }
    var isLoading: Driver<Bool> { get }
    var languageRelay: BehaviorRelay<String> { get }
    var error: PublishSubject<Swift.Error> { get }
    var repositoryViewModel: Driver<RepositoryViewModel> { get }
}

protocol TrendingViewModelType {
    var inputs: TrendingViewModelInputs { get }
    var outpust: TrendingViewModelOutputs { get }
}

final class TrendingViewModel: TrendingViewModelInputs, TrendingViewModelOutputs {
    private let disposeBag = DisposeBag()
    private var language = ""
    private var page = 1
    
    private let selectItem = BehaviorRelay<Repository?>(value: nil)
    
    var items: BehaviorRelay<[Repository]>
    var isLoading: Driver<Bool>
    var languageRelay: BehaviorRelay<String>
    var error: PublishSubject<Error>
    var repositoryViewModel: Driver<RepositoryViewModel>
    
    var loadPageTrigger: PublishSubject<Void>
    var loadNextPageTrigger: PublishSubject<Void>
    
    init() {
        self.items = BehaviorRelay<[Repository]>(value: [])
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        self.languageRelay = BehaviorRelay<String>(value: "")
        self.error = PublishSubject<Swift.Error>()
        self.repositoryViewModel = Driver.empty()
        
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()
        
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[Repository]> in
                if isLoading { return Observable.empty() }
                self.page = 1
                self.items.accept([])
                return API.trendingRepositories(self.language, page: self.page)
                    .trackActivity(loading)
        }
        
        let loadNextRequest = self.isLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .flatMap { isLoading -> Observable<[Repository]>  in
                if isLoading { return Observable.empty() }
                self.page += 1
                return API.trendingRepositories(self.language, page: self.page)
                    .trackActivity(loading)
        }
        
        let request = Observable.of(loadRequest, loadNextRequest)
            .merge()
            .do(onError: { (error) in
                self.error.onNext(error)
            }).catchError({ (error) -> Observable<[Repository]> in
                Observable.empty()
            })
            .share(replay: 1)
        
        Observable.combineLatest(request, self.items.asObservable()) { request, items in
            return self.page == 1 ? request : items + request
            }.sample(request)
            .bind(to: self.items)
            .disposed(by: self.disposeBag)
        
        self.repositoryViewModel = self.selectItem
            .asDriver()
            .filterNil()
            .flatMapLatest { repository -> Driver<RepositoryViewModel> in
                return Driver.just(RepositoryViewModel(repository: repository))
        }
    }
    
    func refresh() {
        self.loadPageTrigger
            .onNext(())
    }
    
    func language(_ language: String) {
        self.language = language
        self.languageRelay.accept(language)
    }
    
    func repositoryTap(_ indexPath: IndexPath) {
        self.selectItem.accept(self.items.value[indexPath.row])
    }
}

extension TrendingViewModel: TrendingViewModelType {
    var inputs: TrendingViewModelInputs { return self }
    var outpust: TrendingViewModelOutputs { return self }
}
