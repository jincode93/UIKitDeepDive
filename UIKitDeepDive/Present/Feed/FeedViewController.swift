//
//  FeedViewController.swift
//  UIKitDeepDive
//
//  Created by 진준호 on 6/22/26.
//

import UIKit

class FeedViewController: UIViewController {
    
    enum Section: Hashable {
        case main
    }
    
    // MARK: - Properties
    
    private var posts: [Post] = []
    private var users: [User] = []
    
    private var dataSource: UITableViewDiffableDataSource<Section, FeedItem>!
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
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
        setupTableView()
        configureDataSource()
        fetchData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupTableView() {
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        tableView.register(ImagePostCell.self, forCellReuseIdentifier: ImagePostCell.reuseIdentifier)
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
    }
    
    // MARK: - Diffable DataSource
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, FeedItem>(
            tableView: tableView
        ) { [weak self] tableView, indexPath, feedItem in
            guard let self else { return UITableViewCell() }
            
            switch feedItem {
            case .textPost(let post):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: PostCell.reuseIdentifier,
                    for: indexPath
                ) as? PostCell else { return UITableViewCell() }
                
                cell.configure(with: post, authorName: self.authorName(for: post.userId))
                return cell
                
            case .imagePost(let post):
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ImagePostCell.reuseIdentifier,
                    for: indexPath
                ) as? ImagePostCell else { return UITableViewCell() }
                
                cell.configure(with: post, authorName: self.authorName(for: post.userId))
                return cell
            }
        }
    }
    
    // MARK: - Snapshot
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FeedItem>()
        snapshot.appendSections([.main])
        
        let feedItems: [FeedItem] = posts.map { post in
            if post.id % 3 == 0 {
                return .imagePost(post)
            } else {
                return .textPost(post)
            }
        }
        
        snapshot.appendItems(feedItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    // MARK: - Data Fetching
    
    private func fetchData() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        
        Task {
            do {
                async let fetchedPosts: [Post] = NetworkManager.shared.fetch(.posts(page: 1, limit: 30))
                async let fetchedUsers: [User] = NetworkManager.shared.fetch(.users)
                
                let (postsResult, userResult) = try await (fetchedPosts, fetchedUsers)
                
                await MainActor.run {
                    self.posts = postsResult
                    self.users = userResult
                    self.applySnapshot(animatingDifferences: false)
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                }
            } catch {
                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.showErrorAlert(error)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func authorName(for userId: Int) -> String {
        users.first { $0.id == userId }?.name ?? "Unknown"
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "오류",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "재시도", style: .default) { [weak self] _ in
            self?.fetchData()
        })
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let feedItem = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch feedItem {
        case .textPost(let post):
            print("텍스트 포스트 선택: \(post.title)")
        case .imagePost(let post):
            print("이미지 포스트 선택: \(post.title)")
        }
    }
}
