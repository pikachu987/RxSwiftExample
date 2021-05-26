//
//  BaseViewController.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    deinit {
        print("deinit: \(self)")
    }

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLayout()
        bindingView()
        bindingViewModel()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        resign()
    }

    func setupUI() {
        
    }

    func setupLayout() {
        
    }
    
    func bindingView() {
        
    }
    
    func bindingViewModel() {
        
    }
    
    @objc func resign() {}
}

extension Reactive where Base: BaseViewController {
    var resign: ControlEvent<Void> {
        let events = methodInvoked(#selector(BaseViewController.resign)).map { _ in }
        return ControlEvent(events: events)
    }
}

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let events = methodInvoked(#selector(UIViewController.viewDidLoad)).map { _ in }
        return ControlEvent(events: events)
    }

    var viewWillAppear: ControlEvent<Void> {
        let events = methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map { _ in }
        return ControlEvent(events: events)
    }
    
    var viewDidAppear: ControlEvent<Void> {
        let events = methodInvoked(#selector(UIViewController.viewDidAppear(_:))).map { _ in }
        return ControlEvent(events: events)
    }
    
    var viewWillDisappear: ControlEvent<Void> {
        let events = methodInvoked(#selector(UIViewController.viewWillDisappear(_:))).map { _ in }
        return ControlEvent(events: events)
    }
    
    var viewDidDisappear: ControlEvent<Void> {
        let events = methodInvoked(#selector(UIViewController.viewDidDisappear(_:))).map { _ in }
        return ControlEvent(events: events)
    }
}
