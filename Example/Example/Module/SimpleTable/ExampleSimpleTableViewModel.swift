//
//  ExampleSimpleTableViewModel.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

final class ExampleSimpleTableViewModel {
    private let disposeBag = DisposeBag()

    let items = BehaviorRelay<[ExampleSimpleTableMemberModel]>(value: [])
    let loadPageTrigger = PublishSubject<Void>()
    let refreshIndicator = BehaviorRelay<Bool>(value: false)
    
    init() {
        loadPageTrigger
            .flatMap { _ -> Observable<[ExampleSimpleTableMemberModel]> in
                return ExampleSimpleTableAPI.simple().asObservable()
            }.do(onNext: { [weak self] _ in
                self?.refreshIndicator.accept(false)
            }).bind(to: items)
            .disposed(by: disposeBag)
    }
    
    func fetchData() {
        loadPageTrigger.onNext(())
    }
}
