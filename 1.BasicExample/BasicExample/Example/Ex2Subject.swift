import UIKit
import RxCocoa
import RxSwift

class Ex2Subject: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.asyncSubject()
//        self.publishSubject()
//        self.behaviorSubject()
//        self.replaySubject()
    }
    
    // AsyncSubject는 Complete 될때까지 이벤트는 발생되지 않으며, complete가 되면 마지막 이벤트를 발생하고 종료된다.
    func asyncSubject() {
        let asyncSubject = AsyncSubject<Int>()
        asyncSubject
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        
        asyncSubject.on(.next(1))
        asyncSubject.on(.next(2))
        asyncSubject.on(.next(3)) // 마지막 이벤트
        asyncSubject.on(.completed)
        // asyncSubject.on(.error(NSError(domain: "err", code: 404, userInfo: nil)))
        // 에러로 종료되면 마지막 이벤트 전달 없이 에러만 발생한다.
    }
    
    //// PublishSubject는 subscribe 된 시점 이후부터 발생한 이벤트를 전달한다. subscribe 되기 이전의 이번트는 전달하지 않는다.
    func publishSubject() {
        let publishSubject = PublishSubject<String>()
        publishSubject.onNext("publish 1")
        publishSubject
            .subscribe({ print("1_\($0)") })
            .disposed(by: self.disposeBag)
        publishSubject.onNext("publish 2")
        publishSubject.onNext("publish 3")
        publishSubject
            .subscribe({ print("2_\($0)") })
            .disposed(by: self.disposeBag)
        publishSubject.onNext("publish 4")
        publishSubject.onNext("publish 5")
    }
    
    // // BehaviorSubject는 초기값을 지닌 subject이다. subscribe가 발생하면 현재 저장된 값을 이벤트로 전달하고 마지막 이벤트값을 저장하고 있다.
    func behaviorSubject() {
        let behaviorSubject = BehaviorSubject<String>(value: "behavior init")
        behaviorSubject
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        behaviorSubject.onNext("behavior 1")
        behaviorSubject.onNext("behavior 2")
        behaviorSubject
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        behaviorSubject.onNext("behavior 3")
        behaviorSubject.onNext("behavior 4")
    }
    
    // ReplaySubject는 n개의 이벤트를 저장하고 subscribe되는 시점과 상관없이 저장된 모든 이벤트를 전달한다.
    func replaySubject() {
        let replaySubject = ReplaySubject<String>.create(bufferSize: 3) // createUnbounded() 모든 이벤트가 전달된다.
        replaySubject.onNext("replay 1")
        replaySubject.onNext("replay 2")
        replaySubject.onNext("replay 3")
        replaySubject.onNext("replay 4")
        replaySubject
            .subscribe({ print($0) })
            .disposed(by: self.disposeBag)
        replaySubject.onNext("replay 5")
        replaySubject.onNext("replay 6")
        replaySubject.onNext("replay 7")
    }
}
