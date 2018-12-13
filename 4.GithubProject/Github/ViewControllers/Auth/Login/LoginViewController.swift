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
    private var viewModel = LoginViewModel()
    
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
    
    private lazy var idTextFieldView: ValidateTextFieldView = {
       let textFieldView = ValidateTextFieldView("input id")
        self.containerView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(self.passwordTextFieldView.snp.top).inset(-10)
        })
        return textFieldView
    }()
    
    private lazy var passwordTextFieldView: ValidateTextFieldView = {
        let textFieldView = ValidateTextFieldView("input password")
        self.containerView.addSubview(textFieldView)
        textFieldView.snp.makeConstraints({ (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview().inset(-20)
        })
        return textFieldView
    }()
    
    private lazy var loginButton: IndicatorButton = {
        let button = IndicatorButton(type: .system)
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
        self.passwordTextFieldView.resignFirstResponder()
    }
    
    private func setupUI() {
        self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem
        self.idTextFieldView.textField.returnKeyType = .next
        self.passwordTextFieldView.textField.returnKeyType = .done
        self.passwordTextFieldView.textField.isSecureTextEntry = true
        self.loginButton.isEnabled = false
        self.loginButton.backgroundColor = UIColor(white: 188/255, alpha: 1)
        self.loginButton.setTitle("Login", for: .normal)
        self.loginButton.setTitleColor(.white, for: .normal)
    }
    
    private func setupBindings() {
        
        self.cancelBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.idTextFieldView.resignFirstResponder()
                self?.passwordTextFieldView.resignFirstResponder()
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: self.disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self,
                 let bottomConstraint = self.bottomConstraint else { return }
                if bottomConstraint.constant != keyboardVisibleHeight {
                    self.bottomConstraint?.constant = keyboardVisibleHeight
                    UIView.animate(withDuration: 0.22, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.disposeBag)
        
        self.idTextFieldView.textField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.passwordTextFieldView.becomeFirstResponder()
            }).disposed(by: self.disposeBag)
        
        self.passwordTextFieldView.textField.rx.controlEvent(.editingDidEndOnExit)
            .filter{ [unowned self] in
                !self.loginButton.isShowIndicator
            }
            .bind(to: self.viewModel.inputs.loginTap)
            .disposed(by: self.disposeBag)
        
        self.idTextFieldView.textField.rx.text
            .bind(to: self.viewModel.inputs.id)
            .disposed(by: self.disposeBag)
        
        self.passwordTextFieldView.textField.rx.text
            .bind(to: self.viewModel.inputs.password)
            .disposed(by: self.disposeBag)
        
        self.loginButton.rx.tap
            .filter{ [unowned self] in
                !self.loginButton.isShowIndicator
            }
            .bind(to: self.viewModel.inputs.loginTap)
            .disposed(by: self.disposeBag)
        
        self.viewModel.outpust.enabledLogin.drive(onNext: { [weak self] isEnabled in
            self?.loginButton.isEnabled = isEnabled
            self?.loginButton.backgroundColor = isEnabled ? .black : UIColor(white: 188/255, alpha: 1)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.validatedId
            .drive(onNext: { [weak self] result in
                self?.idTextFieldView.isValidate = result
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.validatedPassword
            .drive(onNext: { [weak self] result in
                self?.passwordTextFieldView.isValidate = result
            }).disposed(by: self.disposeBag)
        
        self.viewModel.outpust.isLoading
            .drive(self.loginButton.loading(color: .white))
            .disposed(by: self.disposeBag)
        
        self.viewModel.outpust.login
            .drive(onNext: { [weak self] isLogin in
                if isLogin {
                    let tabBarController = TabBarController()
                    AppDelegate.shared?.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    AppDelegate.shared?.window?.rootViewController = tabBarController
                    AppDelegate.shared?.window?.makeKeyAndVisible()
                } else {
                    let alertController = UIAlertController(title: "Error", message: "Login Error", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                }
            }).disposed(by: self.disposeBag)
    }
}
