//
//  GalleryCell.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/23/26.
//

import UIKit

class GalleyCell: UICollectionViewCell {
    
    static let reuseIdentifier = "GalleryCell"
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .systemGray5
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private var imageLoadTask: Task<Void, Never>?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    // MARK: - Configure
    
    func configure(with photo: PicsumPhoto) {
        titleLabel.text = photo.author
        loadImage(photo: photo)
    }
    
    private func loadImage(photo: PicsumPhoto) {
        imageLoadTask?.cancel()
        
        guard let url = photo.imageURL(width: 300, height: 300) else { return }
        
        imageLoadTask = Task {
            let image = await ImageCacheManager.shared.loadImage(from: url)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                if let image {
                    UIView.transition(
                        with: self.imageView,
                        duration: 0.2,
                        options: .transitionCrossDissolve
                    ) {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageView.image = nil
        titleLabel.text = nil
    }
}
