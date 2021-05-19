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
        /*
         testCreate: next(10)
         testCreate: next(20)
         testCreate: completed
         */
    }

    func testJust() throws {
        let observable = Observable<String>.just("hello")
        observable.subscribe { event in
            print("testJust: \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertEqual(try! observable.toBlocking().single(), "hello")
        /*
         testJust: next(hello)
         testJust: completed
         */
    }

    func testEmpty() throws {
        let observable = Observable<Int>.empty()
        observable.subscribe { event in
            print("testEmpty: \(event)")
        }.disposed(by: self.disposeBag)
        XCTAssertNil(try? observable.toBlocking().first())
        /*
         testEmpty: completed
         */
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
        /*
         testError: error(Error Domain=error Code=-1 "(null)")
         */
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
        /*
         testFrom: observable next(1)
         testFrom: observable next(3)
         testFrom: observable next(4)
         testFrom: observable next(5)
         testFrom: observable next(7)
         testFrom: observable completed
         testFrom: observable1 next((key: "aa", value: 1))
         testFrom: observable1 completed
         */
    }

    func testOf() throws {
        let observable = Observable<String>.of("aa", "bb", "cc", "dd")
        observable.subscribe { event in
            print("testOf: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), ["aa", "bb", "cc", "dd"])
        /*
         testOf: next(aa)
         testOf: next(bb)
         testOf: next(cc)
         testOf: next(dd)
         testOf: completed
         */
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
        /*
         testDeferred: next(before change)
         testDeferred: completed
         testDeferred: next(after change)
         testDeferred: completed
         */
    }
    
    func testGenerate() throws {
        let observable = Observable<Int>.generate(initialState: 1, condition: { $0 < 10 }, iterate: { $0 + 4 })
        observable.subscribe { event in
            print("testGenerate: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), [1, 5, 9])
        /*
         testGenerate: next(1)
         testGenerate: next(5)
         testGenerate: next(9)
         testGenerate: completed
         */
    }
}
