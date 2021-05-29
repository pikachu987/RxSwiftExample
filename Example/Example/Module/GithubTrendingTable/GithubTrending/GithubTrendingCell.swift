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
    
    fileprivate let ownerButton: OwnerButton = {
        let button = OwnerButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let updateDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(light: 140/255, dark: 180/255)
        return label
    }()

    var ownerImage: GithubTrendingImageType? {
        didSet {
            guard let ownerImage = ownerImage else { return }
            if case let .image(image) = ownerImage {
                ownerButton.stopAnimating(image)
            } else if ownerImage == .empty {
                ownerButton.stopAnimating(nil)
            } else if ownerImage == .loading {
                ownerButton.startAnimating()
            }
        }
    }
    
    var repository: GithubTrendingRepository? {
        didSet {
            titleLabel.text = repository?.name
            ownerButton.text = repository?.owner?.login
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
            titleLabel.topAnchor.constraint(equalTo: ownerButton.topAnchor, constant: 4),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualTo: ownerButton.heightAnchor)
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
        ownerButton.setImage(nil, for: .normal)
        updateDateLabel.text = nil
        disposeBag = DisposeBag()
    }
}

// MARK: GithubTrendingCell
extension Reactive where Base: GithubTrendingCell {
    var githubTrendingOwnerTap: ControlEvent<Void> {
        return base.ownerButton.rx.tap
    }
}

// MARK: OwnerButton
extension GithubTrendingCell {
    class OwnerButton: UIButton {
        private let ownerLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor(light: 99/255, dark: 224/255)
            return label
        }()

        fileprivate let ownerImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 18
            imageView.backgroundColor = UIColor(light: 218/255, dark: 99/255)
            return imageView
        }()
        
        private let activityIndicatorView: UIActivityIndicatorView = {
            let activityIndicatorView = UIActivityIndicatorView()
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.tintColor = UIColor.white
            if #available(iOS 13.0, *) {
                activityIndicatorView.style = .medium
            } else {
                activityIndicatorView.style = .white
            }
            activityIndicatorView.hidesWhenStopped = true
            return activityIndicatorView
        }()

        var text: String? {
            get {
                return ownerLabel.text
            }
            set {
                ownerLabel.text = newValue
            }
        }
        
        var image: UIImage? {
            get {
                return ownerImageView.image
            }
            set {
                ownerImageView.image = newValue
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                ownerLabel.alpha = isHighlighted ? 0.3 : 1
                ownerImageView.alpha = isHighlighted ? 0.5 : 1
            }
        }

        convenience init() {
            self.init(type: .system)
            
            clipsToBounds = true
            isUserInteractionEnabled = true
            
            addSubview(ownerLabel)
            addSubview(ownerImageView)
            addSubview(activityIndicatorView)
            
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: ownerLabel.leadingAnchor),
                centerYAnchor.constraint(equalTo: ownerLabel.centerYAnchor)
            ])
            
            NSLayoutConstraint.activate([
                ownerLabel.trailingAnchor.constraint(equalTo: ownerImageView.leadingAnchor, constant: -8),
                trailingAnchor.constraint(equalTo: ownerImageView.trailingAnchor),
                topAnchor.constraint(equalTo: ownerImageView.topAnchor),
                bottomAnchor.constraint(equalTo: ownerImageView.bottomAnchor)
            ])
            
            NSLayoutConstraint.activate([
                ownerImageView.widthAnchor.constraint(equalToConstant: 36),
                ownerImageView.heightAnchor.constraint(equalToConstant: 36)
            ])
            
            NSLayoutConstraint.activate([
                ownerImageView.centerYAnchor.constraint(equalTo: activityIndicatorView.centerYAnchor),
                ownerImageView.centerXAnchor.constraint(equalTo: activityIndicatorView.centerXAnchor)
            ])
        }
        
        func startAnimating() {
            ownerImageView.backgroundColor = .clear
            activityIndicatorView.startAnimating()
            image = nil
        }
        
        func stopAnimating(_ image: UIImage? = nil) {
            ownerImageView.backgroundColor = UIColor(light: 218/255, dark: 99/255)
            activityIndicatorView.stopAnimating()
            self.image = image
        }
    }
}
