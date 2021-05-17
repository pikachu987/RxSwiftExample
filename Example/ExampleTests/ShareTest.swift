//
//  ShareTest.swift
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

class ShareTest: XCTestCase {
    let disposeBag = DisposeBag()

    func testExample() throws {
    }
}


//    func testShare() throws {
//        let disposeBag = DisposeBag()
//        let observable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(5).map({ element -> Int in
//            print("element: \(element)")
//            return element
//        })
//
////        let share = observable.share()
//
////        share.subscribe { event in
////            print("1: \(event)")
////        }.disposed(by: disposeBag)
////
////        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
////            share.subscribe { event in
////                print("2: \(event)")
////            }.disposed(by: disposeBag)
////        }
//
////        let publish = observable.publish().refCount()
////
////        publish.subscribe { event in
////            print("3: \(event)")
////        }.disposed(by: disposeBag)
////
////        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
////            publish.subscribe { event in
////                print("4: \(event)")
////            }.disposed(by: disposeBag)
////        }
//
////        publish.connect().disposed(by: disposeBag)
//
//        let replay = observable.replay(3).refCount()
//        replay.subscribe { event in
//            print("5: \(event)")
//        }.disposed(by: disposeBag)
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
//            replay.subscribe { event in
//                print("6: \(event)")
//            }.disposed(by: disposeBag)
//        }
//
////        replay.connect().disposed(by: disposeBag)
//
//        let expectation = expectation(description: "")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: 6) { error in
//
//        }
//    }
