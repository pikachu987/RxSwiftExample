//
//  UtilityTests.swift
//  ExampleTests
//
//  Created by GwanhoKim on 2021/05/19.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking

@testable import Example

class UtilityTests: XCTestCase {
    let disposeBag = DisposeBag()

    // Observable의 이벤트가 발생할때 이벤트 핸들러
    // subscribe시점이 아닌 이벤트 발생시점
    func testDoOn() throws {
        Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance)
            .take(10)
            .do(onNext: {event in
                print("do: \(event)")
            })
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.11) { error in

        }
        /*
         do: 0
         next(0)
         do: 1
         next(1)
         do: 2
         next(2)
         do: 3
         next(3)
         do: 4
         next(4)
         do: 5
         next(5)
         do: 6
         next(6)
         do: 7
         next(7)
         do: 8
         next(8)
         do: 9
         next(9)
         completed
         */
    }
    
    // ObserveOn 이 호출된 다음 메서드가 수행될 스케쥴러를 지정할수 있다.
    func testObserveOn() throws {
        Observable<Int>.create({ observer in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onCompleted()
            return Disposables.create()
        }).observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
        .do(onNext: { print("do: \(Thread.isMainThread), \($0)") })
        .observe(on: MainScheduler.instance)
        .subscribe { print("subscribe: \(Thread.isMainThread), \($0)") }
        .disposed(by: self.disposeBag)
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.11) { error in

        }
        /*
         do: false, 1
         subscribe: true, next(1)
         do: false, 2
         subscribe: true, next(2)
         do: false, 3
         subscribe: true, next(3)
         subscribe: true, completed
         */
    }
    
    // Observable이 수행될 스케쥴러를 지정한다. create 블럭 안에서의 스케쥴러를 지정할수 있다.
    func testSubscribeOn() throws {
        Observable<String>.create { observer in
            let eventText = "create: \(Thread.isMainThread)"
            print(eventText)
            observer.onNext(eventText)
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .map { value -> String in
            let eventText = "map: \(Thread.isMainThread)"
            print(eventText)
            return eventText
        }
        .asDriver(onErrorJustReturn: "-1")
        .asObservable()
        .do(onNext: { value in
            print("do: \(Thread.isMainThread)")
        })
        .subscribe {  (value) in
            print("subscribe: \(Thread.isMainThread)")
        }.disposed(by: self.disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.11) { error in

        }
        /*
         create: false
         map: false
         do: true
         subscribe: true
         */
    }
    
    // materialize: 이벤트가 전달될때 어떤 이벤트인지도 같이 전달된다.
    // dematerialize: materialize된 이벤트를 다시 일반 이벤트발생형태로 변경한다.
    func testMaterialize() throws {
        Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance).take(4)
            .do(onNext: { event in
                print("do1: \(event)")
            })
            .materialize()
            .do(onNext: { event in
                print("do2: \(event)")
            })
            .dematerialize()
            .do(onNext: { event in
                print("do3: \(event)")
            })
            .subscribe { print("subscribe: \($0)") }
            .disposed(by: self.disposeBag)
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.11) { error in

        }
        /*
         do1: 0
         do2: next(0)
         do3: 0
         subscribe: next(0)
         do1: 1
         do2: next(1)
         do3: 1
         subscribe: next(1)
         do1: 2
         do2: next(2)
         do3: 2
         subscribe: next(2)
         do1: 3
         do2: next(3)
         do3: 3
         subscribe: next(3)
         do2: completed
         subscribe: completed
         */
    }
    
    // Observable과 동일한 수명을 가진 일회용 리소스를 만듭니다.
    func testUsing() throws {
        class ResourceDisposable: Disposable {
            func dispose() {
                print("dispose!")
            }
        }
        Observable.using({ () -> ResourceDisposable in
            return ResourceDisposable()
        }) { disposable in
            return Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance)
        }.take(3)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.11) { error in

        }
        /*
         next(0)
         next(1)
         next(2)
         completed
         dispose!
         */
    }
}
