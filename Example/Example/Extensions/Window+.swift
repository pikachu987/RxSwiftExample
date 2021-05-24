//
//  Window+.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/24.
//

import UIKit

extension UIWindow {
    static var first: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first
        } else {
            if let window = UIApplication.shared.keyWindow {
                return window
            } else {
                return UIApplication.shared.windows.first
            }
        }
    }

    static var statusBarFrame: CGRect {
        if #available(iOS 13.0, *) {
            return self.first?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        } else {
            return UIApplication.shared.statusBarFrame
        }
    }

    static var currentViewController: UIViewController? {
        return self.currentViewController(viewController: self.first?.rootViewController)
    }

    private static func currentViewController(viewController: UIViewController?) -> UIViewController? {
        if let viewController = viewController as? UINavigationController {
            if let currentVC = viewController.visibleViewController {
                return self.currentViewController(viewController: currentVC)
            } else {
                return viewController
            }
        } else if let viewController = viewController as? UITabBarController {
            if let currentVC = viewController.selectedViewController {
                return self.currentViewController(viewController: currentVC)
            } else {
                return viewController
            }
        } else {
            if let currentVC = viewController?.presentedViewController {
                return self.currentViewController(viewController: currentVC)
            } else {
                return viewController
            }
        }
    }
}
