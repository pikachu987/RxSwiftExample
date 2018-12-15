//
//  ProfileViewController.swift
//  Github
//
//  Created by Gwanho Kim on 13/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import Kingfisher

final class ProfileViewController: BaseViewController {
    private let viewModel = ProfileViewModel()
    
    private var logoutBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.safeArea.top).inset(40)
            make.leading.equalToSuperview().inset(30)
            make.size.equalTo(90)
        })
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.centerX.equalTo(self.profileImageView.snp.centerX).priority(900)
            make.leading.greaterThanOrEqualToSuperview()
            make.top.equalTo(self.profileImageView.snp.bottom).inset(-5)
        })
        return label
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.profileImageView.snp.trailing).inset(-10)
            make.centerY.equalTo(self.profileImageView.snp.centerY).inset(-10)
        })
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        self.view.addSubview(label)
        label.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.profileImageView.snp.trailing).inset(-10)
            make.centerY.equalTo(self.profileImageView.snp.centerY).inset(10)
        })
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.title = "Profile"
        self.navigationItem.rightBarButtonItem = self.logoutBarButtonItem
        self.profileImageView.contentMode = .scaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.cornerRadius = 45
        self.profileImageView.backgroundColor = UIColor(white: 200/255, alpha: 1)
        self.profileImageView.kf.indicatorType = .activity
        (self.profileImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = .black
        self.nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        self.nameLabel.numberOfLines = 0
        self.idLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.emailLabel.font = UIFont.systemFont(ofSize: 15)
        self.emailLabel.numberOfLines = 0
    }
    
    private func setupBindings() {
        self.viewModel.inputs.loadProfileTrigger.onNext(())
        
        self.logoutBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                let alertController = UIAlertController(title: "Logout", message: "Do you logout?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    UserDefaults.standard.removeObject(forKey: "AuthorizationsToken")
                    UserDefaults.standard.synchronize()
                    let viewController = TrendingViewController()
                    let navigationController = UINavigationController(rootViewController: viewController)
                    AppDelegate.shared?.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    AppDelegate.shared?.window?.rootViewController = navigationController
                    AppDelegate.shared?.window?.makeKeyAndVisible()
                }))
                self?.present(alertController, animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.isLoading
            .asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                self?.view.loading(isLoading: isLoading, style: .whiteLarge, color: .black)
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.profile
            .subscribe(onNext: { [weak self] user in
                if let avatarUrl = user?.avatarUrl, let url = URL(string: avatarUrl) {
                    self?.profileImageView.kf.setImage(with: url)
                }
                self?.nameLabel.text = user?.name
                self?.idLabel.text = "Id: ".appending(user?.login ?? "")
                self?.emailLabel.text = "Email: ".appending(user?.email ?? "")
            }).disposed(by: self.disposeBag)
    }
}
