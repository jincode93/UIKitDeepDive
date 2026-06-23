//
//  GalleryViewController.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import UIKit

class GalleryViewController: UIViewController {
    
    enum Section: Int, Hashable, CaseIterable {
        case featured // 대형 배너 - 가로 스크롤
        case trending // 중형 카드 - 가로 스크롤
        case allPhotos // 2열 그리드 - 세로 스크롤
        
        var title: String {
            switch self {
            case .featured: return "Featured"
            case .trending: return "Trending"
            case .allPhotos: return "All Photos"
            }
        }
    }
    
    // MARK: - Properties
    
    private var photos: [PicsumPhoto] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, PicsumPhoto>!
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .systemBackground
        return collection
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        configureDataSource()
        fetchPhotos()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupCollectionView() {
        collectionView.register(GalleyCell.self, forCellWithReuseIdentifier: GalleyCell.reuseIdentifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: SectionHeaderView.elementKind,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.delegate = self
    }
    
    // MARK: - Compositional Layout
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self,
                  let section = Section(rawValue: sectionIndex)
            else {
                return self?.createAllPhotosSection()
            }
            
            switch section {
            case .featured:
                return self.createFeaturedSection()
            case .trending:
                return self.createTrendingSection()
            case .allPhotos:
                return self.createAllPhotosSection()
            }
        }
        
        return layout
    }
    
    private func createFeaturedSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.85),
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createTrendingSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.4),
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createAllPhotosSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.55)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let header = createSectionHeader()
        header.pinToVisibleBounds = true
        header.zIndex = 2
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: SectionHeaderView.elementKind,
            alignment: .top
        )
        
        return header
    }
    
    // MARK: - Diffable DataSource
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PicsumPhoto>(
            collectionView: collectionView
        ) { collectionView, indexPath, photo in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GalleyCell.reuseIdentifier,
                for: indexPath
            ) as? GalleyCell else { return UICollectionViewCell() }
            
            cell.configure(with: photo)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self,
                  kind == SectionHeaderView.elementKind,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                    for: indexPath
                  ) as? SectionHeaderView else {
                return UICollectionReusableView()
            }
            
            let section = Section(rawValue: indexPath.section)
            
            switch section {
            case .featured:
                header.configure(title: "Featured", subtitle: "에디터 추천 사진")
            case .trending:
                header.configure(title: "Trending", subtitle: "지금 인기있는 사진")
            case .allPhotos:
                header.configure(title: "All Photos")
            case .none:
                break
            }
            
            if section == .allPhotos {
                header.backgroundColor = .systemBackground
            }
            
            return header
        }
    }
    
    // MARK: - Snapshot
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PicsumPhoto>()
        
        let featured = Array(photos.prefix(5))
        let trending = Array(photos.dropFirst(5).prefix(10))
        let allPhotos = Array(photos.dropFirst(15))
        
        snapshot.appendSections([.featured, .trending, .allPhotos])
        snapshot.appendItems(featured, toSection: .featured)
        snapshot.appendItems(trending, toSection: .trending)
        snapshot.appendItems(allPhotos, toSection: .allPhotos)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Data Fetching
    
    private func fetchPhotos() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let fetchedPhotos: [PicsumPhoto] = try await NetworkManager.shared.fetch(
                    .picsumList(page: 1, limit: 30)
                )
                
                await MainActor.run {
                    self.photos = fetchedPhotos
                    self.applySnapshot()
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    print("Gallery fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let detailVC = PhotoDetailViewController(photo: photo)
        detailVC.preferredTransition = .zoom(sourceViewProvider: { _ in
            collectionView.cellForItem(at: indexPath)
        })
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
