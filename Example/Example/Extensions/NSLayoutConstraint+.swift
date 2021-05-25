//
//  NSLayoutConstraint+.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/25.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func priority(_ value: CGFloat) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(rawValue: Float(value))
        return self
    }
    
    @discardableResult
    func identifier(_ value: String) -> NSLayoutConstraint {
        self.identifier = value
        return self
    }
}
