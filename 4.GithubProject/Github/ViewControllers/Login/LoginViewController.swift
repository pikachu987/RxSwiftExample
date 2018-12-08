//
//  LoginViewController.swift
//  Github
//
//  Created by Gwanho Kim on 04/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxKeyboard

// LoginViewController
final class LoginViewController: BaseViewController {
    private let viewModel = LoginViewModel()
    
    private var cancelBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return barButtonItem
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = TouchesScrollView()
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints({ (make) in
            make.leading.trailing.top.equalToSuperview()
        })
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        self.scrollView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().priority(1)
        })
        return view
    }()
    
    private lazy var idTextFieldView: TextFieldView = {
       let textFieldView = TextFieldView("input id")
        self.containerView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.pwdTextFieldView.snp.top).inset(-10)
        })
        return textFieldView
    }()
    
    private lazy var pwdTextFieldView: TextFieldView = {
        let textFieldView = TextFieldView("input password")
        self.containerView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview().inset(-20)
        })
        return textFieldView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        self.view.addSubview(button)
        button.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualTo(self.view.safeArea.bottom)
            make.top.equalTo(self.scrollView.snp.bottom)
            make.height.equalTo(54)
        })
        let bottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: button, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.priority = UILayoutPriority(950)
        self.view.addConstraint(bottomConstraint)
        self.bottomConstraint = bottomConstraint
        return button
    }()
    
    private var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupBindings()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.idTextFieldView.resignFirstResponder()
        self.pwdTextFieldView.resignFirstResponder()
    }
    
    private func setupUI() {
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.idTextFieldView.textField.returnKeyType = .next
        self.pwdTextFieldView.textField.returnKeyType = .done
        self.pwdTextFieldView.textField.isSecureTextEntry = true
        self.loginButton.backgroundColor = .black
        self.loginButton.setTitle("Login", for: .normal)
        self.loginButton.setTitleColor(.white, for: .normal)
    }
    
    private func setupBindings() {
        
        self.cancelBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                self?.bottomConstraint?.constant = keyboardVisibleHeight
                UIView.animate(withDuration: 0.22, animations: {
                    self?.view.layoutIfNeeded()
                })
            }).disposed(by: self.disposeBag)
        
        self.idTextFieldView.textField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.pwdTextFieldView.becomeFirstResponder()
            }).disposed(by: self.disposeBag)
    }
}
