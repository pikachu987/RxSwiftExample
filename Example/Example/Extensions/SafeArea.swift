//
//  SafeArea.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/24.
//

import UIKit

// 뷰 + 세이프

// 세이프뷰
public struct SafeArea: CustomStringConvertible {
    public var header: CGFloat {
        return self.statusBarHeight + self.top
    }
    public var statusBarHeight: CGFloat = 0
    public var top: CGFloat = 0
    public var left: CGFloat = 0
    public var right: CGFloat = 0
    public var bottom: CGFloat = 0

    public var description: String {
        return "{ header: \(self.header), statusBarHeight: \(self.statusBarHeight), top: \(self.top), right: \(self.right), bottom: \(self.bottom), left: \(self.left) }"
    }
}

extension UIView {
    var safe: SafeArea {
        var safeArea = SafeArea()
        guard let window = UIWindow.first else { return safeArea }
        safeArea.left = window.safeAreaInsets.left
        safeArea.right = window.safeAreaInsets.right
        safeArea.bottom = window.safeAreaInsets.bottom
        safeArea.statusBarHeight = UIWindow.statusBarFrame.height
        safeArea.top = UIWindow.currentViewController?.navigationController?.navigationBar.frame.height ?? UINavigationController().navigationBar.frame.size.height
        return safeArea
    }
}

extension UIViewController {
    var safe: SafeArea {
        return self.view.safe
    }
}
