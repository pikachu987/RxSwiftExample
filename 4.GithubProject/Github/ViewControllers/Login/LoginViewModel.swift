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
    
}

protocol LoginViewModelOutputs {
    
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outpust: LoginViewModelOutputs { get }
}

final class LoginViewModel: LoginViewModelInputs, LoginViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}

extension LoginViewModel: LoginViewModelType {
    var inputs: LoginViewModelInputs { return self }
    var outpust: LoginViewModelOutputs { return self }
}
