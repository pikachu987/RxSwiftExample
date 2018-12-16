//
//  TitleView.swift
//  Github
//
//  Created by Gwanho Kim on 15/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit

class TitleView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.leading.trailing.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        })
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.leading.trailing.greaterThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom)
        })
        return label
    }()
    
    init() {
        super.init(frame: CGRect(x: 40, y: 0, width: UIScreen.main.bounds.width - 80, height: 44.0))
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.titleLabel.text = ""
        self.titleLabel.textColor = .black
        self.titleLabel.lineBreakMode = .byTruncatingMiddle
        self.titleLabel.textAlignment = .center
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        self.descriptionLabel.text = ""
        self.descriptionLabel.textColor = UIColor(white: 130/255, alpha: 1)
        self.descriptionLabel.lineBreakMode = .byTruncatingMiddle
        self.descriptionLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
