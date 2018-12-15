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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        let containerView = UIView()
        self.view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeArea.bottom)
        }
        let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        let vc1 = UIViewController()
        vc1.view.backgroundColor = .blue
        let vc2 = UIViewController()
        vc2.view.backgroundColor = .black
        
        pageViewController.setDataSource()
        pageViewController.initView([vc1, vc2])
    }
    
    private func setupBindings() {
        ProfileHelper.shared.profile
            .subscribe(onNext: { [weak self] user in
                
            }).disposed(by: self.disposeBag)
        
        ProfileHelper.shared.ifExistsProfileLoad()
    }
}


// PageViewController Delegate Proxy
class RxPageViewControllerDelegateProxy: DelegateProxy<PageViewController, PageViewControllerDelegate>, DelegateProxyType, PageViewControllerDelegate  {
    let pageIndex = PublishSubject<Int>()
    
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
}
