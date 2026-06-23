//
//  PhotoDetailViewController.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/23/26.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    let photo: PicsumPhoto
    
    // MARK: - UI Components
    
    let photoImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.backgroundColor = .black
        return image
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Init
    
    init(photo: PicsumPhoto) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImage()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        title = photo.author
        
        view.addSubview(photoImageView)
        view.addSubview(authorLabel)
        view.addSubview(sizeLabel)
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            authorLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            authorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            sizeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            sizeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        authorLabel.text = photo.author
        sizeLabel.text = "\(photo.width) x \(photo.height)"
    }
    
    private func loadImage() {
        guard let url = photo.imageURL(width: 800, height: 600) else { return }
        
        Task {
            let image = await ImageCacheManager.shared.loadImage(from: url)
            guard let image else { return }
            await MainActor.run {
                self.photoImageView.image = image
            }
        }
    }
}
