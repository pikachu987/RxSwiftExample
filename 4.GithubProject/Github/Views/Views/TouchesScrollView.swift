//
//  TouchesScrollView.swift
//  Github
//
//  Created by Gwanho Kim on 08/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

class TouchesScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.touchesBegan(touches, with: event)
    }
}
