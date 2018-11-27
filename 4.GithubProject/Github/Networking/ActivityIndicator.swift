//
//  ActivityIndicator.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    private let source: Observable<E>
    private let cancelable: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        self.source = source
        self.cancelable = Disposables.create(with: disposeAction)
    }
    
    func dispose() {
        self.cancelable.dispose()
    }
    
    func asObservable() -> Observable<E> {
        return self.source
    }
}

class ActivityIndicator : SharedSequenceConvertibleType {
    public typealias E = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let lock = NSRecursiveLock()
    private let variable = Variable(0)
    private let loading: SharedSequence<SharingStrategy, Bool>
    
    public init() {
        self.loading = self.variable.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
        return Observable.using({ () -> ActivityToken<O.E> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }
    
    private func increment() {
        self.lock.lock()
        self.variable.value += 1
        self.lock.unlock()
    }
    
    private func decrement() {
        self.lock.lock()
        self.variable.value -= 1
        self.lock.unlock()
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return self.loading
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<E> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}
