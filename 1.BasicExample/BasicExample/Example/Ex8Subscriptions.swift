import UIKit
import RxCocoa
import RxSwift

class Ex8Subscriptions: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.multicast()
//        self.publish()
//        self.replay()
//        self.share()
        
        /*
         Hot Observable 는 생성과 동시에 이벤트를 방출한다.
         subscribe되는 시점과 상관없이 옵저버들에게 이벤트를 중간부터 전송해준다.
         publish, multicast, connect
         replay, replayAll
         share, shareReplay
         sharereplaylatestWhileConnect
         
         
         Cold Observable
         옵저버가 subscribe되는 시점부터 이벤트를 생성하여 방출하기 시작한다.
         기본적으로 Hot Observable가 아닌것들은 Cold Observable이다.
         */
    }
    
    // Observable의 시컨스를 하나의 subject를 통해 multicast로 이벤트를 전달하게 된다.
    // connect 하기 전에는 시컨스가 시작되지 않는다.
    func multicast() {
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance).take(4)
        let subject = PublishSubject<Int>()
        let multicast = timer.multicast(subject)
        _ = multicast.connect()
        multicast.subscribe { event in
            print("first scription: \(event)")
        }.disposed(by: self.disposeBag)
        
        multicast.delaySubscription(2, scheduler: MainScheduler.instance)
            .subscribe { event in
                print("second scription: \(event)")
            }.disposed(by: self.disposeBag)
    }
    
    // multicase + publish subject 합쳐서 publish로 할수 있다.
    func publish() {
        let publish = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .take(4)
            .publish()
        _ = publish.connect()
        publish.subscribe { print("first: \($0)") }
            .disposed(by: self.disposeBag)
        publish.delaySubscription(1, scheduler: MainScheduler.instance)
            .subscribe{ print("second: \($0)") }
            .disposed(by: self.disposeBag)
    }
    
    // subscriptions을 공유시 지정한 버퍼 크기만큼 이벤트를 저장하고 전달해준다.
    // replayAll은 모든 이벤트를 저장한다.
    func replay() {
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance).take(5)
        let replay = timer.replay(2)
        _ = replay.connect()
        replay.subscribe { print("first: \($0)") }
            .disposed(by: self.disposeBag)
        replay.delaySubscription(4, scheduler: MainScheduler.instance)
            .subscribe { print("second: \($0)") }
            .disposed(by: self.disposeBag)
    }
    
    // 간단하게 공유를 만들수 있다. subscribe가 더 이상 없을때까지 지속되고 계속적으로 subscription을 공유할 수 있다.
    func share() {
        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance).take(5)
        let share = timer.share()
        share.subscribe { print("first: \($0)") }
            .disposed(by: self.disposeBag)
        share.delaySubscription(4, scheduler: MainScheduler.instance)
            .subscribe { print("second: \($0)") }
            .disposed(by: self.disposeBag)
    }
}
