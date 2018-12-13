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
    
}

protocol MyRepositoriesViewModelOutputs {
}

protocol MyRepositoriesViewModelType {
    var inputs: MyRepositoriesViewModelInputs { get }
    var outpust: MyRepositoriesViewModelOutputs { get }
}

final class MyRepositoriesViewModel: MyRepositoriesViewModelInputs, MyRepositoriesViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}

extension MyRepositoriesViewModel: MyRepositoriesViewModelType {
    var inputs: MyRepositoriesViewModelInputs { return self }
    var outpust: MyRepositoriesViewModelOutputs { return self }
}
