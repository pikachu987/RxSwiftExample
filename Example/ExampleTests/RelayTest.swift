//
//  RelayTest.swift
//  ExampleTests
//
//  Created by GwanhoKim on 2021/05/18.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking

@testable import Example

class RelayTest: XCTestCase {
    let disposeBag = DisposeBag()

    func testExample() throws {
    }
}



//    func testPublishRelay() throws {
//        let disposeBag = DisposeBag()
//        let relay = PublishRelay<Int>()
//        relay.accept(1)
//        relay.accept(2)
//        relay.accept(3)
//        relay.subscribe { event in
//            print(event)
//        }.disposed(by: disposeBag)
//        relay.accept(4)
//        relay.accept(5)
//    }
//
//    func testBehaviorRelay() throws {
//        let disposeBag = DisposeBag()
//        let relay = BehaviorRelay<Int>(value: 5)
//        relay.accept(1)
//        relay.accept(2)
//        relay.accept(3)
//        relay.subscribe { event in
//            print(event)
//        }.disposed(by: disposeBag)
//        relay.accept(4)
//        relay.accept(5)
//    }
