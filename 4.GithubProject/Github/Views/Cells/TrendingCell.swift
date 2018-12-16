//
//  TrendingCell.swift
//  Github
//
//  Created by Gwanho Kim on 25/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

final class TrendingCell: UITableViewCell {
    static let identifier = "TrendingCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: Repository? {
        willSet {
            guard let newValue = newValue else {
                self.textLabel?.text = nil
                self.detailTextLabel?.text = nil
                return
            }
            self.textLabel?.text = newValue.name
            let detail = "Star: \(newValue.starCount), Fork: \(newValue.forkCount)"
            var languageText = ""
            if let language = newValue.language {
                languageText = "Language: " + language.appending(", ")
            }
            self.detailTextLabel?.text = languageText.appending(detail)
        }
    }
}
