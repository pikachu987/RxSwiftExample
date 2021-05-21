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
        /*
         String -> Int :next(Optional(1))
         String -> Int :next(Optional(2))
         String -> Int :next(Optional(3))
         String -> Int :next(Optional(4))
         String -> Int :completed
         */
    }
    
    func testFlatMap() throws {
        let observable = Observable<String>.from(["1", "2", "3", "4"])
        
        XCTAssertEqual(try! observable.toBlocking().toArray(), ["1", "2", "3", "4"])
        
        observable.flatMap { Observable<String>.just($0) }
            .subscribe { event in
                print("String -> Observable<String> :\(event)")
            }.disposed(by: disposeBag)
        /*
         String -> Observable<String> :next(1)
         String -> Observable<String> :next(2)
         String -> Observable<String> :next(3)
         String -> Observable<String> :next(4)
         String -> Observable<String> :completed
         */
    }
    
    // 원본 Observable의 이벤트를 받아 새로운 Observable로 변형한다.
    func testFlatMap2() throws {
        Observable<Int>.from([1, 2, 3])
            .flatMap({ (num) -> Observable<String> in
                return Observable<String>.create { observer in
                    observer.onNext("A\(num)")
                    observer.onNext("B\(num)")
                    return Disposables.create {
                        print("dispose")
                    }
                }
            }).subscribe { print($0) }
            .disposed(by: disposeBag)
        /*
         next(A1)
         next(B1)
         next(A2)
         next(B2)
         next(A3)
         next(B3)
         */
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
        /*
         next(())
         next(())
         */
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
        /*
         1. next(Data(score: RxRelay.BehaviorRelay<Swift.Int>))
         2. map: next(RxRelay.BehaviorRelay<Swift.Int>)
         3. flatMap: next(1)
         4. flatMapLatest: next(1)
         5. compactMap: next(RxRelay.BehaviorRelay<Swift.Int>)
         3. flatMap: next(3)
         4. flatMapLatest: next(3)
         1. next(Data(score: RxRelay.BehaviorRelay<Swift.Int>))
         2. map: next(RxRelay.BehaviorRelay<Swift.Int>)
         3. flatMap: next(2)
         4. flatMapLatest: next(2)
         5. compactMap: next(RxRelay.BehaviorRelay<Swift.Int>)
         3. flatMap: next(4)
         4. flatMapLatest: next(4)
         3. flatMap: next(5)
         */
    }
    
    // combineLatest는 두 Observable 의 각각의 이벤트가 발생할 때 두 Observable의 마지막 이벤트들을 묶어서 전달한다. 두 이벤트의 타입은 달라도 된다.
    func testCombineLatest() throws {
        let first = Observable.from(["1", "2", "3"])
        let second = Observable.of("a", "b", "c", "d")
        Observable.combineLatest(first, second) { first, second in
            return (first, second)
        }.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
        /*
         next(("1", "a"))
         next(("2", "a"))
         next(("2", "b"))
         next(("3", "b"))
         next(("3", "c"))
         next(("3", "d"))
         completed
         */
    }
    
    // withLatestFrom은 두개의 Observable 을 합성하지만, 한쪽 Observable의 이벤트가 발생할때에 합성해주는 메서드이다. 합성할 다른쪽 이벤트가 없다면 이벤트는 스킵된다.
    func testLatestFrom() throws {
        let list = ["A", "B", "C", "", "", "F"]
        let observable = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance).take(6)
            .map({ list[$0] })
            .filter({ !$0.isEmpty })
        
        Observable<Int>.interval(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance)
            .take(18)
            .withLatestFrom(observable) { first, second in
                return (first, second)
            }.subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in

        }
        /*
         next((1, "A"))
         next((2, "A"))
         next((3, "B"))
         next((4, "B"))
         next((5, "C"))
         next((6, "C"))
         next((7, "C"))
         next((8, "C"))
         next((9, "C"))
         next((10, "C"))
         next((11, "F"))
         next((12, "F"))
         next((13, "F"))
         next((14, "F"))
         next((15, "F"))
         next((16, "F"))
         next((17, "F"))
         completed
         */
    }
    
    // merge는 같은 타입의 이벤트를 발생하는 Observable을 합성하는 함수이며, 각각의 이벤트를 모두 수신할 수 있다.
    func testMerge() throws {
        let mergeFirst = Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance)
            .take(3)
            .map({ "mergeFirst: \($0)" })
        let mergeSecond = Observable<Int>.interval(RxTimeInterval.milliseconds(20), scheduler: MainScheduler.instance)
            .take(2)
            .map({ "mergeSecond: \($0)" })
        Observable.of(mergeFirst, mergeSecond)
            .merge()
            .subscribe { event in
                print(event)
            }.disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.1) { error in

        }
        /*
         next(mergeFirst: 0)
         next(mergeFirst: 1)
         next(mergeSecond: 0)
         next(mergeFirst: 2)
         next(mergeSecond: 1)
         completed
         */
    }
    
    // switchLatest는 observable을 switch 할 수 있는 observable이다.
    // 이벤트를 수신하고 싶은 observable로 바꾸면 해당 이벤트가 발생하는 것을 수신할 수 있다.
    func testSwitchLatest() throws {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        let subject = BehaviorSubject<Observable<String>>(value: first)
        subject.switchLatest().subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
        first.onNext("A1")
        second.onNext("B1")
        subject.onNext(second)
        first.onNext("A2")
        second.onNext("B2")
        second.onNext("B3")
        first.onNext("A3")
        first.onNext("A4")
        second.onNext("B4")
        second.onNext("B5")
        /*
         next(A1)
         next(B2)
         next(B3)
         next(B4)
         next(B5)
         */
    }
    
    func testFlatMapLatest() throws {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        let subject = BehaviorSubject<Observable<String>>(value: first)
        subject.flatMapLatest { data in
            return data
        }.subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
        first.onNext("A1")
        second.onNext("B1")
        subject.onNext(second)
        first.onNext("A2")
        second.onNext("B2")
        second.onNext("B3")
        first.onNext("A3")
        first.onNext("A4")
        second.onNext("B4")
        second.onNext("B5")
        /*
         next(A1)
         next(B2)
         next(B3)
         next(B4)
         next(B5)
         */
    }
    
    // zip으로 두개의 Observable를 합친다.
    func testZip() throws {
        Observable.zip(Observable.from([1, 2, 3, 4]), Observable.of("A", "B", "C")) { (first, second) in
            return "\(first)\(second)"
        }.subscribe({ print($0) })
        .disposed(by: disposeBag)
        /*
         next(1A)
         next(2B)
         next(3C)
         completed
         */
    }
    
    // concat은 두개 이상의 Observable를 직렬로 연결한다. 하나의 Observable가 이벤트를 전달 완료 후 그 다음 Observable의 이벤트를 전달한다.
    func testConcat() throws {
        Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .map { "first: \($0)" }
            .take(3)
            .concat(Observable<Int>.interval(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance).map { "second: \($0)" }.take(4))
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in

        }
        /*
         next(first: 0)
         next(first: 1)
         next(first: 2)
         next(second: 0)
         next(second: 1)
         next(second: 2)
         next(second: 3)
         completed
         */
    }
    
    // 맨 먼저발생한 Observable의 이벤트만을 사용한다.
    func testAmb() throws {
        let first = Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .map{ "first: \($0)" }
            .take(3)
        let second = Observable<Int>.interval(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance)
            .map{ "second: \($0)" }
            .take(3)
        let third = Observable<Int>.interval(RxTimeInterval.milliseconds(110), scheduler: MainScheduler.instance)
            .map{ "third: \($0)" }
            .take(3)
        first.amb(second).amb(third)
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in

        }
        /*
         next(second: 0)
         next(second: 1)
         next(second: 2)
         completed
         */
    }
    
    // 처음 이벤트를 넣어줄 수 있다.
    func testStartWith() throws {
        Observable.from([1, 2, 3, 4, 5])
            .startWith(9, 8, 7)
            .subscribe({ print($0) })
            .disposed(by: disposeBag)
        /*
         next(9)
         next(8)
         next(7)
         next(1)
         next(2)
         next(3)
         next(4)
         next(5)
         completed
         */
    }
    
    // 이벤트에 버퍼를 저장한 뒤 묶어서 방출
    // timeSpan: 버퍼에 저장되는 시간간격
    // count: 버퍼에 저장되는 최대 이벤트의 갯수
    func testBuffer() throws {
        Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance).map{ "buffer: \($0)" }.take(7)
            .buffer(timeSpan: RxTimeInterval.milliseconds(50), count: 3, scheduler: MainScheduler.instance)
            .subscribe { event in print(event) }
            .disposed(by: disposeBag)
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.1) { error in

        }
        /*
         next(["buffer: 0", "buffer: 1", "buffer: 2"])
         next(["buffer: 3", "buffer: 4", "buffer: 5"])
         next(["buffer: 6"])
         completed
         */
    }
    
    // scan은 값을 축적해서 가지고 있을 수 있으며, 이 값을 통해 이벤트를 변형할 수 있는 메서드이다.
    func testScan() throws {
        Observable<Int>.from([1, 2, 4, 6, 2])
            .scan(3, accumulator: { (accumulator, num) -> Int in
                print("accumulator: \(accumulator), num: \(num)")
                return accumulator + num
            })
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        /*
         accumulator: 3, num: 1
         next(4)
         accumulator: 4, num: 2
         next(6)
         accumulator: 6, num: 4
         next(10)
         accumulator: 10, num: 6
         next(16)
         accumulator: 16, num: 2
         next(18)
         completed
         */
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3) { error in

        }
    }
    
    // buffer와 유사하지만 모여진 이벤트로 새로운 observable를 생성한다.
    func testWindow() throws {
        Observable<Int>.of(1, 2, 3, 4, 5, 6, 7)
            .window(timeSpan: RxTimeInterval.milliseconds(30), count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { observable in
                print(observable)
                observable.subscribe(onNext: { event in
                    print(event)
                }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        /*
         RxSwift.AddRef<Swift.Int>
         1
         2
         3
         RxSwift.AddRef<Swift.Int>
         4
         5
         6
         RxSwift.AddRef<Swift.Int>
         7
         */
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.3) { error in

        }
    }
    
    // 기본값을 가지고, emit된 값들을 연산해서 하나의 결과값 이벤트를 발생하는 Observable 로 변형한다.
    func testReduce() throws {
        Observable<Int>.range(start: 0, count: 10)
            .reduce(100, accumulator: +)
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        /*
         next(145)
         completed
         */
    }
    
    // 이벤트들을 분류해서 key 값을 통해 다른 Observable로 변형 할 수 있다. keySelector에서 각 요소들에의 키값을 추출하는 함수를 전달한다.
    func testGroupBy() throws {
        Observable.of(1, 2, 3, 4, 5, 5, 5)
            .groupBy { (value) -> Bool in
                return value % 2 == 0
            }.flatMap { grouped -> Observable<String> in
                if grouped.key {
                    return grouped.map { "even: \($0)" }
                } else {
                    return grouped.map { "odd: \($0)" }
                }
            }.subscribe { print($0) }
            .disposed(by: disposeBag)
        /*
         next(odd: 1)
         next(even: 2)
         next(odd: 3)
         next(even: 4)
         next(odd: 5)
         next(odd: 5)
         next(odd: 5)
         completed
         */
    }
    
    // 지정한 시간간격 내에 하나의 이벤트만 발생했을때 이벤트를 전달한다.
    // 이벤트가 발생한후 debounce 시간동안 다른 이벤트가 발생하지 않으면 debounce된 Observable 에 이벤트가 발생한다.
    // 이벤트가 발생한후 debounce 시간동안 다른 이벤트가 발생하면 debounce된 Observable 에 이벤트가 발생하지 않는다.
    func testDebounce() throws {
        let textField = UITextField()
        let observable = BehaviorRelay<String>(value: "")
        textField.rx.text
            .asObservable()
            .compactMap({ $0 })
            .bind(to: observable)
            .disposed(by: disposeBag)
        
        observable.debounce(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance)
            .subscribe { event in
                print("testDebounce: \(event)")
            }.disposed(by: disposeBag)
        
        textField.insertText("a")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            textField.insertText("b")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                textField.insertText("c")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    textField.insertText("d")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        textField.insertText("e")
                    }
                }
            }
        }
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
        /*
         testDebounce: next(abc)
         testDebounce: next(abcde)
         */
    }
    
    // 지정한 시간 내에 발생한 최초 이벤트 및 가장 최신의 이벤트를 발생시킨다.
    func testThrottle() throws {
        let textField = UITextField()
        let observable = BehaviorRelay<String>(value: "")
        textField.rx.text
            .asObservable()
            .compactMap({ $0 })
            .bind(to: observable)
            .disposed(by: disposeBag)
        
        observable.throttle(RxTimeInterval.milliseconds(30), scheduler: MainScheduler.instance)
            .subscribe { event in
                print("testThrottle: \(event)")
            }.disposed(by: disposeBag)
        
        textField.insertText("a")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            textField.insertText("b")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                textField.insertText("c")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                    textField.insertText("d")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        textField.insertText("e")
                    }
                }
            }
        }
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
        /*
         testThrottle: next()
         testThrottle: next(ab)
         testThrottle: next(abc)
         testThrottle: next(abcd)
         testThrottle: next(abcde)
         */
    }
    
    // 이전 이벤트와 비교해서 값이 다를 경우에만 이벤트를 방출한다.
    func testDistinct() throws {
        let array = ["가", "나", "가", "가", "가", "바", "나", "나", "나", "다", "나", "나"]
        Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance).take(array.count)
            .enumerated().map({ array[$0.index] })
            .distinctUntilChanged()
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
        /*
         next(가)
         next(나)
         next(가)
         next(바)
         next(나)
         next(다)
         next(나)
         completed
         */
    }
    
    // 지정한 index의 이벤트만 발생시킨다.
    func testElementAt() throws {
        Observable.of(1, 2, 3, 3, 7, 10, 1).element(at: 4)
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        /*
         next(7)
         completed
         */
    }
    
    // 첫번째 이벤트만 발생시킨다.
    func testSingle() throws {
        Observable.of(1, 2, 3, 3, 7, 10, 1).single()
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        /*
         next(1)
         error(Sequence contains more than one element.)
         */
    }
    
    // sampler observable의 이벤트에 따라 본래 observable의 이벤트가 전달된다. 전달할 이벤트가 없을때는 무시한다.
    func testSample() throws {
        Observable<Int>.interval(RxTimeInterval.milliseconds(10), scheduler: MainScheduler.instance).take(10)
            .sample(Observable<Int>.interval(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance))
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        let expectation = expectation(description: "expectation")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.6) { error in

        }
        /*
         next(4)
         next(9)
         completed
         */
    }
    
    // 이벤트를 스킵한다.
    func testSkip() throws {
        Observable.of(1, 2, 3, 4, 5, 6)
            .skip(5)
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        Observable.of(1, 2, 3, 4, 5, 6)
            .skip { $0 != 5 }
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        /*
         next(6)
         completed
         next(5)
         next(6)
         completed
         */
    }
    
    // 모든 이벤트를 무시한다
    func testIgnoreElements() throws {
        Observable.of(1,2,3,4,5)
            .ignoreElements()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
