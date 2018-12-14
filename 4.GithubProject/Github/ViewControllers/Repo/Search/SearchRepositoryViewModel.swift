//
//  SearchRepositoryViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

protocol SearchRepositoryViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    var searchText: PublishSubject<String?> { get }
    func repositoryTap(_ indexPath: IndexPath)
}

protocol SearchRepositoryViewModelOutputs {
    var items: BehaviorRelay<[Repository]> { get }
    var isLoading: Driver<Bool> { get }
    var error: PublishSubject<Swift.Error> { get }
    var repositoryViewModel: Driver<RepositoryViewModel> { get }
}

protocol SearchRepositoryViewModelType {
    var inputs: SearchRepositoryViewModelInputs { get }
    var outpust: SearchRepositoryViewModelOutputs { get }
}

final class SearchRepositoryViewModel: SearchRepositoryViewModelInputs, SearchRepositoryViewModelOutputs {
    private let disposeBag = DisposeBag()
    private var page = 1
    private var query = ""
    
    private let selectItem = BehaviorRelay<Repository?>(value: nil)
    
    var items: BehaviorRelay<[Repository]>
    var isLoading: Driver<Bool>
    var error: PublishSubject<Error>
    var repositoryViewModel: Driver<RepositoryViewModel>
    
    var loadPageTrigger: PublishSubject<Void>
    var loadNextPageTrigger: PublishSubject<Void>
    var searchText: PublishSubject<String?>
    
    init() {
        self.items = BehaviorRelay<[Repository]>(value: [])
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        self.error = PublishSubject<Swift.Error>()
        self.repositoryViewModel = Driver.empty()
        
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()
        self.searchText = PublishSubject<String?>()
        
        let loadRequest = self.searchText.asDriver(onErrorJustReturn: nil)
            .debounce(0.7)
            .distinctUntilChanged()
            .filterNil()
            .filterEmpty()
            .flatMap { query -> Driver<[Repository]> in
                self.query = query
                return API.searchRepositories(query, page: self.page)
                    .trackActivity(loading)
                    .asDriver(onErrorJustReturn: [])
        }
        
        let loadNextRequest = self.isLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .filter({ [weak self] _ -> Bool in
                guard let self = self else { return false }
                return self.query != ""
            })
            .flatMap { isLoading -> Observable<[Repository]>  in
                if isLoading { return Observable.empty() }
                self.page += 1
                return API.searchRepositories(self.query, page: self.page)
                    .trackActivity(loading)
        }
        
        let request = Observable.of(loadRequest.asObservable(), loadNextRequest)
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
    
    func repositoryTap(_ indexPath: IndexPath) {
        self.selectItem.accept(self.items.value[indexPath.row])
    }
}

extension SearchRepositoryViewModel: SearchRepositoryViewModelType {
    var inputs: SearchRepositoryViewModelInputs { return self }
    var outpust: SearchRepositoryViewModelOutputs { return self }
}
