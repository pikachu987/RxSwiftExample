import UIKit
import RxCocoa
import RxSwift

class Ex7Utility: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.doOn()
//        self.observeOn()
//        self.subscribeOn()
//        self.materialize()
//        self.using()
    }
    
    // Observable의 이벤트가 발생할때 이벤트 핸들러
    // subscribe시점이 아닌 이벤트 발생시점
    func doOn() {
        Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .take(10)
            .do(onNext: {event in
                print("do: \(event)")
            })
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
    }
    
    // ObserveOn 이 호출된 다음 메서드가 수행될 스케쥴러를 지정할수 있다.
    func observeOn() {
        Observable<Int>.interval(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            .take(10)
            .observe(on: MainScheduler.instance)
            .do(onNext: { print("do: \(Thread.isMainThread), \($0)") })
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe { print("subscribe: \(Thread.isMainThread), \($0)") }
            .disposed(by: self.disposeBag)
    }
    
    // Observable이 수행될 스케쥴러를 지정한다. create 블럭 안에서의 스케쥴러를 지정할수 있다.
    func subscribeOn() {
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
        
        /*
        .asDriver(onErrorJustReturn: "-1")
        .asObservable()
         는
         .observeOn(MainScheduler.instance)
         .catchErrorJustReturn("-1")
         .shareReplayLatesWhileConnected()
         와 동일하다.
         */
    }
    
    // materialize: 이벤트가 전달될때 어떤 이벤트인지도 같이 전달된다.
    // dematerialize: materialize된 이벤트를 다시 일반 이벤트발생형태로 변경한다.
    func materialize() {
        Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).take(4)
            .materialize()
            .dematerialize()
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
    // Observable과 동일한 수명을 가진 일회용 리소스를 만듭니다.
    func using() {
        class ResourceDisposable: Disposable {
            func dispose() {
                print("dispose!")
            }
        }
        Observable.using({ () -> ResourceDisposable in
            return ResourceDisposable()
        }) { disposable in
            return Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
        }.take(3)
            .subscribe { print($0) }
            .disposed(by: self.disposeBag)
    }
    
}
