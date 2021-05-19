//
//  TraitsTest.swift
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

class TraitsTest: XCTestCase {
    let disposeBag = DisposeBag()

    func testSingle() throws {
        let observable = Single<Bool>.create { observer in
            observer(.success(true))
            return Disposables.create()
        }
        observable.subscribe { event in
            print("singleExample: \(event)")
        }.disposed(by: self.disposeBag)
        
        XCTAssertEqual(try! observable.toBlocking().single(), true)
        /*
         singleExample: success(true)
         */
    }

    func testCompletable() throws {
        let observable = Completable.create { observer in
            observer(.completed)
            return Disposables.create()
        }
        observable.subscribe { event in
            print("testCompletable: \(event)")
            XCTAssertEqual(event, .completed)
        }.disposed(by: self.disposeBag)
        /*
         testCompletable: completed
         */
    }

    func testMay() throws {
        let observable = Maybe<String>.create { observer in
            observer(.completed)
            return Disposables.create()
        }
        observable.subscribe { event in
            print("testMay: \(event)")
            XCTAssertEqual(event, .completed)
        }.disposed(by: self.disposeBag)
        
        let observable1 = Maybe<String>.create { observer in
            observer(.success("hello"))
            return Disposables.create()
        }
        observable1.subscribe { event in
            print("testMay: \(event)")
            XCTAssertEqual(event, .success("hello"))
        }.disposed(by: self.disposeBag)
        /*
         testMay: completed
         testMay: success("hello")
         */
    }
}
