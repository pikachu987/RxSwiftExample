//
//  BasicExampleTests.swift
//  BasicExampleTests
//
//  Created by GwanhoKim on 2021/05/16.
//  Copyright © 2021 pikachu987. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import BasicExample

class BasicExampleTests: XCTestCase {

    func testCreateObservable() throws {
        func createJust<E>(element: E) -> Observable<E> {
            return Observable.create { observer in
                observer.on(.next(element))
                observer.on(.completed)
                return Disposables.create()
            }
        }
        let disposeBag = DisposeBag()
        
        createJust(element: "create Observable")
            .subscribe(onNext: { element in
                print("create Observable")
                XCTAssertEqual(element, "create Observable")
            }, onCompleted: {
                print("onComplete")
            })
            .disposed(by: disposeBag)
        
        let aaa = createJust(element: "create AAA Observable")
            
        let expectation = expectation(description: "")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            aaa.subscribe(onNext: { element in
                print(element)
                
                expectation.fulfill()
            }).disposed(by: disposeBag)
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testJustObservable() throws {

        let observable = Observable.of(1, 2, 3)
        let subscription = observable.subscribe({ num in
          print(num)
        })
        subscription.dispose()
        
        let disposeBag = DisposeBag()
        Observable.just("just Observable")
            .subscribe(onNext: { element in
                XCTAssertEqual(element, "just Observable")
            })
            .disposed(by: disposeBag)

    }
    
    func testEmptyObservable() throws {
        let disposeBag = DisposeBag()
        Observable.empty()
            .subscribe(onNext: { element in
                XCTAssertEqual(element, "")
            })
            .disposed(by: disposeBag)
    }
    
    func testNeverObservable() throws {
        let disposeBag = DisposeBag()
        Observable.never()
            .subscribe(onNext: { element in
                XCTAssertEqual(element, "")
            }).disposed(by: disposeBag)
    }

    func testErrorObservable() throws {
        let disposeBag = DisposeBag()
        Observable.error(NSError(domain: "error", code: 404, userInfo: nil))
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
    }

    func testFromObservable() throws {
        let disposeBag = DisposeBag()
        Observable.from([1, 3, 5, 7, 9, 10])
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)

        Observable.from([["aa": 1, "bb": "hi"], ["aa": 2, "bb": "hello"]])
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
        
        Observable.from(["aa": 1, "bb": "hi"])
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
    }
    
    func testOfObservable() throws {
        let disposeBag = DisposeBag()
        Observable.of(1, 3, 5, 7, 9, 10)
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
    }
    
    func testDeferredObservable() throws {
        let disposeBag = DisposeBag()
        Observable.deferred({ Observable.just("Hello") })
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)

