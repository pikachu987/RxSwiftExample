//
//  TrendingViewModel.swift
//  SomeProject
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TrendingViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    func refresh()
    func language(_ language: String)
}

protocol TrendingViewModelOutputs {
    var items: BehaviorRelay<[Repository]> { get }
    var isLoading: Driver<Bool> { get }
}

protocol TrendingViewModelType {
    var inputs: TrendingViewModelInputs { get }
    var outpust: TrendingViewModelOutputs { get }
}

final class TrendingViewModel: TrendingViewModelInputs, TrendingViewModelOutputs {
    private let disposeBag = DisposeBag()
    private var language = ""
    private var page = 1
    
    var items: BehaviorRelay<[Repository]>
    var isLoading: Driver<Bool>
    
    var loadPageTrigger: PublishSubject<Void>
    var loadNextPageTrigger: PublishSubject<Void>
    
    init() {
        self.items = BehaviorRelay<[Repository]>(value: [])
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()

        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[Repository]> in
                if isLoading { return Observable.empty() }
                self.page = 1
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
                print(error)
            }).catchError({ (error) -> Observable<[Repository]> in
                return Observable.empty()
            })
            .share(replay: 1)
        
        Observable.combineLatest(request, self.items.asObservable()) { request, items in
            return self.page == 1 ? request : items + request
            }.sample(request)
            .bind(to: self.items)
            .disposed(by: self.disposeBag)
    }
    
    func refresh() {
        self.loadPageTrigger
            .onNext(())
    }
    
    func language(_ language: String) {
        self.language = language
    }
}

extension TrendingViewModel: TrendingViewModelType {
    var inputs: TrendingViewModelInputs { return self }
    var outpust: TrendingViewModelOutputs { return self }
}
