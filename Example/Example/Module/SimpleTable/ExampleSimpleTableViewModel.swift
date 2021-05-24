//
//  ExampleSimpleTableViewModel.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class ExampleSimpleTableViewModel: ViewModelType {
    struct Dependency {
    }

    struct Input {
        let loadPageTrigger = PublishSubject<Void>()
    }
 
    struct Output {
        let items = BehaviorRelay<[ExampleSimpleTableMemberModel]>(value: [])
        let refreshIndicator = BehaviorRelay<Bool>(value: false)
    }

    var disposeBag: DisposeBag = DisposeBag()
    var dependency: Dependency
    var input: Input
    var output: Output
    
    init() {
        dependency = Dependency()
        input = Input()
        output = Output()


        input.loadPageTrigger
            .flatMap { _ -> Observable<[ExampleSimpleTableMemberModel]> in
                return ExampleSimpleTableAPI.simple().asObservable()
            }.do(onNext: { [weak self] _ in
                self?.output.refreshIndicator.accept(false)
            }).bind(to: output.items)
            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        input.loadPageTrigger.onNext(())
    }
}
