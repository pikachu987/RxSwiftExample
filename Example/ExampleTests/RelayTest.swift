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

    func testPublishRelay() throws {
        let relay = PublishRelay<Int>()
        relay.accept(1)
        relay.accept(2)
        relay.accept(3)
        relay.subscribe { event in
            print(event)
        }.disposed(by: self.disposeBag)
        relay.accept(4)
        relay.accept(5)
        /*
         next(4)
         next(5)
         */
    }
    
    func testBehaviorReply() throws {
        let relay = BehaviorRelay<Int>(value: 0)
        relay.accept(1)
        relay.accept(2)
        relay.accept(3)
        relay.subscribe { event in
            print(event)
        }.disposed(by: self.disposeBag)
        relay.accept(4)
        relay.accept(5)
        /*
         next(3)
         next(4)
         next(5)
         */
    }
}
