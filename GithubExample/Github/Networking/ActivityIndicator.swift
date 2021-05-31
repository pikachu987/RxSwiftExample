//
//  ActivityIndicator.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import RxCocoa

extension UIView {
    private func addIndicator(_ style: UIActivityIndicatorView.Style, color: UIColor) {
        var view = self.viewWithTag(987) as? UIActivityIndicatorView
        if view == nil {
            let activityIndicatorView = UIActivityIndicatorView()
            activityIndicatorView.tag = 987
            self.addSubview(activityIndicatorView)
            activityIndicatorView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            view = activityIndicatorView
        }
        view?.style = style
        view?.color = color
        view?.hidesWhenStopped = true
        view?.startAnimating()
    }
    
    private func removeIndicator() {
        (self.viewWithTag(987) as? UIActivityIndicatorView)?.stopAnimating()
        self.viewWithTag(987)?.removeFromSuperview()
    }
    
    final func loading(_ style: UIActivityIndicatorView.Style = .gray, color: UIColor = .black) -> AnyObserver<Bool> {
        return Binder(self, binding: { (target, isLoading) in
            if let indicatorButton = self as? IndicatorButton {
                if isLoading {
                    indicatorButton.showIndicator(style, color: color)
                } else {
                    indicatorButton.hideIndicator()
                }
            } else {
                if isLoading {
                    self.addIndicator(style, color: color)
                } else {
                    self.removeIndicator()
                }
            }
        }).asObserver()
    }
    
    final func loading(isLoading: Bool, style: UIActivityIndicatorView.Style = .gray, color: UIColor = .black) {
        if let indicatorButton = self as? IndicatorButton {
            if isLoading {
                indicatorButton.showIndicator(style, color: color)
            } else {
                indicatorButton.hideIndicator()
            }
        } else {
            if isLoading {
                self.addIndicator(style, color: color)
            } else {
                self.removeIndicator()
            }
        }
    }
}

private struct ActivityToken<E> : ObservableConvertibleType, Disposable {
    private let source: Observable<E>
    private let cancelable: Cancelable
    
    init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        self.source = source
        self.cancelable = Disposables.create(with: disposeAction)
    }
    
    func dispose() {
        self.cancelable.dispose()
    }
    
    func asObservable() -> Observable<E> {
        return self.source
    }
}

class ActivityIndicator : SharedSequenceConvertibleType {
    public typealias E = Bool
    public typealias SharingStrategy = DriverSharingStrategy
    
    private let lock = NSRecursiveLock()
    private let variable = Variable(0)
    private let loading: SharedSequence<SharingStrategy, Bool>
    
    public init() {
        self.loading = self.variable.asDriver()
            .map { $0 > 0 }
            .distinctUntilChanged()
    }
    
    fileprivate func trackActivityOfObservable<O: ObservableConvertibleType>(_ source: O) -> Observable<O.E> {
        return Observable.using({ () -> ActivityToken<O.E> in
            self.increment()
            return ActivityToken(source: source.asObservable(), disposeAction: self.decrement)
        }) { t in
            return t.asObservable()
        }
    }
    
    private func increment() {
        self.lock.lock()
        self.variable.value += 1
        self.lock.unlock()
    }
    
    private func decrement() {
        self.lock.lock()
        self.variable.value -= 1
        self.lock.unlock()
    }
    
    func asSharedSequence() -> SharedSequence<SharingStrategy, E> {
        return self.loading
    }
}

extension ObservableConvertibleType {
    func trackActivity(_ activityIndicator: ActivityIndicator) -> Observable<E> {
        return activityIndicator.trackActivityOfObservable(self)
    }
}


class IndicatorButton: UIButton {
    
    private var text: String?
    private var image: UIImage?
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.isHidden = true
        indicatorView.stopAnimating()
        indicatorView.color = UIColor.white
        self.addSubview(indicatorView)
        indicatorView.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        return indicatorView
    }()
    
    var isShowIndicator: Bool {
        get {
            return !self.indicatorView.isHidden
        }
    }
    
    func showIndicator(_ style: UIActivityIndicatorView.Style, color: UIColor) {
        self.indicatorView.style = style
        self.indicatorView.color = color
        if (self.currentTitle ?? "") != "" {
            self.image = self.currentImage
            self.text = self.currentTitle
            self.setImage(nil, for: .normal)
            self.setTitle("", for: .normal)
        }
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    func hideIndicator() {
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
        if let image = self.image {
            self.setImage(image, for: .normal)
        }
        if let text = self.text {
            self.setTitle(text, for: .normal)
        }
    }
}

