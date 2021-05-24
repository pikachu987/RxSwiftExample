//
//  BaseViewModel.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    associatedtype Dependency
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    var dependency: Dependency { get }
    var input: Input { get }
    var output: Output { get }
}
