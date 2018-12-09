//
//  LoginViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 04/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

protocol LoginViewModelInputs {
    var id: PublishSubject<String?> { get }
    var password: PublishSubject<String?> { get }
    var loginTap: PublishSubject<Void> { get }
}

protocol LoginViewModelOutputs {
    var validatedId: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var enabledLogin: Driver<Bool> { get }
    var login: Driver<Bool> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outpust: LoginViewModelOutputs { get }
}

final class LoginViewModel: LoginViewModelInputs, LoginViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    var id: PublishSubject<String?>
    var password: PublishSubject<String?>
    var loginTap: PublishSubject<Void>
    
    var validatedId: Driver<ValidationResult>
    var validatedPassword: Driver<ValidationResult>
    var enabledLogin: Driver<Bool>
    var login: Driver<Bool>
    
    init() {
        self.id = PublishSubject<String?>()
        self.password = PublishSubject<String?>()
        self.loginTap = PublishSubject<Void>()
        
        self.validatedId = self.id.asDriver(onErrorJustReturn: nil)
            .filterNil()
            .flatMapLatest({ id in
                return ValidationService.id(id)
                    .asDriver(onErrorJustReturn: .failed(message: "Error Server"))
            })
        
        self.validatedPassword = self.password.asDriver(onErrorJustReturn: nil)
            .filterNil()
            .flatMapLatest({ password in
                return ValidationService.password(password)
                    .asDriver(onErrorJustReturn: .failed(message: "Error Server"))
            })
        
        self.enabledLogin = Driver.combineLatest(self.validatedId, self.validatedPassword, resultSelector: { id, password in
            return id.isValid && password.isValid
        })
        
        let idAndPassword = Driver.combineLatest(
            self.id.asDriver(onErrorJustReturn: nil),
            self.password.asDriver(onErrorJustReturn: nil)
        ) { ($0, $1) }
        
        self.login = self.loginTap
            .asDriver(onErrorJustReturn: ())
            .withLatestFrom(idAndPassword)
            .flatMapLatest{ (id, password) in
                return API.login(id ?? "", password: password ?? "")
                    .asDriver(onErrorJustReturn: false)
            }
    }
}

extension LoginViewModel: LoginViewModelType {
    var inputs: LoginViewModelInputs { return self }
    var outpust: LoginViewModelOutputs { return self }
}
