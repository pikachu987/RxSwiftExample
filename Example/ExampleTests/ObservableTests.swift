//
//  ObservableTests.swift
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

class ObservableTests: XCTestCase {
    let disposeBag = DisposeBag()

    func testCreate() throws {
        let observable = Observable<Int>.create { observer in
            observer.on(.next(10))
            observer.on(.next(20))
            observer.onCompleted()
            return Disposables.create()
        }
        observable.subscribe { event in
            print("testCreate: \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertEqual(try! observable.toBlocking().toArray(), [10, 20])
    }

    func testJust() throws {
        let observable = Observable<String>.just("hello")
        observable.subscribe { event in
            print("testJust: \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertEqual(try! observable.toBlocking().single(), "hello")
    }

    func testEmpty() throws {
        let observable = Observable<Int>.empty()
        observable.subscribe { event in
            print("testEmpty: \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertNil(try? observable.toBlocking().first())
    }
    
    func testNever() throws {
        let observable = Observable<Int>.never()
        observable.subscribe { event in
            print("testNever: \(event)")
        }.disposed(by: self.disposeBag)
    }
    
    func testError() throws {
        let observable = Observable<Int>.error(NSError(domain: "error", code: -1, userInfo: nil))
        observable.subscribe { event in
            print("testError: \(event)")
            XCTAssertEqual(event.error! as NSError, NSError(domain: "error", code: -1, userInfo: nil))
        }.disposed(by: self.disposeBag)
        XCTAssertNil(try? observable.toBlocking().single())
    }
    
    func testFrom() throws {
        let observable = Observable<Int>.from([1, 3, 4, 5, 7])
        observable.subscribe { event in
            print("testFrom: observable \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertEqual(try! observable.toBlocking().toArray(), [1, 3, 4, 5, 7])
        
        let observable1 = Observable.from(["aa": 1])
        observable1.subscribe { event in
            print("testFrom: observable1 \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertEqual(try! observable1.toBlocking().last()!.key, "aa")
        XCTAssertEqual(try! observable1.toBlocking().last()!.value, 1)
    }

    func testOf() throws {
        let observable = Observable<String>.of("aa", "bb", "cc", "dd")
        observable.subscribe { event in
            print("testOf: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), ["aa", "bb", "cc", "dd"])
    }
    
    func testDeferred() throws {
        var isChange = false
        let observable = Observable<String>.deferred {
            if isChange {
                return Observable.just("after change")
            } else {
                return Observable.just("before change")
            }
        }

        observable.subscribe { event in
            print("testDeferred: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().single(), "before change")
        
        isChange = true

        observable.subscribe { event in
            print("testDeferred: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().single(), "after change")
    }
    
    func testGenerate() throws {
        let observable = Observable<Int>.generate(initialState: 1, condition: { $0 < 10 }, iterate: { $0 + 4 })
        observable.subscribe { event in
            print("testGenerate: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), [1, 5, 9])
    }
}
