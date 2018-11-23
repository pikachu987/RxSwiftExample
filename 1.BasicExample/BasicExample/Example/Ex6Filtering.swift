import UIKit
import RxCocoa
import RxSwift

class Ex6Filtering: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.debounce()
//        self.throttle()
//        self.distinct()
//        self.elementAt()
//        self.single()
//        self.sample()
//        self.skip()
//        self.ignoreElements()
    }
    
    // 지정한 시간간격 내에 하나의 이벤트만 발생했을때 이벤트를 전달한다.
    // 이벤트가 발생한후 debounce 시간동안 다른 이벤트가 발생하지 않으면 debounce된 Observable 에 이벤트가 발생한다.
    // 이벤트가 발생한후 debounce 시간동안 다른 이벤트가 발생하면 debounce된 Observable 에 이벤트가 발생하지 않는다.
    func debounce() {
        Observable<Int>.interval(0.6, scheduler: MainScheduler.instance).take(3, scheduler: MainScheduler.instance)
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // 지정한 시간 내에 발생한 최초 이벤트 및 가장 최신의 이벤트를 발생시킨다.
    func throttle() {
        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).take(20)
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // 이전 이벤트와 비교해서 값이 다를 경우에만 이벤트를 방출한다.
    func distinct() {
        let array = ["가", "나", "가", "가", "가", "바", "나", "나", "나", "다", "나", "나"]
        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).take(array.count)
            .enumerated().map({ array[$0.index] })
            .throttle(0.2, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // 지정한 index의 이벤트만 발생시킨다.
    func elementAt() {
        Observable.of(1, 2, 3, 3, 7, 10, 1).elementAt(4)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // 첫번째 이벤트만 발생시킨다.
    func single() {
        Observable.of(1, 2, 3, 3, 7, 10, 1).single()
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // sampler observable의 이벤트에 따라 본래 observable의 이벤트가 전달된다. 전달할 이벤트가 없을때는 무시한다.
    func sample() {
        Observable<Int>.interval(0.1, scheduler: MainScheduler.instance).take(10)
            .sample(Observable<Int>.interval(0.5, scheduler: MainScheduler.instance))
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // 이벤트를 스킵한다.
    func skip() {
        Observable.of(1,2,3,4,5,6)
            .skip(5)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
        
        Observable.of(1,2,3,4,5,6)
            .skipWhile { $0 != 5 }
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // 모든 이벤트를 무시한다
    func ignoreElements() {
        Observable.of(1,2,3,4,5)
            .ignoreElements()
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
