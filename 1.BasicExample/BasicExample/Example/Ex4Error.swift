import UIKit
import RxCocoa
import RxSwift

class Ex4Error: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.catchError()
//        self.catchErrorJustReturn()
//        self.retry()
//        self.retryWhen()
//        self.timeout()
    }
    
    // 에러가 발생되었을때 onError로 종료되지 않고 이벤트를 발생하고 onComplete 될수 있게 한다.
    func catchError() {
        Observable<String>.create{ observer in
            for count in 1...3 {
                observer.onNext("\(count)")
            }
            observer.onError(NSError(domain: "error!", code: 404, userInfo: nil))
            return Disposables.create {
                print("dispose!")
            }
        }.catchError { (error) -> Observable<String> in
            return Observable.of("close1", "close2")
        }.subscribe({ print($0) })
        .disposed(by: self.disposeBag)
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
    func catchErrorJustReturn() {
        Observable<String>.create{ observer in
            [1, 2, 3].forEach({ observer.on(.next("\($0)")) })
            observer.on(.error(NSError(domain: "error!", code: 404, userInfo: nil)))
            return Disposables.create {
                print("dispose!")
            }
        }.catchErrorJustReturn("End")
        .subscribe({ print($0) })
        .disposed(by: self.disposeBag)
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
    func retry() {
        var isFirst = true
        Observable<String>.create { observer in
            observer.onNext("1")
            observer.onNext("2")
            if isFirst {
                observer.onError(NSError(domain: "Error!", code: 404, userInfo: nil))
            } else {
                observer.on(.completed)
            }
            isFirst = false
            return Disposables.create()
        }.retry(2)
        .subscribe({ print($0) })
        .disposed(by: self.disposeBag)
        /*
         next(1)
         next(2)
         next(1)
         next(2)
         completed
         */
    }
    
    // retry 하는 시점을 지정할수 있다. 재시도는 한번만 수행한다.
    func retryWhen() {
        Observable<String>.create { observer in
            observer.on(.next("1"))
            observer.on(.next("2"))
            observer.onError(NSError(domain: "Error!", code: 404, userInfo: nil))
            return Disposables.create()
            }.retryWhen { (_) -> Observable<Int> in
                return Observable<Int>.timer(3, scheduler: MainScheduler.asyncInstance)
            }.subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        /*
         next(1)
         next(2)
         
         next(1)
         next(2)
         completed
         */
    }
    
    // 이벤트가 일정시간동안 발생하지 않으면 오류를 발생시킨다.
    func timeout() {
        Observable<Int>.create { observer in
            let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer.schedule(deadline: .now() + 1, repeating: 1)
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
        }.timeout(2, scheduler: MainScheduler.instance)
            .do(onNext: { value in
                print("onNext: \(value)")
            }, onError: { (error) in
                print("error: \(error)")
            })
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        /*
         next(0)
         next(1)
         next(2)
         error(Sequence timeout.)
         */
    }
    
}
