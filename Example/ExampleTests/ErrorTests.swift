//
//  ErrorTests.swift
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

class ErrorTests: XCTestCase {
    let disposeBag = DisposeBag()

    // 에러가 발생되었을때 onError로 종료되지 않고 이벤트를 발생하고 onComplete 될수 있게 한다.
    func testCatchError() {
        Observable<String>.create{ observer in
            for count in 1...3 {
                observer.onNext("\(count)")
            }
            observer.onError(NSError(domain: "error!", code: 404, userInfo: nil))
            return Disposables.create {
                print("dispose!")
            }
        }.catch { (error) -> Observable<String> in
            return Observable.of("close1", "close2")
        }.subscribe({ print($0) })
        .disposed(by: disposeBag)
        /*
         next(1)
         next(2)
         next(3)
         dispose!
         next(close1)
         next(close2)
         completed
         */
    }
    
    // catchErrorJustReturn은 subscribe에서 에러를 감지하는 것이 아닌, Observable에서 에러에 대한 기본 이벤트를 설정한다.
    func testCatchErrorJustReturn() {
        Observable<String>.create{ observer in
            [1, 2, 3].forEach({ observer.on(.next("\($0)")) })
            observer.on(.error(NSError(domain: "error!", code: 404, userInfo: nil)))
            return Disposables.create {
                print("dispose!")
            }
        }.catchAndReturn("End")
        .subscribe({ print($0) })
        .disposed(by: disposeBag)
        /*
         next(1)
         next(2)
         next(3)
         next(End)
         completed
         dispose!
         */
    }
    
    // 에러가 발생했을때 성공을 기대하며 Observable을 다시 시도한다. maxAttemptCount를 통해 재시도 횟수를 지정한다. 2를 주면 재시도를 1번 한다.
    func testRetry() throws {
        var isFirst = true
        Observable<String>.create { observer in
            observer.onNext("1")
            if isFirst {
                observer.onNext("2")
                observer.onNext("3")
                observer.onError(NSError(domain: "Error!", code: 404, userInfo: nil))
                isFirst = false
            } else {
                observer.onNext("2")
                observer.on(.completed)
            }
            return Disposables.create()
        }.retry(2)
        .subscribe({ print($0) })
        .disposed(by: disposeBag)
        /*
         next(1)
         next(2)
         next(3)
         next(1)
         next(2)
         completed
         */
    }
    
    // retry 하는 시점을 지정할수 있다. 재시도는 한번만 수행한다.
    func testRetryWhen() throws {
        var isFirst = true
        Observable<String>.create { observer in
            observer.on(.next("1"))
            if isFirst {
                observer.on(.next("2"))
                observer.on(.next("3"))
                observer.onError(NSError(domain: "Error!", code: 404, userInfo: nil))
            } else {
                observer.on(.next("2"))
                observer.onCompleted()
            }
            return Disposables.create()
        }.retry(when: { _ -> Observable<Int> in
            return Observable<Int>.timer(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(1)
        }).subscribe({ print($0) })
        .disposed(by: disposeBag)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            isFirst = false
        }

        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in

        }
        /*
         next(1)
         next(2)
         next(3)
         next(1)
         next(2)
         completed
         */
    }
    
    // 이벤트가 일정시간동안 발생하지 않으면 오류를 발생시킨다.
    func testTimeout() throws {
        Observable<Int>.create { observer in
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: .now() + 0.01, repeating: 1)
            let cancel = Disposables.create {
                timer.cancel()
            }
            var next = 0
            timer.setEventHandler(handler: {
                if cancel.isDisposed { return }
                if next < 3 {
                    observer.onNext(next)
                    next += 1
                }
            })
            timer.resume()
            return cancel
        }.timeout(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance)
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 0.1) { error in

        }
        /*
         next(0)
         error(Sequence timeout.)
         */
    }
}
