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
    
}

protocol ProfileViewModelOutputs {
    
}

protocol ProfileViewModelType {
    var inputs: ProfileViewModelInputs { get }
    var outpust: ProfileViewModelOutputs { get }
}

final class ProfileViewModel: ProfileViewModelInputs, ProfileViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}

extension ProfileViewModel: ProfileViewModelType {
    var inputs: ProfileViewModelInputs { return self }
    var outpust: ProfileViewModelOutputs { return self }
}
