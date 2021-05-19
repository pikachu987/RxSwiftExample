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

    func testShare() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let share = observable.share()
        share.subscribe { event in
            print("1: \(event)")
        }.disposed(by: self.disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            share.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
    }
    
    func testPublish() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let publish = observable.publish()
        
        publish.subscribe { event in
            print("1: \(event)")
        }.disposed(by: self.disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            publish.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        publish.connect()
            .disposed(by: self.disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
    }
    
    func testPublishRefCount() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let publish = observable.publish().refCount()
        
        publish.subscribe { event in
            print("1: \(event)")
        }.disposed(by: self.disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            publish.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
    }
    
    func testReplay() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let replay = observable.replay(2)
        
        replay.subscribe { event in
            print("1: \(event)")
        }.disposed(by: self.disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            replay.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        replay.connect()
            .disposed(by: self.disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
    }

    func testReplayRefCount() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let replay = observable.replay(2).refCount()
        
        replay.subscribe { event in
            print("1: \(event)")
        }.disposed(by: self.disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            replay.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
    }
}
