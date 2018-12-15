//
//  MyRepositoriesViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

protocol MyRepositoriesViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    func repositoryTap(_ indexPath: IndexPath)
}

protocol MyRepositoriesViewModelOutputs {
    var items: BehaviorRelay<[Repository]> { get }
    var isLoading: Driver<Bool> { get }
    var error: PublishSubject<Swift.Error> { get }
    var repositoryViewModel: Driver<RepositoryViewModel> { get }
}

protocol MyRepositoriesViewModelType {
    var inputs: MyRepositoriesViewModelInputs { get }
    var outpust: MyRepositoriesViewModelOutputs { get }
}

final class MyRepositoriesViewModel: MyRepositoriesViewModelInputs, MyRepositoriesViewModelOutputs {
    private let disposeBag = DisposeBag()
    private var page = 1
    
    private let selectItem = BehaviorRelay<Repository?>(value: nil)
    
    var items: BehaviorRelay<[Repository]>
    var isLoading: Driver<Bool>
    var error: PublishSubject<Error>
    var repositoryViewModel: Driver<RepositoryViewModel>
    
    var loadPageTrigger: PublishSubject<Void>
    var loadNextPageTrigger: PublishSubject<Void>
    
    init() {
        self.items = BehaviorRelay<[Repository]>(value: [])
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        self.error = PublishSubject<Swift.Error>()
        self.repositoryViewModel = Driver.empty()
        
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()
        
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[Repository]> in
                guard let reposUrl = ProfileHelper.shared.profile.value?.reposUrl else {
                    return Observable.empty()
                        .trackActivity(loading)
                }
                if isLoading { return Observable.empty() }
                self.page = 1
                return API.myRepo(reposUrl, page: self.page)
                    .trackActivity(loading)
        }
        
        let loadNextRequest = self.isLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .flatMap { isLoading -> Observable<[Repository]>  in
                guard let profile = ProfileHelper.shared.profile.value else { return Observable.empty() }
                guard let reposUrl = profile.reposUrl else { return Observable.empty() }
                if self.items.value.count >= profile.repoCount {
                    return Observable.empty()
                }
                if isLoading { return Observable.empty() }
                self.page += 1
                return API.myRepo(reposUrl, page: self.page)
                    .trackActivity(loading)
        }
        
        let request = Observable.of(loadRequest, loadNextRequest)
            .merge()
            .do(onError: { error in
                self.error.onNext(error)
            }).catchError { (error) -> Observable<[Repository]> in
                Observable.empty()
            }.share(replay: 1)
        
        Observable.combineLatest(request, self.items.asObservable()) { (request, items) in
            return self.page == 1 ? request : items + request
            }.sample(request)
            .do(onNext: { _ in
                if self.page == 1 {
                    self.items.accept([])
                }
            })
            .bind(to: self.items)
            .disposed(by: self.disposeBag)
        
        self.repositoryViewModel = self.selectItem
            .asDriver()
            .filterNil()
            .flatMapLatest { repository -> Driver<RepositoryViewModel> in
                return Driver.just(RepositoryViewModel(repository: repository))
        }
    }
    
    func repositoryTap(_ indexPath: IndexPath) {
        self.selectItem.accept(self.items.value[indexPath.row])
    }
}

extension MyRepositoriesViewModel: MyRepositoriesViewModelType {
    var inputs: MyRepositoriesViewModelInputs { return self }
    var outpust: MyRepositoriesViewModelOutputs { return self }
}
