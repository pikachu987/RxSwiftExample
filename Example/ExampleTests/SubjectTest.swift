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
        }).disposed(by: disposeBag)

        subject.on(.next(4))
        subject.on(.next(5))
        subject.on(.next(6))
        subject.on(.completed)
        /*
         testAsync: 6
         testAsync: onCompleted
         */
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
        }).disposed(by: disposeBag)

        subject.on(.next(4))
        subject.on(.next(5))
        subject.on(.next(6))
        subject.on(.error(NSError(domain: "err", code: 404, userInfo: nil)))
        /*
         Error Domain=err Code=404 "(null)"
         */
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
        /*
         testPublish: next(2)
         testPublish: next(3)
         testPublish 2: next(3)
         testPublish: completed
         testPublish 2: completed
         */
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
        /*
         testPublishError: next(2)
         testPublishError: next(3)
         testPublishError 2: next(3)
         testPublishError: error(Error Domain=err Code=-1 "(null)")
         testPublishError 2: error(Error Domain=err Code=-1 "(null)")
         */
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
        /*
         testBehavior: next(1)
         testBehavior: next(2)
         testBehavior 2: next(2)
         testBehavior: next(3)
         testBehavior 2: next(3)
         testBehavior: completed
         testBehavior 2: completed
         */
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
        /*
         testReplay: next(1)
         testReplay: next(2)
         testReplay: next(3)
         testReplay 2: next(2)
         testReplay 2: next(3)
         testReplay: next(4)
         testReplay 2: next(4)
         testReplay: completed
         testReplay 2: completed
         */
    }
}
