//
//  TrendingViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TrendingViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
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
    
    // MARK: Input property
    
    var loadPageTrigger: PublishSubject<Void>
    
    // MARK: Output property
    
    var items: BehaviorRelay<[Repository]>
    var isLoading: Driver<Bool>
    
    // MARK: Init
    
    init() {
        self.items = BehaviorRelay<[Repository]>(value: [])
        
        let activityIndicator = ActivityIndicator()
        self.isLoading = activityIndicator.asDriver()
        
        self.loadPageTrigger = PublishSubject<Void>()
        
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[Repository]> in
                if isLoading {
                    return Observable.empty()
                } else {
                    self.page = 1
                    self.items.accept([])
                    return API.trendingRepositories(self.language, page: self.page)
                        .trackActivity(activityIndicator)
                }
            }
        let request = Observable.of(loadRequest)
            .merge()
            .share(replay: 1)

        let response = request.flatMap { (repositories) -> Observable<[Repository]> in
            request
                .do(onError: { (error) in

                }).catchError({ (error) -> Observable<[Repository]> in
                    Observable.empty()
                })
            }.share(replay: 1)

        Observable
            .combineLatest(loadRequest, response, self.items.asObservable()) { request, response, items in
                return self.page == 1 ? response : items + response
            }
            .sample(response)
            .bind(to: self.items)
            .disposed(by: self.disposeBag)
    }
    
    
    // MARK: Input Methods
    
    func refresh() {
        self.loadPageTrigger
            .onNext(())
    }
    
    func language(_ language: String) {
        self.language = language
    }
}

// MARK: TrendingViewModelType
extension TrendingViewModel: TrendingViewModelType {
    var inputs: TrendingViewModelInputs { return self }
    var outpust: TrendingViewModelOutputs { return self }
}
