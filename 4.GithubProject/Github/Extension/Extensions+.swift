//
//  Extensions+.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import RxSwift
import SnapKit

extension Reactive where Base: UIScrollView {
    var loadNextBottom: Observable<Void> {
        let scrollView = self.base as UIScrollView
        return self.contentOffset.flatMap{ [weak scrollView] (contentOffset) -> Observable<Void> in
            guard let scrollView = scrollView else { return Observable.empty() }
            let isLoadNext = (scrollView.contentSize.height - scrollView.frame.size.height) - contentOffset.y <= 0
            return isLoadNext ? Observable.just(()) : Observable.empty()
        }
    }
}

extension UIView {
    var safeArea: ConstraintBasicAttributesDSL {
        #if swift(>=3.2)
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        }
        return self.snp
        #else
        return self.snp
        #endif
    }
}
