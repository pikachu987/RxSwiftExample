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

final class TrendingViewModel {
    private let disposeBag = DisposeBag()
    var language = ""
    
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
}
