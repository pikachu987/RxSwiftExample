//
//  RelationViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

protocol RelationViewModelInputs {
    
}

protocol RelationViewModelOutputs {
    
}

protocol RelationViewModelType {
    var inputs: RelationViewModelInputs { get }
    var outpust: RelationViewModelOutputs { get }
}

final class RelationViewModel: RelationViewModelInputs, RelationViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}

extension RelationViewModel: RelationViewModelType {
    var inputs: RelationViewModelInputs { return self }
    var outpust: RelationViewModelOutputs { return self }
}
