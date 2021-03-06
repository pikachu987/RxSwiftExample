//
//  FollowersViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 16/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

protocol FollowersViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    func userTap(_ indexPath: IndexPath)
}

protocol FollowersViewModelOutputs {
    var items: BehaviorRelay<[User]> { get }
    var isLoading: Driver<Bool> { get }
    var error: PublishSubject<Swift.Error> { get }
    var userViewModel: Driver<UserViewModel> { get }
}

protocol FollowersViewModelType {
    var inputs: FollowersViewModelInputs { get }
    var outpust: FollowersViewModelOutputs { get }
}

final class FollowersViewModel: FollowersViewModelInputs, FollowersViewModelOutputs {
    private let disposeBag = DisposeBag()
    private var page = 1
    
    private let selectItem = BehaviorRelay<User?>(value: nil)
    
    var items: BehaviorRelay<[User]>
    var isLoading: Driver<Bool>
    var error: PublishSubject<Error>
    var userViewModel: Driver<UserViewModel>
    
    var loadPageTrigger: PublishSubject<Void>
    var loadNextPageTrigger: PublishSubject<Void>
    
    init() {
        self.items = BehaviorRelay<[User]>(value: [])
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        self.error = PublishSubject<Swift.Error>()
        self.userViewModel = Driver.empty()
        
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()
        
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Observable<[User]> in
                guard let followersUrl = ProfileHelper.shared.profile.value?.followersUrl else {
                    return Observable.empty()
                        .trackActivity(loading)
                }
                if isLoading { return Observable.empty() }
                self.page = 1
                return API.follower(followersUrl, page: self.page)
                    .trackActivity(loading)
        }
        
        let loadNextRequest = self.isLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .flatMap { isLoading -> Observable<[User]>  in
                guard let profile = ProfileHelper.shared.profile.value else { return Observable.empty() }
                guard let followersUrl = profile.followersUrl else { return Observable.empty() }
                if self.items.value.count >= profile.followersCount {
                    return Observable.empty()
                }
                if isLoading { return Observable.empty() }
                self.page += 1
                return API.follower(followersUrl, page: self.page)
                    .trackActivity(loading)
        }
        
        let request = Observable.of(loadRequest, loadNextRequest)
            .merge()
            .do(onError: { error in
                self.error.onNext(error)
            }).catchError { (error) -> Observable<[User]> in
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
        
        self.userViewModel = self.selectItem
            .asDriver()
            .filterNil()
            .flatMapLatest { user -> Driver<UserViewModel> in
                return Driver.just(UserViewModel(user: user))
        }
    }
    
    func userTap(_ indexPath: IndexPath) {
        self.selectItem.accept(self.items.value[indexPath.row])
    }
}

extension FollowersViewModel: FollowersViewModelType {
    var inputs: FollowersViewModelInputs { return self }
    var outpust: FollowersViewModelOutputs { return self }
}
