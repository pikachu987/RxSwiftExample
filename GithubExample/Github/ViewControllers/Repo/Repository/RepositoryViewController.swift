//
//  RepositoryViewController.swift
//  Github
//
//  Created by Gwanho Kim on 27/11/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import WebKit
import RxWebKit

final class RepositoryViewController: BaseViewController {
    let viewModel: RepositoryViewModel
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        self.view.addSubview(webView)
        webView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeArea.top)
            make.height.equalTo(3)
        })
        return progressView
    }()
    
    private var titleView = TitleView()
    
    init(viewModel: RepositoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    private func setupUI() {
        self.navigationItem.titleView = self.titleView
        if let urlPath = self.viewModel.outpust.repository.htmlUrl,
            let url = URL(string: urlPath) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            if let token = UserDefaults.token {
                request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
            }
            self.webView.load(request)
        }
        self.progressView.alpha = 0
    }
    
    private func setupBindings() {
        self.webView.rx.title
            .subscribe(onNext: { [weak self] title in
                self?.titleView.titleLabel.text = title
            }).disposed(by: self.disposeBag)
        
        self.webView.rx.url
            .subscribe(onNext: { [weak self] url in
                self?.titleView.descriptionLabel.text = url?.absoluteString
            }).disposed(by: self.disposeBag)
        
        self.webView.rx.estimatedProgress
            .subscribe(onNext: { [weak self] progress in
                guard let self = self else { return }
                self.progressView.progress = Float(progress)
                if progress == 1 && self.progressView.alpha == 1 {
                    self.view.loading(isLoading: false, style: .whiteLarge, color: .black)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.progressView.alpha = 0
                    })
                } else if progress >= 0 && self.progressView.alpha == 0 {
                    self.view.loading(isLoading: true, style: .whiteLarge, color: .black)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.progressView.alpha = 1
                    })
                }
            }).disposed(by: self.disposeBag)
    }
}
