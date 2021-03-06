//
//  LanguageListViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 27/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

protocol LanguageListViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    func languageTap(_ indexPath: IndexPath)
}

protocol LanguageListViewModelOutputs {
    var items: BehaviorRelay<[String]> { get }
    var language: Driver<String> { get }
    var isLoading: Driver<Bool> { get }
}

protocol LanguageListViewModelType {
    var inputs: LanguageListViewModelInputs { get }
    var outpust: LanguageListViewModelOutputs { get }
}

final class LanguageListViewModel: LanguageListViewModelInputs, LanguageListViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    private let selectItem = BehaviorRelay<String?>(value: nil)
    
    var items: BehaviorRelay<[String]>
    var language: Driver<String>
    var isLoading: Driver<Bool>
    
    var loadPageTrigger: PublishSubject<Void>
    
    init() {
        self.items = BehaviorRelay<[String]>(value: [])
        
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        
        self.loadPageTrigger = PublishSubject<Void>()
        
        self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { _ -> Observable<[String]> in
                return API.languages()
                    .trackActivity(loading)
            }.bind(to: self.items)
            .disposed(by: self.disposeBag)
        
        self.language = self.selectItem
            .asDriver()
            .filterNil()
            .flatMapLatest { language -> Driver<String> in
                return Driver.just(language)
        }
    }
    
    func refresh() {
        self.loadPageTrigger
            .onNext(())
    }
    
    func languageTap(_ indexPath: IndexPath) {
        self.selectItem.accept(self.items.value[indexPath.row])
    }
}

extension LanguageListViewModel: LanguageListViewModelType {
    var inputs: LanguageListViewModelInputs { return self }
    var outpust: LanguageListViewModelOutputs { return self }
}
