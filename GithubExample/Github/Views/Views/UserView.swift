//
//  UserView.swift
//  Github
//
//  Created by Gwanho Kim on 16/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import Kingfisher

class UserView: UIView {
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(30)
            make.size.equalTo(90)
        })
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.profileImageView.snp.centerX).priority(900)
            make.leading.greaterThanOrEqualToSuperview()
            make.top.equalTo(self.profileImageView.snp.bottom).inset(-5)
            make.bottom.equalToSuperview().inset(20)
        })
        return label
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.profileImageView.snp.trailing).inset(-10)
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(self.profileImageView.snp.centerY)
        })
        return label
    }()
    
    var user: User? {
        willSet {
            guard let newValue = newValue else { return }
            if let avatarUrl = newValue.avatarUrl, let url = URL(string: avatarUrl) {
                self.profileImageView.kf.setImage(with: url)
            }
            self.nameLabel.text = newValue.name
            let attributedString = NSMutableAttributedString()
            if let login = newValue.login {
                attributedString.append(NSAttributedString(string: "Id: ".appending(login), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]))
            }
            if let email = newValue.email {
                var prefix = ""
                if newValue.login != nil {
                    prefix = "\n"
                }
                attributedString.append(NSAttributedString(string: "\(prefix)Email: ".appending(email), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)]))
            }
            self.loginLabel.attributedText = attributedString
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = 45
        self.profileImageView.backgroundColor = UIColor(white: 200/255, alpha: 1)
        self.profileImageView.kf.indicatorType = .activity
        (self.profileImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = .black
        self.nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        self.nameLabel.numberOfLines = 0
        self.loginLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.loginLabel.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
