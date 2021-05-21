//
//  Reactive+LifeCycle.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/19.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewWillAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillAppear(_:)))
    }
    
    var viewDidAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidAppear(_:)))
    }
    
    var viewWillDisappear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
    }
    
    var viewDidDisappear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
    }
}
