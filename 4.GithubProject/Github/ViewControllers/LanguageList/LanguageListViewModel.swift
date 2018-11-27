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
    
}

protocol LanguageListViewModelOutputs {
    
}

protocol LanguageListViewModelType {
    var inputs: LanguageListViewModelInputs { get }
    var outpust: LanguageListViewModelOutputs { get }
}

final class LanguageListViewModel: LanguageListViewModelInputs, LanguageListViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}

extension LanguageListViewModel: LanguageListViewModelType {
    var inputs: LanguageListViewModelInputs { return self }
    var outpust: LanguageListViewModelOutputs { return self }
}
