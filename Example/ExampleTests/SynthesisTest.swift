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

    func testMap() throws {
        let observable = Observable<String>.from(["1", "2", "3", "4"])
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), ["1", "2", "3", "4"])
        
        observable.map { Int($0) }
            .subscribe { event in
                print("String -> Int :\(event)")
            }.disposed(by: disposeBag)
    }
    
    func testFlatMap() throws {
        let observable = Observable<String>.from(["1", "2", "3", "4"])
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), ["1", "2", "3", "4"])
        
        observable.flatMap { Observable<String>.just($0) }
            .subscribe { event in
                print("String -> Observable<String> :\(event)")
            }.disposed(by: disposeBag)
    }
    
    func testMapButton() throws {
        let button = UIButton()

        let value = BehaviorRelay<String?>(value: nil)
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
    
    func testMapDataScore() throws {
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
            print("2. map: \(data)")
        }.disposed(by: disposeBag)

        score.flatMap { data in
            return data.score
        }.subscribe { data in
            print("3. flatMap: \(data)")
        }.disposed(by: disposeBag)

        score.flatMapLatest { data in
            return data.score
        }.subscribe { data in
            print("4. flatMapLatest: \(data)")
        }.disposed(by: disposeBag)

        score.compactMap { data in
            return data.score
        }.subscribe { data in
            print("5. compactMap: \(data)")
        }.disposed(by: disposeBag)

        let first = Data(score: BehaviorRelay<Int>(value: 1))
        let second = Data(score: BehaviorRelay<Int>(value: 2))
        score.onNext(first)
        first.score.accept(3)
        score.onNext(second)
        second.score.accept(4)
        first.score.accept(5)
    }
}
