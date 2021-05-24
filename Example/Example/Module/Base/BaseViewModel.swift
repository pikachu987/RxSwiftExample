//
//  BaseViewModel.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/24.
//

import Foundation
import RxSwift
import RxCocoa

class BaseViewModel {
    deinit {
        print("deinit: \(self)")
    }

    var disposeBag = DisposeBag()

    public init() { }
}
