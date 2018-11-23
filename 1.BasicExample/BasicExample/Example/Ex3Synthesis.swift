import UIKit
import RxCocoa
import RxSwift

class Ex3Synthesis: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.combineLatest()
//        self.withLatestFrom()
//        self.merge()
//        self.switchLatest()
//        self.zip()
//        self.concat()
//        self.amb()
//        self.startWith()
    }
    
    // combineLatest는 두 Observable 의 각각의 이벤트가 발생할 때 두 Observable의 마지막 이벤트들을 묶어서 전달한다. 두 이벤트의 타입은 달라도 된다.
    func combineLatest() {
        let combineFirst = Observable.from(["1", "2", "3"])
        let combineSecond = Observable.from(["A", "B", "C", "D"])
        Observable.combineLatest(combineFirst, combineSecond) { (first, second) in
            return (first, second)
            }.subscribe({ print("combineLatest \($0)") })
            .disposed(by: self.disposeBag)
        /*
         combineLatest next(("1", "A"))
         combineLatest next(("2", "A"))
         combineLatest next(("2", "B"))
         combineLatest next(("3", "B"))
         combineLatest next(("3", "C"))
         combineLatest next(("3", "D"))
         combineLatest completed
         */
    }
    
    // withLatestFrom은 두개의 Observable 을 합성하지만, 한쪽 Observable의 이벤트가 발생할때에 합성해주는 메서드이다. 합성할 다른쪽 이벤트가 없다면 이벤트는 스킵된다.
    func withLatestFrom() {
        let latestFromFirst = Observable<Int>.interval(2, scheduler: MainScheduler.instance).take(6)
            .map{ ["A", "B", "C", "", "", "D"][$0] }
            .filter{ !$0.isEmpty }
        
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .take(12)
            .map({ "\($0)" })
            .withLatestFrom(latestFromFirst, resultSelector: { (first, second) in
                return (first, second)
            }).subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        /*
         next(("1", "A"))
         next(("2", "A"))
         next(("3", "B"))
         next(("4", "B"))
         next(("5", "C"))
         next(("6", "C"))
         next(("7", "C"))
         next(("8", "C"))
         next(("9", "C"))
         next(("10", "C"))
         next(("11", "D"))
         completed
         */
    }
    
    // merge는 같은 타입의 이벤트를 발생하는 Observable을 합성하는 함수이며, 각각의 이벤트를 모두 수신할 수 있다.
    func merge() {
        let mergeFirst = Observable<Int>.interval(1, scheduler: MainScheduler.instance).take(3)
            .map({ "mergeFirst: \($0)" })
        let mergeSecond = Observable<Int>.interval(2, scheduler: MainScheduler.instance).take(2)
            .map({ "mergeSecond: \($0)" })
        Observable.of(mergeFirst, mergeSecond).merge().subscribe { event in
            print(event)
            }.disposed(by: self.disposeBag)
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
    func switchLatest() {
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        let switchTest = BehaviorSubject<Observable<String>>(value: first)
        switchTest.switchLatest().subscribe { (event) in
            print(event)
        }.disposed(by: self.disposeBag)
        first.onNext("A1")
        second.onNext("B1")
        switchTest.onNext(second)
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
    func zip() {
        Observable.zip(Observable.from([1, 2, 3, 4]), Observable.of("A", "B", "C")) { (first, second) in
            return "\(first)\(second)"
        }.subscribe({ print($0) })
        .disposed(by: self.disposeBag)
        /*
         next(1A)
         next(2B)
         next(3C)
         completed
         */
    }
    
    // concat은 두개 이상의 Observable를 직렬로 연결한다. 하나의 Observable가 이벤트를 전달 완료 후 그 다음 Observable의 이벤트를 전달한다.
    func concat() {
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .map{ "first: \($0)" }
            .take(3)
            .concat(Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).map{ "second: \($0)" }.take(4))
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
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
    func amb() {
        let first = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .map{ "first: \($0)" }
            .take(3)
        let second = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
            .map{ "second: \($0)" }
            .take(3)
        let third = Observable<Int>.interval(1.1, scheduler: MainScheduler.instance)
            .map{ "third: \($0)" }
            .take(3)
        first.amb(second).amb(third)
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        /*
         next(second: 0)
         next(second: 1)
         next(second: 2)
         completed
         */
    }
    
    // 처음 이벤트를 넣어줄 수 있다.
    func startWith() {
        Observable.from([1, 2, 3, 4, 5])
            .startWith(9, 8, 7)
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
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
}






