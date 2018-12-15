//
//  PageViewController.swift
//  Github
//
//  Created by Gwanho Kim on 15/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

// PageViewControllerDelegate
public protocol PageViewControllerDelegate: class {
    /// pageViewController count
    func pageViewController(_ pageViewController: UIPageViewController, count: Int)
    /// pageViewController index
    func pageViewController(_ pageViewController: UIPageViewController, index: Int)
}

public extension PageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, count: Int){ }
    func pageViewController(_ pageViewController: UIPageViewController, index: Int){ }
}


// PageViewController
public class PageViewController: UIPageViewController {
    // MARK: var
    
    /// delegate
    public weak var pageViewDelegate: PageViewControllerDelegate?
    
    /// viewControllers
    public lazy var orderedViewControllers: [UIViewController] = [UIViewController]()
    
    /// isReload Infinite PageViewController
    public var isReload = false
    
    // MARK: initialize
    
    public override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    
    // MARK: func
    
    /// Left Right Swipe
    public func setDataSource(){
        self.dataSource = self
    }
    
    /// init View
    public func initView(_ viewController: [UIViewController]){
        self.orderedViewControllers = viewController
        if let initialViewController = self.orderedViewControllers.first {
            scrollToViewController(initialViewController)
        }
        self.pageViewDelegate?.pageViewController(self, count: orderedViewControllers.count)
    }
    
    
    /// scroll
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    /// scroll To Index
    public func scrollToViewController(_ index: Int, isNotify: Bool = true) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewController.NavigationDirection = index >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[index]
            scrollToViewController(nextViewController, direction: direction, isNotify: isNotify)
        }
    }
    
    /// New ViewController
    public static func newViewController(_ id: String, storyBoard: String) -> UIViewController {
        return UIStoryboard(name: storyBoard, bundle: nil).instantiateViewController(withIdentifier: "\(id)")
    }
    
    /// Scroll To ViewController
    private func scrollToViewController(_ viewController: UIViewController, direction: UIPageViewController.NavigationDirection = .forward, isNotify: Bool = true) {
        setViewControllers([viewController],direction: direction,animated: true,completion: { (finished) -> Void in
            self.notifyDelegateOfNewIndex(isNotify)
        })
    }
    
    /// Notify NewIndex
    private func notifyDelegateOfNewIndex(_ isNotify: Bool = true) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            if isNotify {
                self.pageViewDelegate?.pageViewController(self, index: index)
            }
        }
    }
    
}

// MARK: UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.notifyDelegateOfNewIndex()
    }
}

// MARK: UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        if !self.isReload{
            if previousIndex < 0{ return nil }
        }
        guard previousIndex >= 0 else { return orderedViewControllers.last }
        guard orderedViewControllers.count > previousIndex else { return nil }
        return orderedViewControllers[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        if !self.isReload{
            if nextIndex >= orderedViewControllers.count{ return nil }
        }
        guard orderedViewControllers.count != nextIndex else { return orderedViewControllers.first }
        return orderedViewControllers[nextIndex]
    }
}
