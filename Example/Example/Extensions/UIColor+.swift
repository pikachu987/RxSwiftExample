//
//  UIColor+.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/24.
//

import UIKit

extension UIColor {
    convenience init(light: CGFloat, dark: CGFloat) {
        self.init(light: UIColor(white: light, alpha: 1), dark: UIColor(white: dark, alpha: 1))
    }

    convenience init(light: CGFloat, dark: UIColor) {
        self.init(light: UIColor(white: light, alpha: 1), dark: dark)
    }

    convenience init(light: UIColor, dark: CGFloat) {
        self.init(light: light, dark: UIColor(white: dark, alpha: 1))
    }

    convenience init(light: UIColor, dark: UIColor) {
        if #available(iOS 13.0, *) {
            self.init(dynamicProvider: { (collection) -> UIColor in
                return collection.userInterfaceStyle == .light ? light : dark
            })
        } else {
            self.init(cgColor: light.cgColor)
        }
    }
}
