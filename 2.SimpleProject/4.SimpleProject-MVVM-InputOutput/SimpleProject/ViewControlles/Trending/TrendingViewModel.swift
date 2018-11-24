//
//  TrendingViewModel.swift
//  SimpleProject
//
//  Created by Gwanho Kim on 24/11/2018.
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
}

protocol TrendingViewModelType {
    var inputs: TrendingViewModelInputs { get }
    var outpust: TrendingViewModelOutputs { get }
}

final class TrendingViewModel: TrendingViewModelInputs, TrendingViewModelOutputs {
    private let disposeBag = DisposeBag()
    private var language = ""
    
    var items: BehaviorRelay<[Repository]>
    var loadPageTrigger: PublishSubject<Void>
    
    init() {
        self.items = BehaviorRelay<[Repository]>(value: [])
        self.loadPageTrigger = PublishSubject<Void>()
        
        self.loadPageTrigger
            .asObserver()
            .flatMap { _ -> Observable<[Repository]> in
                self.items.accept([])
                return API.trendingRepositories(self.language)
                    .asObservable()
            }.bind(to: self.items)
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
