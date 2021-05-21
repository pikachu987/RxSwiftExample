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

/*
 Hot Observable 는 생성과 동시에 이벤트를 방출한다.
 subscribe되는 시점과 상관없이 옵저버들에게 이벤트를 중간부터 전송해준다.
 publish, multicast, connect
 replay, replayAll
 share, shareReplay
 sharereplaylatestWhileConnect
 
 
 Cold Observable
 옵저버가 subscribe되는 시점부터 이벤트를 생성하여 방출하기 시작한다.
 기본적으로 Hot Observable가 아닌것들은 Cold Observable이다.
 */
class ShareTest: XCTestCase {
    let disposeBag = DisposeBag()

    // 간단하게 공유를 만들수 있다. subscribe가 더 이상 없을때까지 지속되고 계속적으로 subscription을 공유할 수 있다.
    func testShare() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let share = observable.share()
        share.subscribe { event in
            print("1: \(event)")
        }.disposed(by: disposeBag)
        
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
        /*
         create 0
         1: next(0)
         create 1
         1: next(1)
         create 2
         1: next(2)
         create 3
         1: next(3)
         2: next(3)
         create 4
         1: next(4)
         2: next(4)
         1: completed
         2: completed
         */
    }
    
    func testPublish() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let publish = observable.publish()
        
        publish.subscribe { event in
            print("1: \(event)")
        }.disposed(by: disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            publish.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        publish.connect()
            .disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
        /*
         create 0
         1: next(0)
         create 1
         1: next(1)
         create 2
         1: next(2)
         2: next(2)
         create 3
         1: next(3)
         2: next(3)
         create 4
         1: next(4)
         2: next(4)
         1: completed
         2: completed
         */
    }
    
    func testPublishRefCount() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let publish = observable.publish().refCount()
        
        publish.subscribe { event in
            print("1: \(event)")
        }.disposed(by: disposeBag)
        
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
        /*
         create 0
         1: next(0)
         create 1
         1: next(1)
         create 2
         1: next(2)
         create 3
         1: next(3)
         2: next(3)
         create 4
         1: next(4)
         2: next(4)
         1: completed
         2: completed
         */
    }
    
    func testReplay() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let replay = observable.replay(2)
        
        replay.subscribe { event in
            print("1: \(event)")
        }.disposed(by: disposeBag)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            replay.subscribe { event in
                print("2: \(event)")
            }.disposed(by: self.disposeBag)
        }
        
        replay.connect()
            .disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
        /*
         create 0
         1: next(0)
         create 1
         1: next(1)
         2: next(0)
         2: next(1)
         create 2
         1: next(2)
         2: next(2)
         create 3
         1: next(3)
         2: next(3)
         create 4
         1: next(4)
         2: next(4)
         1: completed
         2: completed
         */
    }

    func testReplayRefCount() throws {
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(5).map { element -> Int in
            print("create \(element)")
            return element
        }
        let replay = observable.replay(2).refCount()
        
        replay.subscribe { event in
            print("1: \(event)")
        }.disposed(by: disposeBag)
        
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
        /*
         create 0
         1: next(0)
         create 1
         1: next(1)
         create 2
         1: next(2)
         2: next(1)
         2: next(2)
         create 3
         1: next(3)
         2: next(3)
         create 4
         1: next(4)
         2: next(4)
         1: completed
         2: completed
         */
    }
    
    // Observable의 시컨스를 하나의 subject를 통해 multicast로 이벤트를 전달하게 된다.
    // connect 하기 전에는 시컨스가 시작되지 않는다.
    func testMulticast() throws {
        let timer = Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance).take(4)
        let subject = PublishSubject<Int>()
        let multicast = timer.multicast(subject)
        multicast.connect()
            .disposed(by: disposeBag)
        
        multicast.subscribe { event in
            print("first scription: \(event)")
        }.disposed(by: disposeBag)
        
        multicast.delaySubscription(RxTimeInterval.milliseconds(20), scheduler: MainScheduler.instance)
            .subscribe { event in
                print("second scription: \(event)")
            }.disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { error in

        }
        /*
         first scription: next(0)
         first scription: next(1)
         first scription: next(2)
         second scription: next(2)
         first scription: next(3)
         second scription: next(3)
         first scription: completed
         second scription: completed
         */
    }
    
    func testMulticastRefCount() throws {
        let timer = Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance).take(4)
        let subject = PublishSubject<Int>()
        let multicast = timer.multicast(subject).refCount()
        
        multicast.subscribe { event in
            print("first scription: \(event)")
        }.disposed(by: disposeBag)
        
        multicast.delaySubscription(RxTimeInterval.milliseconds(20), scheduler: MainScheduler.instance)
            .subscribe { event in
                print("second scription: \(event)")
            }.disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { error in

        }
        /*
         first scription: next(0)
         first scription: next(1)
         first scription: next(2)
         second scription: next(2)
         first scription: next(3)
         second scription: next(3)
         first scription: completed
         second scription: completed
         */
    }
}
