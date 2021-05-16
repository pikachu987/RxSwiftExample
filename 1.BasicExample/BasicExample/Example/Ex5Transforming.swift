import UIKit
import RxCocoa
import RxSwift

class Ex5Transforming: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.buffer()
//        self.flatMap()
//        self.scan()
//        self.window()
//        self.reduce()
//        self.groupBy()
    }
    
    // 이벤트에 버퍼를 저장한 뒤 묶어서 방출
    // timeSpan: 버퍼에 저장되는 시간간격
    // count: 버퍼에 저장되는 최대 이벤트의 갯수
    func buffer() {
        Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).map{ "buffer: \($0)" }.take(7)
            .buffer(timeSpan: RxTimeInterval.milliseconds(500), count: 3, scheduler: MainScheduler.instance)
            .subscribe { event in print(event) }
            .disposed(by: self.disposeBag)
        /*
         next(["buffer: 0", "buffer: 1"])
         next(["buffer: 2", "buffer: 3", "buffer: 4"])
         next(["buffer: 5", "buffer: 6"])
         completed
         */
    }
    
    // 원본 Observable의 이벤트를 받아 새로운 Observable로 변형한다.
    func flatMap() {
        Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(2)
            .flatMap({ (num) -> Observable<String> in
                return Observable<String>.create { observer in
                    observer.onNext("A\(num)")
                    observer.onNext("B\(num)")
                    return Disposables.create {
                        print("dispose")
                    }
                }
            }).subscribe { print($0) }
            .disposed(by: self.disposeBag)
        /*
         next(A0)
         next(B0)
         next(A1)
         next(B1)
         */
    }
    
    // scan은 값을 축적해서 가지고 있을 수 있으며, 이 값을 통해 이벤트를 변형할 수 있는 메서드이다.
    func scan() {
        Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(5)
            .scan(10, accumulator: { (accumulator, num) -> Int in
                return accumulator + num
            })
            .delaySubscription(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
        /*
         next(10)
         next(11)
         next(13)
         next(16)
         next(20)
         completed
         */
    }
    
    // buffer와 유사하지만 모여진 이벤트로 새로운 observable를 생성한다.
    func window() {
        Observable<Int>.of(1, 2, 3, 4, 5, 6, 7)
            .window(timeSpan: RxTimeInterval.seconds(3), count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { observable in
                print(observable)
                observable.subscribe(onNext: { event in
                    print(event)
                }).disposed(by: self.disposeBag)
            }).disposed(by: self.disposeBag)
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
    }
    
    // 기본값을 가지고, emit된 값들을 연산해서 하나의 결과값 이벤트를 발생하는 Observable 로 변형한다.
    func reduce() {
        Observable<Int>.range(start: 0, count: 10)
            .reduce(100, accumulator: +)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
        /*
         next(145)
         completed
         */
    }
    
    // 이벤트들을 분류해서 key 값을 통해 다른 Observable로 변형 할 수 있다. keySelector에서 각 요소들에의 키값을 추출하는 함수를 전달한다.
    func groupBy() {
        Observable.of(1,2,3,4,5,5,5)
            .groupBy { (value) -> Bool in
                return value % 2 == 0
            }.flatMap { grouped -> Observable<String> in
                if grouped.key {
                    return grouped.map { "even: \($0)" }
                } else {
                    return grouped.map { "odd: \($0)" }
                }
            }.subscribe { print($0) }
            .disposed(by: self.disposeBag)
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
}
