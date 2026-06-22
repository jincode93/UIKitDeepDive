//
//  ImagePostCell.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import UIKit

class ImagePostCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagePostCell"
    
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
        label.numberOfLines = 2
        return label
    }()
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        return label
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    
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
        contentView.addSubview(authorLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(statsLabel)
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = statsLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor, constant: -12
        )
        bottomConstraint.priority = UILayoutPriority(999)
        
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalToConstant: 200),
            
            bodyLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            statsLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 6),
            statsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomConstraint
        ])
    }
    
    // MARK: - Configure
    
    func configure(with post: Post, authorName: String) {
        authorLabel.text = authorName
        titleLabel.text = post.title
        bodyLabel.text = post.body
        statsLabel.text = "포스트 #\(post.id)"
        loadImage(id: post.id)
    }
    
    private func loadImage(id: Int) {
        imageLoadTask?.cancel()
        
        let url = URL(string: "https://loremflickr.com/400/200?lock=\(id)")!
        
        imageLoadTask = Task {
            do {
                let data = try await NetworkManager.shared.fetchImage(from: url)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.postImageView.image = UIImage(data: data)
                }
            } catch {
                // 이미지 로딩 실패 시 placeholder 유지
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        postImageView.image = nil
        postImageView.backgroundColor = .systemGray5
        authorLabel.text = nil
        titleLabel.text = nil
        bodyLabel.text = nil
        statsLabel.text = nil
    }
}
