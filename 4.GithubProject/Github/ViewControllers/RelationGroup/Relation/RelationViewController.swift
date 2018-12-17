//
//  RelationViewController.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class RelationViewController: BaseViewController {
    private let viewModel = RelationViewModel()
    
    private lazy var buttonGroupContainerView: UIView = {
        let view = UIView()
        self.view.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        })
        return view
    }()
    
    private lazy var starsButton: UIButton = {
        let button = UIButton(type: .system)
        self.buttonGroupContainerView.addSubview(button)
        button.snp.makeConstraints({ (make) in
            make.leading.top.equalToSuperview()
            make.bottom.equalTo(self.buttonGroupBGLineView.snp.top)
        })
        return button
    }()
    
    private lazy var followersButton: UIButton = {
        let button = UIButton(type: .system)
        self.buttonGroupContainerView.addSubview(button)
        button.snp.makeConstraints({ (make) in
            make.top.equalToSuperview()
            make.leading.equalTo(self.starsButton.snp.trailing)
            make.bottom.equalTo(self.buttonGroupBGLineView.snp.top)
            make.width.equalTo(self.starsButton.snp.width)
            make.height.equalTo(self.starsButton.snp.height)
        })
        return button
    }()
    
    private lazy var followingButton: UIButton = {
        let button = UIButton(type: .system)
        self.buttonGroupContainerView.addSubview(button)
        button.snp.makeConstraints({ (make) in
            make.top.trailing.equalToSuperview()
            make.leading.equalTo(self.followersButton.snp.trailing)
            make.bottom.equalTo(self.buttonGroupBGLineView.snp.top)
            make.width.equalTo(self.starsButton.snp.width)
            make.height.equalTo(self.starsButton.snp.height)
        })
        return button
    }()
    
    private lazy var buttonGroupBGLineView: UIView = {
        let view = UIView()
        self.buttonGroupContainerView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(2)
        })
        return view
    }()
    
    private lazy var buttonGroupLineView: UIView = {
        let view = UIView()
        self.buttonGroupContainerView.insertSubview(view, aboveSubview: self.buttonGroupBGLineView)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
            make.width.equalTo(UIScreen.main.bounds.width/3)
        })
        let lineViewStarConstraint = NSLayoutConstraint(item: self.starsButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        lineViewStarConstraint.priority = UILayoutPriority(750)
        self.buttonGroupContainerView.addConstraint(lineViewStarConstraint)
        self.lineViewStarConstraint = lineViewStarConstraint
        
        let lineViewFollowersConstraint = NSLayoutConstraint(item: self.followersButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        lineViewFollowersConstraint.priority = UILayoutPriority(250)
        self.buttonGroupContainerView.addConstraint(lineViewFollowersConstraint)
        self.lineViewFollowersConstraint = lineViewFollowersConstraint
        
        let lineViewFollowingConstraint = NSLayoutConstraint(item: self.followingButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        lineViewFollowingConstraint.priority = UILayoutPriority(250)
        self.buttonGroupContainerView.addConstraint(lineViewFollowingConstraint)
        self.lineViewFollowingConstraint = lineViewFollowingConstraint
        return view
    }()
    
    private var lineViewStarConstraint: NSLayoutConstraint?
    private var lineViewFollowersConstraint: NSLayoutConstraint?
    private var lineViewFollowingConstraint: NSLayoutConstraint?
    
    private var lineViewIndex: Int = 0 {
        willSet {
            if newValue == 0 {
                self.title = "Stars"
                self.lineViewStarConstraint?.priority = UILayoutPriority(750)
                self.lineViewFollowersConstraint?.priority = UILayoutPriority(250)
                self.lineViewFollowingConstraint?.priority = UILayoutPriority(250)
                self.starsButton.setTitleColor(UIColor.black, for: .normal)
                self.followersButton.setTitleColor(UIColor(white: 170/255, alpha: 1), for: .normal)
                self.followingButton.setTitleColor(UIColor(white: 170/255, alpha: 1), for: .normal)
            } else if newValue == 1 {
                self.title = "Followers"
                self.lineViewStarConstraint?.priority = UILayoutPriority(250)
                self.lineViewFollowersConstraint?.priority = UILayoutPriority(750)
                self.lineViewFollowingConstraint?.priority = UILayoutPriority(250)
                self.starsButton.setTitleColor(UIColor(white: 170/255, alpha: 1), for: .normal)
                self.followersButton.setTitleColor(UIColor.black, for: .normal)
                self.followingButton.setTitleColor(UIColor(white: 170/255, alpha: 1), for: .normal)
            } else if newValue == 2 {
                self.title = "Following"
                self.lineViewStarConstraint?.priority = UILayoutPriority(250)
                self.lineViewFollowersConstraint?.priority = UILayoutPriority(250)
                self.lineViewFollowingConstraint?.priority = UILayoutPriority(750)
                self.starsButton.setTitleColor(UIColor(white: 170/255, alpha: 1), for: .normal)
                self.followersButton.setTitleColor(UIColor(white: 170/255, alpha: 1), for: .normal)
                self.followingButton.setTitleColor(UIColor.black, for: .normal)
            }
            UIView.animate(withDuration: 0.3) {
                self.buttonGroupContainerView.layoutIfNeeded()
            }
        }
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(self.buttonGroupContainerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeArea.bottom)
        }
        return view
    }()
    
    private lazy var pageViewController: PageViewController = {
        let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.addChild(pageViewController)
        self.containerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return pageViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.starsButton.setTitle("Stars", for: .normal)
        self.starsButton.setTitleColor(.black, for: .normal)
        self.followersButton.setTitle("Followers", for: .normal)
        self.followersButton.setTitleColor(.black, for: .normal)
        self.followingButton.setTitle("Following", for: .normal)
        self.followingButton.setTitleColor(.black, for: .normal)
        self.buttonGroupBGLineView.backgroundColor = UIColor(white: 210/255, alpha: 1)
        self.buttonGroupLineView.backgroundColor = .black
        let starsViewController = StarsViewController()
        let followersViewController = FollowersViewController()
        let followingViewController = FollowingViewController()
        self.pageViewController.setDataSource()
        self.pageViewController.initView([starsViewController,
                                          followersViewController,
                                          followingViewController])
        self.lineViewIndex = 0
    }
    
    private func setupBindings() {
        ProfileHelper.shared.ifExistsProfileLoad()
        
        self.starsButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.pageViewController.scrollToViewController(0)
            }).disposed(by: self.disposeBag)
        
        self.followersButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.pageViewController.scrollToViewController(1)
            }).disposed(by: self.disposeBag)
        
        self.followingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.pageViewController.scrollToViewController(2)
            }).disposed(by: self.disposeBag)
        
        self.pageViewController.rx_delegate.pageIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.lineViewIndex = index
            }).disposed(by: self.disposeBag)
        
        self.pageViewController.rx_delegate.buttonEnabled
            .subscribe(onNext: { [weak self] isEnabled in
                self?.buttonGroupBGLineView
                    .subviews
                    .compactMap({ $0 as? UIButton })
                    .forEach({ $0.isUserInteractionEnabled = isEnabled })
            }).disposed(by: self.disposeBag)
    }
}


// PageViewController Delegate Proxy
class RxPageViewControllerDelegateProxy: DelegateProxy<PageViewController, PageViewControllerDelegate>, DelegateProxyType, PageViewControllerDelegate  {
    let pageIndex = PublishSubject<Int>()
    let buttonEnabled = PublishSubject<Bool>()
    
    static func currentDelegate(for object: PageViewController) -> PageViewControllerDelegate? {
        return object.pageViewDelegate
    }
    
    static func setCurrentDelegate(_ delegate: PageViewControllerDelegate?, to object: PageViewController) {
        object.pageViewDelegate = delegate
    }
    
    static func registerKnownImplementations() {
        self.register { RxPageViewControllerDelegateProxy(parentObject: $0, delegateProxy: RxPageViewControllerDelegateProxy.self) }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, index: Int) {
        self.pageIndex.onNext(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, isEnabled: Bool) {
        self.buttonEnabled.onNext(isEnabled)
    }
}

extension PageViewController {
    var rx_delegate: RxPageViewControllerDelegateProxy {
        return RxPageViewControllerDelegateProxy.proxy(for: self)
    }
}
