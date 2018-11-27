//
//  RepositoryViewModel.swift
//  Github
//
//  Created by Gwanho Kim on 27/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

protocol RepositoryViewModelInputs {
    
}

protocol RepositoryViewModelOutputs {
    var repositoryName: String { get }
}

protocol RepositoryViewModelType {
    var inputs: RepositoryViewModelInputs { get }
    var outpust: RepositoryViewModelOutputs { get }
}

final class RepositoryViewModel: RepositoryViewModelInputs, RepositoryViewModelOutputs {
    private let disposeBag = DisposeBag()
    
    private let repository: Repository
    
    var repositoryName: String { return self.repository.name }
    
    init(repository: Repository) {
        self.repository = repository
    }
}

extension RepositoryViewModel: RepositoryViewModelType {
    var inputs: RepositoryViewModelInputs { return self }
    var outpust: RepositoryViewModelOutputs { return self }
}
