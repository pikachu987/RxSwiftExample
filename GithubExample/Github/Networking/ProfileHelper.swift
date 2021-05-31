//
//  ProfileHelper.swift
//  Github
//
//  Created by Gwanho Kim on 14/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileHelper: NSObject {
    static let shared = ProfileHelper()
    private let disposeBag = DisposeBag()
    
    private let loading = ActivityIndicator()
    lazy var isLoading: Driver<Bool> = {
        return self.loading.asDriver()
    }()
    
    var profile: BehaviorRelay<User?> = BehaviorRelay<User?>(value: nil)
    var loadProfileTrigger: PublishSubject<Void> = PublishSubject<Void>()
    
    private override init() {
        super.init()
        
        self.isLoading.asObservable()
            .debug()
            .sample(self.loadProfileTrigger)
            .flatMap { isLoading -> Observable<User> in
                return API.profile()
                    .trackActivity(self.loading)
            }.bind(to: self.profile)
            .disposed(by: self.disposeBag)
    }
    
    func ifExistsProfileLoad() {
        if self.profile.value == nil {
            self.loadProfileTrigger.onNext(())
        }
    }
}