        var isSwitch = true
        let defferredObservable = Observable<String>.deferred({
            if isSwitch {
                return Observable.just("isSwitch is True")
            } else {
                return Observable.just("isSwitch is False")
            }
        })
        defferredObservable.subscribe { event in
            print("defferredObservable1: \(event)")
        }.disposed(by: disposeBag)
        isSwitch = false
        defferredObservable.subscribe { event in
            print("defferredObservable2: \(event)")
        }.disposed(by: disposeBag)
    }
    
    func testSingle() throws {
        let disposeBag = DisposeBag()
        Single<String>.create(subscribe: { single in
            single(.success("single!!!"))
            return Disposables.create()
        }).subscribe(onSuccess: { success in
            print("Single onSuccess: \(success)")
        }, onFailure: { error in
            
        }, onDisposed: {
            
        }).disposed(by: disposeBag)
        
        Completable.create(subscribe: { completable in
            completable(.completed)
            return Disposables.create()
        }).subscribe(onCompleted: {
            print("Completable onCompleted")
        }, onError: { error in
            
        }).disposed(by: disposeBag)
        
        Maybe<String>.create(subscribe: { maybe in
            maybe(.success("success"))
            maybe(.completed)
            return Disposables.create()
        }).subscribe(onSuccess: { success in
            print("Maybe onSuccess: \(success)")
        }, onError: { error in
            print("Maybe onError: \(error)")
        }, onCompleted: {
            print("Maybe onCompleted")
        }).disposed(by: disposeBag)
    }
    
    func testAsyncSubject() throws {
        let disposeBag = DisposeBag()
        
        let subject = AsyncSubject<Int>()
        subject.on(.next(1))
        subject.on(.next(2))
        subject.on(.next(3))
        
        subject.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        
        subject.on(.next(4))
        subject.on(.next(5))
        subject.on(.next(6))
        subject.on(.completed)
    }
    
    func testAsyncSubjectError() throws {
        let disposeBag = DisposeBag()
        
        let subject = AsyncSubject<Int>()
        subject.on(.next(1))
        subject.on(.next(2))
        subject.on(.next(3))
        
        subject.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        
        subject.on(.next(4))
        subject.on(.next(5))
        subject.on(.next(6))
        subject.on(.error(NSError(domain: "err", code: 404, userInfo: nil)))
    }
    
    func testPublishSubject() throws {
        let disposeBag = DisposeBag()
        
        let subject = PublishSubject<Int>()
        subject.onNext(1)
        
        subject.subscribe { event in
            print("1. \(event)")
//            XCTAssertEqual(event.element, 1)
        }.disposed(by: disposeBag)
        
        subject.onNext(2)
        subject.onNext(3)
        
        subject.subscribe { event in
            print("2. \(event)")
//            XCTAssertEqual(event.element, 1)
        }.disposed(by: disposeBag)
        
        subject.onNext(4)
        subject.onNext(5)
//        subject.onError(NSErro r(domain: "", code: -1, userInfo: nil))
        subject.onCompleted()
        subject.onNext(6)
    }
    
    func testBehaviorSubject() throws {
        let disposeBag = DisposeBag()
        
        let subject = BehaviorSubject<String>(value: "init")
        subject.subscribe { event in
            print("1. \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext("1")
        
        subject.subscribe { event in
            print("2. \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext("2")
        subject.onNext("3")
        
        subject.subscribe { event in
            print("3. \(event)")
        }.disposed(by: disposeBag)
        
        subject.onNext("4")
        subject.onNext("5")
    }
    
    func testPublishRelay() throws {
        let disposeBag = DisposeBag()
        let relay = PublishRelay<Int>()
        relay.accept(1)
        relay.accept(2)
        relay.accept(3)
        relay.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        relay.accept(4)
        relay.accept(5)
    }
    
    func testBehaviorRelay() throws {
        let disposeBag = DisposeBag()
        let relay = BehaviorRelay<Int>(value: 5)
        relay.accept(1)
        relay.accept(2)
        relay.accept(3)
        relay.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        relay.accept(4)
        relay.accept(5)
    }

    func testShare() throws {
        let disposeBag = DisposeBag()
        let observable = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(5).map({ element -> Int in
            print("element: \(element)")
            return element
        })
        
//        let share = observable.share()
        
//        share.subscribe { event in
//            print("1: \(event)")
//        }.disposed(by: disposeBag)
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            share.subscribe { event in
//                print("2: \(event)")
//            }.disposed(by: disposeBag)
//        }
        
//        let publish = observable.publish().refCount()
//
//        publish.subscribe { event in
//            print("3: \(event)")
//        }.disposed(by: disposeBag)
//
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            publish.subscribe { event in
//                print("4: \(event)")
//            }.disposed(by: disposeBag)
//        }

//        publish.connect().disposed(by: disposeBag)
        
        let replay = observable.replay(3).refCount()
        replay.subscribe { event in
            print("5: \(event)")
        }.disposed(by: disposeBag)

        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            replay.subscribe { event in
                print("6: \(event)")
            }.disposed(by: disposeBag)
        }
        
//        replay.connect().disposed(by: disposeBag)
        
        let expectation = expectation(description: "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 6) { error in
            
        }
    }
    
    func testFlatMap() throws {
        let disposeBag = DisposeBag()
        
        struct Data {
            var score: BehaviorRelay<Int>
        }
        
        let score = PublishSubject<Data>()
        
        score.subscribe { data in
            print("1. \(data)")
        }.disposed(by: disposeBag)
        
        score.map { data in
            return data.score
        }.subscribe { data in
            print("2. \(data)")
        }.disposed(by: disposeBag)
        
        score.flatMap { data in
            return data.score
        }.subscribe { data in
            print("3. \(data)")
        }.disposed(by: disposeBag)
        
        score.flatMapLatest { data in
            return data.score
        }.subscribe { data in
            print("5. \(data)")
        }.disposed(by: disposeBag)
        
        score.compactMap { data in
            return data.score
        }.subscribe { data in
            print("4. \(data)")
        }.disposed(by: disposeBag)
        
        let first = Data(score: BehaviorRelay<Int>(value: 1))
        let second = Data(score: BehaviorRelay<Int>(value: 2))
        score.onNext(first)
        first.score.accept(3)
        score.onNext(second)
        second.score.accept(4)
        first.score.accept(5)
    }
    
    func testMap() throws {
        let disposeBag = DisposeBag()

        let observable = Observable<String>.from(["1", "2", "3", "4"])
        
        let blocking = observable.toBlocking()
        XCTAssertEqual(try! blocking.first(), "1")
        XCTAssertEqual(try! blocking.toArray(), ["1", "2", "3", "4"])
        
        observable.map { Int($0) }
            .subscribe { event in
                print("1. :\(event)")
            }.disposed(by: disposeBag)
        
        observable.flatMap { Observable<String>.just($0) }
            .subscribe { event in
                print("2. :\(event)")
            }.disposed(by: disposeBag)
        
        observable.compactMap { Int($0) }
            .subscribe { event in
                print("3. :\(event)")
            }.disposed(by: disposeBag)
        
        let value = BehaviorRelay<String?>(value: nil)
        
        let button = UIButton()
        
        value.bind(to: button.rx.title())
            .disposed(by: disposeBag)
        
        button.rx.tap.asObservable().flatMap { _ in
            return Observable<String>.create { observer in
                observer.onNext("Hello")
                observer.onCompleted()
                return Disposables.create()
            }
        }.subscribe { event in
            value.accept(event.element)
            XCTAssertEqual(button.currentTitle, "Hello")
        }.disposed(by: disposeBag)  
        
        button.rx.tap.asObservable().subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        
        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)
    }

}
