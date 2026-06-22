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
        case loader
    }
    
    // MARK: - Properties
    
    private var posts: [Post] = []
    private var users: [User] = []
    
    private var currentPage = 1
    private let pageSize = 20
    private var isLoading = false
    private var hasMorePages = true
    
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
        fetchData(page: 1)
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
        tableView.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.reuseIdentifier)
        
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
            case .textPost(let snapshotPost):
                let post = self.posts.first { $0.id == snapshotPost.id } ?? snapshotPost
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: PostCell.reuseIdentifier,
                    for: indexPath
                ) as? PostCell else { return UITableViewCell() }
                
                cell.configure(with: post, authorName: self.authorName(for: post.userId))
                return cell
                
            case .imagePost(let snapshotPost):
                let post = self.posts.first { $0.id == snapshotPost.id } ?? snapshotPost
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ImagePostCell.reuseIdentifier,
                    for: indexPath
                ) as? ImagePostCell else { return UITableViewCell() }
                
                cell.configure(with: post, authorName: self.authorName(for: post.userId))
                return cell
                
            case .loading:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: LoadingCell.reuseIdentifier,
                    for: indexPath
                ) as? LoadingCell else { return UITableViewCell() }
                
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
        
        if hasMorePages {
            snapshot.appendSections([.loader])
            snapshot.appendItems([.loading], toSection: .loader)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    // MARK: - Data Fetching
    
    private func fetchData(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        if page == 1 {
            activityIndicator.startAnimating()
            tableView.isHidden = true
        }
        
        Task {
            do {
                if page == 1 {
                    async let fetchedPosts: [Post] = NetworkManager.shared.fetch(.posts(page: page, limit: pageSize))
                    async let fetchedUsers: [User] = NetworkManager.shared.fetch(.users)
                    
                    let (postsResult, userResult) = try await (fetchedPosts, fetchedUsers)
                    
                    await MainActor.run {
                        self.users = userResult
                        self.handlePostsResponse(postsResult, page: page)
                    }
                } else {
                    let newPosts: [Post] = try await NetworkManager.shared.fetch(.posts(page: page, limit: pageSize))
                    
                    await MainActor.run {
                        self.handlePostsResponse(newPosts, page: page)
                    }
                }
                
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false
                    self.showErrorAlert(error)
                }
            }
        }
    }
    
    private func handlePostsResponse(_ newPosts: [Post], page: Int) {
        if newPosts.count < pageSize {
            hasMorePages = false
        }
        
        if page == 1 {
            posts = newPosts
        } else {
            posts.append(contentsOf: newPosts)
        }
        
        currentPage = page
        isLoading = false
        
        applySnapshot(animatingDifferences: page != 1)
        
        activityIndicator.stopAnimating()
        tableView.isHidden = false
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
            guard let self else { return }
            self.fetchData(page: self.currentPage + 1)
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
        case .loading:
            break
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 200 {
            guard hasMorePages, !isLoading else { return }
            fetchData(page: currentPage + 1)
        }
    }
    
    // MARK: - Trailing Swipe (← 왼쪽으로 스와이프)
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let feedItem = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        if case .loading = feedItem { return nil }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "삭제"
        ) { [weak self] _, _, completionHandler in
            guard let self else { return }
            self.deleteItem(feedItem)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let moreAction = UIContextualAction(style: .normal, title: "더보기") { [weak self] _, _, completionHandler in
            guard let self else { return }
            self.showMoreOptions(for: feedItem)
            completionHandler(true)
        }
        
        moreAction.backgroundColor = .systemGray
        moreAction.image = UIImage(systemName: "ellipsis.circle")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, moreAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    // MARK: - Leading Swipe (→ 오른쪽으로 스와이프)
    
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let feedItem = dataSource.itemIdentifier(for: indexPath) else { return nil }
        if case .loading = feedItem { return nil }
        
        let snapshotPost: Post
        switch feedItem {
        case .textPost(let p), .imagePost(let p):
            snapshotPost = p
        case .loading:
            return nil
        }
        
        guard let post = posts.first(where: { $0.id == snapshotPost.id }) else { return nil }
        
        let bookmarkAction = UIContextualAction(
            style: .normal,
            title: post.isBookmarked ? "해제" : "북마크"
        ) { [weak self] _, _, completionHandler in
            guard let self else { return }
            self.toggleBookmark(for: post)
            completionHandler(true)
        }
        bookmarkAction.image = UIImage(
            systemName: post.isBookmarked ? "bookmark.slash" : "bookmark.fill"
        )
        bookmarkAction.backgroundColor = post.isBookmarked ? .systemGray : .systemOrange
        
        let config = UISwipeActionsConfiguration(actions: [bookmarkAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    // MARK: - Swipe Action Helpers
    
    private func deleteItem(_ feedItem: FeedItem) {
        switch feedItem {
        case .textPost(let post), .imagePost(let post):
            posts.removeAll { $0.id == post.id }
        case .loading:
            return
        }
        
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([feedItem])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func toggleBookmark(for post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isBookmarked.toggle()
        
        let feedItem: FeedItem = post.id % 3 == 0 ? .imagePost(post) : .textPost(post)
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems([feedItem])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func showMoreOptions(for feedItem: FeedItem) {
        let post: Post
        switch feedItem {
        case .textPost(let p), .imagePost(let p):
            post = p
        case .loading:
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "공유", style: .default) { _ in
            print("공유: \(post.title)")
        })
        alert.addAction(UIAlertAction(title: "신고", style: .destructive) { _ in
            print("신고: \(post.title)")
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
}
