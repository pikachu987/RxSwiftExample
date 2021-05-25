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

    func setupUI() {
        
    }

    func setupLayout() {
        
    }
    
    func bindingView() {
        
    }
    
    func bindingViewModel() {
        
    }
}

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let events = methodInvoked(#selector(UIViewController.viewDidLoad)).map({ _ -> Void in
            return ()
        })
        return ControlEvent(events: events)
    }

    var viewWillAppear: ControlEvent<Bool> {
        return ControlEvent(events: methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map { $0.first as? Bool ?? false })
    }
    
    var viewDidAppear: ControlEvent<Bool> {
        return ControlEvent(events: methodInvoked(#selector(UIViewController.viewDidAppear(_:))).map { $0.first as? Bool ?? false })
    }
    
    var viewWillDisappear: ControlEvent<Bool> {
        return ControlEvent(events: methodInvoked(#selector(UIViewController.viewWillDisappear(_:))).map { $0.first as? Bool ?? false })
    }
    
    var viewDidDisappear: ControlEvent<Bool> {
        return ControlEvent(events: methodInvoked(#selector(UIViewController.viewDidDisappear(_:))).map { $0.first as? Bool ?? false })
    }
}
