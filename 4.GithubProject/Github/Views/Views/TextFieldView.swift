//
//  TextFieldView.swift
//  Github
//
//  Created by Gwanho Kim on 08/12/2018.
//  Copyright © 2018 Gwanho Kim. All rights reserved.
//

import UIKit
import RxSwift

class ValidateTextFieldView: UIView {
    
    private lazy var _textField: UITextField = {
        let textField = UITextField()
        self.addSubview(textField)
        textField.snp.makeConstraints({ (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(self.bottomLine.snp.top)
            make.height.equalTo(44).priority(950)
        })
        return textField
    }()
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        self.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        })
        return view
    }()
    
    var textField: UITextField {
        return self._textField
    }
    
    var isValidate: ValidationResult = .empty {
        willSet {
            if newValue == .empty {
                self.bottomLine.backgroundColor = UIColor(white: 224/255, alpha: 1)
            } else if newValue == .success(message: "") {
                self.bottomLine.backgroundColor = .black
            } else if newValue == .failed(message: "") {
                self.bottomLine.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 94/255, alpha: 1)
            } else if newValue == .validateFailed {
                self.bottomLine.backgroundColor = UIColor(red: 255/255, green: 94/255, blue: 94/255, alpha: 1)
            }
        }
    }
    
    init(_ placeholder: String) {
        super.init(frame: .zero)
        
        self.textField.placeholder = placeholder
        self.bottomLine.backgroundColor = UIColor(white: 224/255, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let value = super.resignFirstResponder()
        self.textField.resignFirstResponder()
        return value
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let value = super.becomeFirstResponder()
        self.textField.becomeFirstResponder()
        return value
    }
}
