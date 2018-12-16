//
//  FollowCell.swift
//  Github
//
//  Created by Gwanho Kim on 16/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import Kingfisher

final class FollowCell: UITableViewCell {
    static let identifier = "FollowCell"
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        self.contentView.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        })
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        self.contentView.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.profileImageView.snp.trailing).inset(-10)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        })
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.backgroundColor = UIColor(white: 170/255, alpha: 1)
        self.profileImageView.layer.cornerRadius = 22
        self.profileImageView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    var item: User? {
        willSet {
            guard let newValue = newValue else {
                self.profileImageView.image = nil
                self.nameLabel.text = nil
                return
            }
            self.profileImageView.image = nil
            if let avatalUrlPath = newValue.avatarUrl, let avatalUrl = URL(string: avatalUrlPath) {
                self.profileImageView.kf.setImage(with: avatalUrl)
            }
            self.nameLabel.text = newValue.login
        }
    }
}
