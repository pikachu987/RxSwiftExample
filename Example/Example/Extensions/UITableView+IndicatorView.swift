//
//  UITableView+IndicatorView.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/24.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView {
    var isBottomIndicator: Binder<Bool> {
        return isBottomIndicator()
    }

    func isBottomIndicator(frame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44), color: UIColor = UIColor(light: .black, dark: .white)) -> Binder<Bool> {
        return Binder(base) { tableView, isIndicator in
            if isIndicator {
                let view = UIView(frame: frame)
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.tintColor = color
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(activityIndicatorView)
                NSLayoutConstraint.activate([
                    view.centerYAnchor.constraint(equalTo: activityIndicatorView.centerYAnchor),
                    view.centerXAnchor.constraint(equalTo: activityIndicatorView.centerXAnchor)
                ])
                tableView.tableFooterView = view
            } else {
                tableView.tableFooterView = nil
            }
        }
    }
}
