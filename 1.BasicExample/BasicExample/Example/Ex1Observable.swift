import UIKit
import RxCocoa
import RxSwift

class Ex1Observable: NSObject {
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
//        self.create()
//        self.just()
//        self.generate()
//        self.empty()
//        self.never()
//        self.error()
//        self.from()
//        self.of()
//        self.deferred()
//        self.repeatElement()
//        self.range()
    }
    
    // Observable를 만든다.
    func create() {
        func createJust<E>(element: E) -> Observable<E> {
            return Observable.create { observer in
                observer.on(.next(element))
                observer.on(.completed)
                return Disposables.create()
            }
        }
        
        createJust(element: "Observable를 만들어 봅니다.")
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)
    }
    
    // just는 단일 이벤트를 발생하는 Observable를 생성한다.
    func just() {
        Observable.just("RxSwift 빡세다 😭")
            .subscribe { (event: Event<String>) in print(event) }
            .disposed(by: self.disposeBag)
    }
    
    // 조건식과 반복문을 가진 Observable 생성 함수이다.
    func generate() {
        Observable.generate(initialState: 1, condition: { $0 < 10 }, iterate: { $0 + 4 } )
            .subscribe(onNext: { (event) in print(event) })
            .disposed(by: self.disposeBag)
    }
    
    // empty는 이벤트가 없어 종료되는 Observable 함수이다.
    func empty() {
        Observable.empty()
            .subscribe(onNext: { event in print(event) })
            .disposed(by: self.disposeBag)
    }
    
    // never는 종료되지 않는 Observable 함수이다.
    func never() {
        Observable.never()
            .subscribe(onNext: { event in print(event) })
            .disposed(by: self.disposeBag)
    }
    
    // error는 error을 리턴하며 종료되는 Observable 함수이다.
    func error() {
        Observable.error(NSError(domain: "!!Error!!", code: 404, userInfo: nil) as Error)
            .subscribe(onNext: { event in print(event) })
            .disposed(by: self.disposeBag)
    }
    
    // from은 순차적으로 이벤트를 발생한다.
    // array나 Sequence을 받아 순차적으로 이벤트를 발생시키는 Observable를 생성한다.
    func from() {
        Observable.from([1, 3, 5])
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)
        
        Observable.from([ "name": "Gwan Ho", "age": 28, "gender": "M" ])
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)
    }
    
    // Variadic을 받아 순차적으로 이벤트를 발생시키는 Observable를 생성한다.
    func of() {
        Observable.of("가", "나", "다", "라")
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)
    }
    
    // lazy initialze Observable 생성자. subscribe가 발생할때 Observable이 생성된다.
    func deferred() {
        Observable.deferred({ Observable.just("RxSwift deferred 테스트") })
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)
    }
    
    // 설장한 element를 반복적으로 이벤트를 발생한다.
    func repeatElement() {
        Observable.repeatElement("repeat test")
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)

    }
    
    // 설정한 Range내의 이벤트를 발생한다.
    func range() {
        Observable.range(start: 10, count: 3)
            .subscribe { (event) in print(event) }
            .disposed(by: self.disposeBag)
    }
}
