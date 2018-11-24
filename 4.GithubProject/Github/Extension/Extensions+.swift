//
//  Extensions+.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

extension UIScrollView {
    public var isBottomLoadNextPage: Bool {
        return (self.contentSize.height - self.frame.size.height) - self.contentOffset.y <= 0
    }
}
