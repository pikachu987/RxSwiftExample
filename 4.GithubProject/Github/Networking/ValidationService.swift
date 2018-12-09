//
//  ValidationService.swift
//  Github
//
//  Created by Gwanho Kim on 09/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

enum ValidationResult {
    var isValid: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    case success(message: String)
    case empty
    case validateFailed
    case failed(message: String)
    
    static func ==(lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.validateFailed, .validateFailed):
            return true
        case let (.failed(lhsMessage), .failed(rhsMessage)):
            return lhsMessage == rhsMessage
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

class ValidationService {
    
    static func id(_ value: String) -> Observable<ValidationResult> {
        if value.isEmpty { return .just(.empty) }
        if value.count < 6 || value.count > 30 {
            return .just(.validateFailed)
        } else {
            return .just(.success(message: "Id available"))
        }
    }
    
    static func password(_ value: String) -> Observable<ValidationResult> {
        if value.isEmpty { return .just(.empty) }
        if value.count < 4 || value.count > 30 {
            return .just(.validateFailed)
        } else {
            return .just(.success(message: "Password available"))
        }
    }
}
