//
//  GithubTrendingCell.swift
//  Example
//
//  Created by GwanhoKim on 2021/05/25.
//

import UIKit
import RxSwift
import RxCocoa

class GithubTrendingCell: UITableViewCell {
    static let identifier = "GithubTrendingCell"
    var disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
        return label
    }()
    
    fileprivate let ownerButton: UIButton = {
        let button = UIButton(type: .system)
        button.isUserInteractionEnabled = true
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
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(ownerButton)
        contentView.addSubview(updateDateLabel)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -16),
            contentView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: ownerButton.leadingAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: ownerButton.topAnchor, constant: 4)
        ])
            
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(equalTo: ownerButton.trailingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: updateDateLabel.topAnchor, constant: -10)
        ])
        
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(equalTo: updateDateLabel.trailingAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: updateDateLabel.bottomAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        ownerButton.setTitle(nil, for: .normal)
        updateDateLabel.text = nil
        disposeBag = DisposeBag()
    }
}

extension Reactive where Base: GithubTrendingCell {
    var githubTrendingOwnerTap: ControlEvent<Void> {
        return base.ownerButton.rx.tap
    }
}
