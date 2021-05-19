//
//  BaseCoordinator.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift

class BaseCoordinator<E> {
    typealias CoordinationResult = E
    
    let disposeBag = DisposeBag()
    
    private let identifier = UUID()
    
    private var childCoordinators = [UUID: Any]()
    
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }
    
    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
    
    func coordinate<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in self?.free(coordinator: coordinator) })
    }
    
    func start() -> Observable<E> {
        fatalError("Start method should be implemented.")
    }
}

extension BaseCoordinator: Equatable {
    static func == (lhs: BaseCoordinator, rhs: BaseCoordinator) -> Bool {
        return lhs === rhs
    }
    
}
