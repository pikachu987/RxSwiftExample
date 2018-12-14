//
//  ProfileViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

protocol ProfileViewModelInputs {
    var loadProfileTrigger: PublishSubject<Void> { get }
}

protocol ProfileViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var profile: BehaviorRelay<User?> { get }
}

protocol ProfileViewModelType {
    var inputs: ProfileViewModelInputs { get }
    var outpust: ProfileViewModelOutputs { get }
}

final class ProfileViewModel: ProfileViewModelInputs, ProfileViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    var isLoading: Driver<Bool>
    var profile: BehaviorRelay<User?>
    
    var loadProfileTrigger: PublishSubject<Void>
    
    init() {
        self.profile = BehaviorRelay<User?>(value: nil)
        let loading = ActivityIndicator()
        self.isLoading = loading.asDriver()
        
        self.loadProfileTrigger = PublishSubject<Void>()
        
        
        self.isLoading.asObservable()
            .sample(self.loadProfileTrigger)
            .flatMap { isLoading -> Observable<User> in
                return API.profile()
                    .trackActivity(loading)
        }.bind(to: self.profile)
        .disposed(by: self.disposeBag)
    }
}

extension ProfileViewModel: ProfileViewModelType {
    var inputs: ProfileViewModelInputs { return self }
    var outpust: ProfileViewModelOutputs { return self }
}
