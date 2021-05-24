//
//  UIScrollView+Scroll.swift
//  Example
//
//  Created by corpdocfriends on 2021/05/24.
//

import UIKit
import RxSwift
import RxCocoa

extension UIScrollView {
    public var contentReverseOffset: CGPoint {
        let maximumOffsetX = contentSize.width - frame.size.width
        let maximumOffsetY = contentSize.height - frame.size.height
        let offsetX = maximumOffsetX - contentOffset.x
        let offsetY = maximumOffsetY - contentOffset.y
        return CGPoint(x: offsetX, y: offsetY)
    }
}

extension Reactive where Base: UIScrollView {
    public var contentReverseOffset: Observable<CGPoint> {
        return self.contentOffset.flatMap({_ in
            return Observable.just(base.contentReverseOffset)
        })
    }
}
