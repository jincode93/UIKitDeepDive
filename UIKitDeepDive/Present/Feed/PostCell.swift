//
//  PostCell.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import UIKit

class PostCell: UITableViewCell {
    
    static let reuseIdentifier = "PostCell"
    
    // MARK: - UI Components
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()
    
    private let postImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        image.backgroundColor = .randomPastel()
        return image
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint!
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        let textStack = UIStackView(arrangedSubviews: [authorLabel, titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textStack)
        contentView.addSubview(postImageView)
        contentView.addSubview(statsLabel)
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            postImageView.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageHeightConstraint,
            
            statsLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            statsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    // MARK: - Configure
    
    func configure(with post: Post, authorName: String) {
        authorLabel.text = authorName
        titleLabel.text = post.title
        bodyLabel.text = post.body
        
        let hasImage = post.id % 3 == 0
        if hasImage {
            imageHeightConstraint.constant = 200
            postImageView.backgroundColor = .randomPastel()
            postImageView.isHidden = false
        } else {
            imageHeightConstraint.constant = 0
            postImageView.isHidden = true
        }
        
        statsLabel.text = "댓글 · 포스트 #\(post.id)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        authorLabel.text = nil
        titleLabel.text = nil
        bodyLabel.text = nil
        statsLabel.text = nil
        postImageView.backgroundColor = .randomPastel()
        imageHeightConstraint.constant = 0
    }
}
