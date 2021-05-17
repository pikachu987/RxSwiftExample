//
//  SynthesisTest.swift
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

class SynthesisTest: XCTestCase {
    let disposeBag = DisposeBag()

    func testExample() throws {
    }
}

//
//    func testFlatMap() throws {
//        let disposeBag = DisposeBag()
//
//        struct Data {
//            var score: BehaviorRelay<Int>
//        }
//
//        let score = PublishSubject<Data>()
//
//        score.subscribe { data in
//            print("1. \(data)")
//        }.disposed(by: disposeBag)
//
//        score.map { data in
//            return data.score
//        }.subscribe { data in
//            print("2. \(data)")
//        }.disposed(by: disposeBag)
//
//        score.flatMap { data in
//            return data.score
//        }.subscribe { data in
//            print("3. \(data)")
//        }.disposed(by: disposeBag)
//
//        score.flatMapLatest { data in
//            return data.score
//        }.subscribe { data in
//            print("5. \(data)")
//        }.disposed(by: disposeBag)
//
//        score.compactMap { data in
//            return data.score
//        }.subscribe { data in
//            print("4. \(data)")
//        }.disposed(by: disposeBag)
//
//        let first = Data(score: BehaviorRelay<Int>(value: 1))
//        let second = Data(score: BehaviorRelay<Int>(value: 2))
//        score.onNext(first)
//        first.score.accept(3)
//        score.onNext(second)
//        second.score.accept(4)
//        first.score.accept(5)
//    }
//
//    func testMap() throws {
//        let disposeBag = DisposeBag()
//
//        let observable = Observable<String>.from(["1", "2", "3", "4"])
//
//        let blocking = observable.toBlocking()
//        XCTAssertEqual(try! blocking.first(), "1")
//        XCTAssertEqual(try! blocking.toArray(), ["1", "2", "3", "4"])
//
//        observable.map { Int($0) }
//            .subscribe { event in
//                print("1. :\(event)")
//            }.disposed(by: disposeBag)
//
//        observable.flatMap { Observable<String>.just($0) }
//            .subscribe { event in
//                print("2. :\(event)")
//            }.disposed(by: disposeBag)
//
//        observable.compactMap { Int($0) }
//            .subscribe { event in
//                print("3. :\(event)")
//            }.disposed(by: disposeBag)
//
//        let value = BehaviorRelay<String?>(value: nil)
//
//        let button = UIButton()
//
//        value.bind(to: button.rx.title())
//            .disposed(by: disposeBag)
//
//        button.rx.tap.asObservable().flatMap { _ in
//            return Observable<String>.create { observer in
//                observer.onNext("Hello")
//                observer.onCompleted()
//                return Disposables.create()
//            }
//        }.subscribe { event in
//            value.accept(event.element)
//            XCTAssertEqual(button.currentTitle, "Hello")
//        }.disposed(by: disposeBag)
//
//        button.rx.tap.asObservable().subscribe { event in
//            print(event)
//        }.disposed(by: disposeBag)
//
//        button.sendActions(for: .touchUpInside)
//        button.sendActions(for: .touchUpInside)
//    }
