import UIKit
import RxCocoa
import RxSwift

class Ex3ObservableSynthesis: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.combineLatest()
//        self.withLatestFrom()
//        self.merge()
//        self.switchLatest()
        self.zip()
        
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
    }
    
    //
    func zip() {
        let observable1 = Observable.range(start: 0, count: 50000)
            .reduce(0, accumulator: { (value1, value2) -> Int in
                return value1 + value2
            })
        
        // zip으로 두개의 Observable를 합친다.
        Observable.zip(observable1, Observable.just("Sum")) { (sum, text) -> String in return "\(text): \(sum)" }
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background)) // 백그라운드에서 연산한다.
            .observeOn(MainScheduler.instance) // UI등을 변화시킬때는 메인에서 처리할수 있게 쓰레드를 변경한다.
            .subscribe(onNext: { (value) in
                print("Observable zip Complete")
                let label = UILabel(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 100))
                label.text = value
               // self.view.addSubview(label)
            })
            .disposed(by: self.disposeBag)
        print("zip?")
    }
}


