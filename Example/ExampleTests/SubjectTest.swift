//
//  SubjectTest.swift
//  ExampleTests
//
//  Created by GwanhoKim on 2021/05/17.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking

@testable import Example

class SubjectTest: XCTestCase {
    let disposeBag = DisposeBag()

    func testAsync() throws {
        let subject = AsyncSubject<Int>()
        subject.on(.next(1))
        subject.on(.next(2))
        subject.on(.next(3))

        subject.subscribe(onNext: { value in
            print("testAsync: \(value)")
            XCTAssertEqual(value, 6)
        }, onCompleted: {
            print("testAsync: onCompleted")
        }).disposed(by: self.disposeBag)

        subject.on(.next(4))
        subject.on(.next(5))
        subject.on(.next(6))
        subject.on(.completed)
    }
    
    func testAsyncError() throws {
        let subject = AsyncSubject<Int>()
        subject.on(.next(1))
        subject.on(.next(2))
        subject.on(.next(3))

        subject.subscribe(onNext: { value in
            print("testAsync: \(value)")
        }, onError: { error in
            print(error)
            XCTAssertEqual(error as NSError, NSError(domain: "err", code: 404, userInfo: nil))
        }, onCompleted: {
            print("testAsync: onCompleted")
        }).disposed(by: self.disposeBag)

        subject.on(.next(4))
        subject.on(.next(5))
        subject.on(.next(6))
        subject.on(.error(NSError(domain: "err", code: 404, userInfo: nil)))
    }
    
    func testPublish() throws {
        let subject = PublishSubject<Int>()
        subject.onNext(1)
        subject.subscribe { event in
            print("testPublish: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(2)
        
        subject.subscribe { event in
            print("testPublish 2: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(3)
        subject.onCompleted()
        subject.onNext(4)
    }
    
    func testPublishError() throws {
        let subject = PublishSubject<Int>()
        subject.onNext(1)
        subject.subscribe { event in
            print("testPublishError: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(2)
        
        subject.subscribe { event in
            print("testPublishError 2: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(3)
        subject.onError(NSError(domain: "err", code: -1, userInfo: nil))
        subject.onNext(4)
    }
    
    func testBehavior() throws {
        let subject = BehaviorSubject<Int>(value: 1)
        subject.subscribe { event in
            print("testBehavior: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(2)
        
        subject.subscribe { event in
            print("testBehavior 2: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(3)
        subject.onCompleted()
        subject.onNext(4)
    }
    
    func testReplay() throws {
        let subject = ReplaySubject<Int>.create(bufferSize: 2)
        
        subject.onNext(1)
        subject.onNext(2)
        
        subject.subscribe { event in
            print("testReplay: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(3)
        
        subject.subscribe { event in
            print("testReplay 2: \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext(4)
        subject.onCompleted()
        subject.onNext(5)
    }
}
