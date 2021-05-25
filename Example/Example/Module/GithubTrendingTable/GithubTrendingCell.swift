//
//  GithubTrendingCell.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/25.
//

import UIKit
import RxSwift
import RxCocoa

@objc protocol GithubTrendingCellDelegate: AnyObject {
    @objc optional func githubTrendingOwnerTap(_ cell: GithubTrendingCell)
}

class GithubTrendingCell: UITableViewCell {
    weak var delegate: GithubTrendingCellDelegate?

    static let identifier = "GithubTrendingCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
        return label
    }()
    
    private let ownerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(light: 99/255, dark: 224/255), for: .normal)
        return button
    }()
    
    private let updateDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(light: 140/255, dark: 180/255)
        return label
    }()
    
    var repository: GithubTrendingRepository? {
        didSet {
            titleLabel.text = repository?.name
            ownerButton.setTitle(repository?.owner?.login, for: .normal)
            updateDateLabel.text = repository?.updatedRegDate
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(ownerButton)
        addSubview(updateDateLabel)
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -16),
            topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: ownerButton.leadingAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: ownerButton.topAnchor, constant: 4)
        ])
            
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: ownerButton.trailingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: updateDateLabel.topAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: updateDateLabel.trailingAnchor, constant: 16),
            bottomAnchor.constraint(equalTo: updateDateLabel.bottomAnchor, constant: 10)
        ])
        
        ownerButton.addTarget(self, action: #selector(ownerTap(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        ownerButton.setTitle(nil, for: .normal)
        updateDateLabel.text = nil
    }
    
    @objc private func ownerTap(_ sender: UIButton) {
        delegate?.githubTrendingOwnerTap?(self)
    }
}

class GithubTrendingCellDelegateProxy: DelegateProxy<GithubTrendingCell, GithubTrendingCellDelegate>, DelegateProxyType, GithubTrendingCellDelegate {
    deinit {
        print("deinit: \(self)")
    }

    static func registerKnownImplementations() {
        self.register(make: { GithubTrendingCellDelegateProxy(parentObject: $0, delegateProxy: self) })
    }

    static func currentDelegate(for object: GithubTrendingCell) -> GithubTrendingCellDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: GithubTrendingCellDelegate?, to object: GithubTrendingCell) {
        object.delegate = delegate
    }
}

extension Reactive where Base: GithubTrendingCell {
    var delegate: DelegateProxy<GithubTrendingCell, GithubTrendingCellDelegate> {
        return GithubTrendingCellDelegateProxy.proxy(for: self.base)
    }
    
    var githubTrendingOwnerTap: ControlEvent<GithubTrendingCell> {
        let events = methodInvoked(#selector(GithubTrendingCellDelegate.githubTrendingOwnerTap(_:))).compactMap({ $0.first as? GithubTrendingCell })
        return ControlEvent(events: events)
    }
}
