//
//  TrendingCell.swift
//  SomeProject
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

final class TrendingCell: UITableViewCell {
    static let identifier = "TrendingCell"
    
    var item: Repository? {
        willSet {
            self.textLabel?.text = newValue?.name
        }
    }
}
