//
//  GithubTrendingViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation












//final class ViewController: UIViewController {
//    // button Example
//    @IBOutlet private weak var button: UIButton!
//
//    var trackedSectionViewModel = BehaviorRelay(value: [TrackedModelType]())
//    var sectionViewModels: Driver<[TrackedModelType]> {
//        get {
//            return trackedSectionViewModel.asDriver().map { $0 }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//
//        let customView: CustomView = CustomView(frame: CGRect(x: 0, y: 500, width: 300, height: 60))
//        customView.rx.customTest.subscribe { event in
//            print("customTest delegate: \(event)")
//        }.disposed(by: self.disposeBag)
//
//        customView.test()
//        customView.test()
//        customView.test()
//
//        let customSecondView: CustomSecondView = CustomSecondView(frame: CGRect(x: 0, y: 500, width: 300, height: 60))
//        customSecondView.rx.customTest.subscribe { event in
//            print("customSecondView delegate: \(event)")
//        }.disposed(by: self.disposeBag)
//
//        customSecondView.test()
//        customSecondView.test()
//        customSecondView.test()
//
//        self.rx.viewWillAppear
//            .subscribe({ event in
//                print("viewWillAppear!!")
//            })
//            .disposed(by: self.disposeBag)
//
//        let textField = UITextField(frame: CGRect(x: 0, y: 400, width: 300, height: 60))
//        textField.borderStyle = .roundedRect
//        self.view.addSubview(textField)
//
//        textField.rx.text
//            .distinctUntilChanged()
//            .subscribe { event in
//                print(event)
//            }.disposed(by: self.disposeBag)
//    }
//}
//

//
//// objc optional
//
//@objc protocol CustomDelegate: AnyObject {
//    @objc optional func customTest(_ view: CustomView, value: String)
//}
//
//class CustomView: UIView {
//    deinit {
//        print("deinit: \(self)")
//    }
//    weak var delegate: CustomDelegate?
//
//    func test() {
//        self.delegate?.customTest?(self, value: "value")
//    }
//}
//
//class CustomDelegateProxy: DelegateProxy<CustomView, CustomDelegate>, DelegateProxyType, CustomDelegate {
//    deinit {
//        print("deinit: \(self)")
//    }
//
//    static func registerKnownImplementations() {
//        self.register(make: { CustomDelegateProxy(parentObject: $0, delegateProxy: self) })
//    }
//
//    static func currentDelegate(for object: CustomView) -> CustomDelegate? {
//        return object.delegate
//    }
//
//    static func setCurrentDelegate(_ delegate: CustomDelegate?, to object: CustomView) {
//        object.delegate = delegate
//    }
//}
//
//extension Reactive where Base: CustomView {
//    var delegate: DelegateProxy<CustomView, CustomDelegate> {
//        return CustomDelegateProxy.proxy(for: self.base)
//    }
//
//    var customTest: Observable<String> {
//        return delegate.methodInvoked(#selector(CustomDelegate.customTest(_:value:)))
//            .map { parameter in
//                return parameter[1] as? String ?? ""
//            }
//    }
//}
//
//// objc optional X
//
//protocol CustomSecondDelegate: AnyObject {
//    func customTest(_ view: CustomSecondView, value: String)
//}
//
//class CustomSecondView: UIView {
//    deinit {
//        print("deinit: \(self)")
//    }
//    weak var delegate: CustomSecondDelegate?
//
//    func test() {
//        self.delegate?.customTest(self, value: "value")
//    }
//}
//
//class CustomSecondDelegateProxy: DelegateProxy<CustomSecondView, CustomSecondDelegate>, DelegateProxyType, CustomSecondDelegate {
//    deinit {
//        print("deinit: \(self)")
//        self.customTestSubject.onCompleted()
//    }
//
//    lazy var customTestSubject = PublishSubject<String>()
//
//    func customTest(_ view: CustomSecondView, value: String) {
//        self.customTestSubject.onNext(value)
//    }
//
//    static func registerKnownImplementations() {
//        self.register(make: { CustomSecondDelegateProxy(parentObject: $0, delegateProxy: self) })
//    }
//
//    static func currentDelegate(for object: CustomSecondView) -> CustomSecondDelegate? {
//        return object.delegate
//    }
//
//    static func setCurrentDelegate(_ delegate: CustomSecondDelegate?, to object: CustomSecondView) {
//        object.delegate = delegate
//    }
//}
//
//extension Reactive where Base: CustomSecondView {
//    var delegate: CustomSecondDelegateProxy {
//        return CustomSecondDelegateProxy.proxy(for: self.base)
//    }
//
//    var customTest: Observable<String> {
//        return self.delegate.customTestSubject.asObserver()
//    }
//}
